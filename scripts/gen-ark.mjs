#!/usr/bin/env node
/**
 * 契约翻译生成器（鸿蒙 · 核心资产）
 * ---------------------------------------------------------------
 * 输入：lieshou-contract-types 源码（business/*.ts + index.ts）
 * 输出：ArkTS 契约文件（.ets，HAR 内 contract-types/src/main/ets/contracts/）
 *
 * 纪律：
 * - 产物由本脚本生成，禁止手写漂移；契约变更 → 重跑脚本
 * - ArkTS 不兼容点一律在 RULES 表 + ArkTsTransformer 中处理，勿改产物
 * - 用法：node scripts/gen-ark.mjs [--input <contract-types/src>] [--output <ets 目录>]
 */
import ts from 'typescript';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_INPUT = path.resolve(__dirname, '../open/contract-types/src');
const DEFAULT_OUTPUT = path.resolve(__dirname, '../contract-types/src/main/ets/contracts');

// ---------------------------------------------------------------------------
// RULES —— 文本级替换（在 AST 解析前应用，解决 import/React 专属/函数级问题）
// ---------------------------------------------------------------------------
const FILE_RULES = {
  // React 组件工厂类型（EditionExtraRoute.load）→ 鸿蒙动态加载语义占位
  'edition.ts': {
    transforms: [
      [/import type \{ ComponentType \} from 'react';\r?\n/, ''],
      [
        /(\s*)load: \(\) => Promise<\{ default: ComponentType \}>;(\n)/,
        '$1/** 动态加载语义（鸿蒙 Navigation 编译期路由；此字段保留兼容占位） */$1load?: () => Promise<void>;$2',
      ],
    ],
  },
  // dayjs（npm 依赖）→ 剔除 dayjs 函数，其余类型保留
  'supply.ts': {
    transforms: [[/^import dayjs, \{ type Dayjs \} from "dayjs";\r?\n/m, '']],
    dropSymbols: ['defaultSettlementPeriod'],
  },
  // iot.ts JSON.parse 返回 any（ArkTS 禁）→ 显式 Object 标注
  'iot.ts': {
    transforms: [[/const parsed = JSON\.parse\(actionsJson\);/g, 'const parsed: Object = JSON.parse(actionsJson);']],
  },
};

const INDEX_TOOL_TYPES = ['ApiResponse', 'HealthStatus', 'IndustryId', 'StatusMeta', 'getStatusMeta', 'RoleTagColor'];
const UTILITY_TYPES = ['Pick', 'Partial', 'Omit', 'Required'];

// ---------------------------------------------------------------------------
// 顶层声明名提取
// ---------------------------------------------------------------------------
function declNameOf(stmt) {
  if (
    ts.isTypeAliasDeclaration(stmt) ||
    ts.isInterfaceDeclaration(stmt) ||
    ts.isEnumDeclaration(stmt) ||
    ts.isFunctionDeclaration(stmt) ||
    ts.isClassDeclaration(stmt)
  ) {
    return stmt.name?.text;
  }
  if (ts.isVariableStatement(stmt)) {
    for (const d of stmt.declarationList.declarations) {
      if (ts.isIdentifier(d.name)) return d.name.text;
    }
  }
  return undefined;
}

/** type literal 成员文本（含 JSDoc） */
function literalMembersText(node, sf) {
  return node.members.map((m) => m.getFullText(sf).replace(/\s+$/, '')).join('\n');
}

/** 展开 utility type（Pick/Partial/Omit/Required）为接口成员文本 */
function expandUtilityType(node, sf) {
  const name = node.typeName.text;
  const targetRef = node.typeArguments?.[0];
  if (!targetRef) return null;
  const targetName = targetRef.getText(sf);
  const keysArg = node.typeArguments?.[1];
  const keys = keysArg ? Array.from(keysArg.getText(sf).matchAll(/["']([^"']+)["']/g)).map((m) => m[1]) : null;

  let targetIface = null;
  ts.forEachChild(sf, (s) => {
    if (ts.isInterfaceDeclaration(s) && s.name.text === targetName) targetIface = s;
  });
  if (!targetIface) return null;

  const members = targetIface.members
    .filter((m) => ts.isPropertySignature(m) || ts.isMethodSignature(m))
    .filter((m) => {
      if (!ts.isPropertySignature(m)) return true;
      const key = m.name.getText(sf);
      if (name === 'Pick' || name === 'Partial') return keys ? keys.includes(key) : true;
      if (name === 'Omit') return keys ? !keys.includes(key) : false;
      if (name === 'Required') return keys ? keys.includes(key) : true;
      return true;
    })
    .map((m) => {
      let t = m.getFullText(sf).replace(/\s+$/, '');
      if ((name === 'Partial' || name === 'Omit') && ts.isPropertySignature(m) && !m.questionToken) {
        t = t.replace(':', '?:', 1);
      }
      return t;
    });

  return members.length ? members.join('\n') : null;
}

/**
 * ArkTS 兼容转换（AST 级）：
 *  A. 内联对象字面量类型 `{...}` → 命名接口（arkts-no-obj-literals-as-types），同形状复用
 *  B. unknown/any → Object（arkts-no-any-unknown）
 *  C. Pick/Partial/Omit/Required → 展开接口（arkts-no-utility-types）
 *  D. 泛型 type alias `type X<T> = {...}` → interface X<T>（保泛型）
 *  E. Record<T, I> 值对象字面量 → 生成键集 interface（arkts-no-untyped-obj-literals）
 *  F. OPTIONS 派生数组编译期求值（arkts-no-props-by-index + untyped）
 */

/** 找同文件顶层 `const Y = {...}` 的对象字面量 */
function findConstObject(sf, name) {
  for (const s of sf.statements) {
    if (!ts.isVariableStatement(s)) continue;
    for (const d of s.declarationList.declarations) {
      if (
        ts.isIdentifier(d.name) &&
        d.name.text === name &&
        d.initializer &&
        ts.isObjectLiteralExpression(d.initializer)
      ) {
        return d.initializer;
      }
    }
  }
  return null;
}

/**
 * OPTIONS 派生数组求值：`(Object.keys(Y) as X[]).map(s => ({ value: s, label: Y[s].text }))`
 * → 静态字面量数组（ArkTS 禁 props-by-index 与 map 回调对象字面量）
 * 仅支持 value=键 / label=Y[键].text 模式；其他形态返回 null 保留原样。
 */
function evalOptions(sf, init) {
  if (!ts.isCallExpression(init)) return null;
  const prop = init.expression;
  if (!ts.isPropertyAccessExpression(prop) || prop.name.text !== 'map') return null;
  let targetExpr = prop.expression;
  if (ts.isParenthesizedExpression(targetExpr)) targetExpr = targetExpr.expression;
  if (ts.isAsExpression(targetExpr)) targetExpr = targetExpr.expression;
  let yName = null;
  if (
    ts.isCallExpression(targetExpr) &&
    ts.isPropertyAccessExpression(targetExpr.expression) &&
    targetExpr.expression.name.text === 'keys' &&
    targetExpr.arguments[0] &&
    ts.isIdentifier(targetExpr.arguments[0])
  ) {
    yName = targetExpr.arguments[0].text;
  }
  if (!yName) return null;
  const yObj = findConstObject(sf, yName);
  if (!yObj) return null;
  const cb = init.arguments[0];
  if (!cb || !ts.isArrowFunction(cb)) return null;
  let body = cb.body;
  if (ts.isParenthesizedExpression(body)) body = body.expression;
  if (!ts.isObjectLiteralExpression(body)) return null;
  const valueProp = body.properties.find(
    (p) => ts.isPropertyAssignment(p) && p.name.getText(sf) === 'value',
  );
  const labelProp = body.properties.find(
    (p) => ts.isPropertyAssignment(p) && p.name.getText(sf) === 'label',
  );
  if (!valueProp || !labelProp) return null;
  if (!ts.isPropertyAssignment(valueProp) || !ts.isPropertyAssignment(labelProp)) return null;
  if (!ts.isIdentifier(valueProp.initializer)) return null; // value 必须是键本身
  let labelField = null;
  if (ts.isPropertyAccessExpression(labelProp.initializer)) {
    labelField = labelProp.initializer.name.text; // Y[s].text / Y[s].label 等字段访问
  }
  if (!labelField) return null;

  const items = [];
  for (const p of yObj.properties) {
    if (!ts.isPropertyAssignment(p) || !ts.isIdentifier(p.name)) continue;
    const key = p.name.text;
    let label = key;
    if (ts.isObjectLiteralExpression(p.initializer)) {
      const textProp = p.initializer.properties.find(
        (pp) => ts.isPropertyAssignment(pp) && pp.name.getText(sf) === labelField,
      );
      if (textProp && ts.isPropertyAssignment(textProp) && ts.isStringLiteral(textProp.initializer)) {
        label = textProp.initializer.text;
      }
    }
    items.push(`{ value: '${key}', label: '${label}' }`);
  }
  return items.length ? `[${items.join(', ')}]` : null;
}

/** 提取数组/泛型内层的内联对象类型（Array<{...}> / {..}[] → {..}） */
function extractInnerLiteral(node) {
  if (ts.isTypeLiteralNode(node)) return node;
  if (ts.isTypeReferenceNode(node) && node.typeName && node.typeName.text === 'Array' && node.typeArguments?.[0]) {
    return extractInnerLiteral(node.typeArguments[0]);
  }
  if (ts.isArrayTypeNode(node)) return extractInnerLiteral(node.elementType);
  return null;
}

function applyArkTsTransforms(stmt, sf) {
  const declName = declNameOf(stmt) ?? 'Anon';
  const fullText = stmt.getFullText(sf);
  const base = stmt.getFullStart(sf);
  const hoisted = [];
  const shapeToName = new Map();
  const usedNames = new Set();
  const replacements = [];
  const recordValueTargets = []; // { itemTypeTextOrNode }

  const nameFor = (shape, kind) => {
    if (shapeToName.has(shape)) return shapeToName.get(shape);
    let n = `${declName}_${kind}`;
    let i = 1;
    while (usedNames.has(n)) n = `${declName}_${kind}${++i}`;
    usedNames.add(n);
    shapeToName.set(shape, n);
    return n;
  };

  const visit = (node) => {
    // G. 索引访问类型 `T["field"]` → 展开为实际类型（arkts-no-aliases-by-index）
    if (ts.isIndexedAccessTypeNode(node)) {
      const objType = node.objectType;
      const idxType = node.indexType;
      if (ts.isTypeReferenceNode(objType) && ts.isLiteralTypeNode(idxType) && ts.isStringLiteral(idxType.literal)) {
        const ifaceName = objType.typeName.text;
        const field = idxType.literal.text;
        let fieldType = null;
        let fieldTypeNode = null;
        ts.forEachChild(sf, (s) => {
          if (ts.isInterfaceDeclaration(s) && s.name.text === ifaceName) {
            for (const m of s.members) {
              if (ts.isPropertySignature(m) && m.name.getText(sf) === field) {
                fieldType = m.type ? m.type.getText(sf) : null;
                fieldTypeNode = m.type ?? null;
              }
            }
          }
        });
        if (fieldType !== null) {
          // 展开结果若为内联对象类型（含 Array<{...}>），先走 A 提升
          const innerLit = extractInnerLiteral(fieldTypeNode);
          if (innerLit) {
            const shape = `obj:{${literalMembersText(innerLit, sf)}}`;
            if (!shapeToName.has(shape)) {
              const n = nameFor(shape, 'Item');
              hoisted.push({ shape, text: `export interface ${n} {\n${literalMembersText(innerLit, sf)}\n}` });
            }
            const itemName = shapeToName.get(shape);
            fieldType = fieldTypeNode && (ts.isTypeReferenceNode(fieldTypeNode) || ts.isArrayTypeNode(fieldTypeNode)) ? `Array<${itemName}>` : itemName;
          }
          replacements.push({ start: node.getStart(sf) - base, end: node.getEnd() - base, text: fieldType });
        }
      }
      return;
    }
    // C. utility types
    if (ts.isTypeReferenceNode(node) && node.typeName && UTILITY_TYPES.includes(node.typeName.text)) {
      const shape = `utility:${node.typeName.text}:${node.getText(sf)}`;
      if (!shapeToName.has(shape)) {
        const body = expandUtilityType(node, sf);
        if (body === null) return;
        const n = nameFor(shape, 'Expanded');
        hoisted.push({ shape, text: `export interface ${n} {\n${body}\n}` });
      }
      replacements.push({ start: node.getStart(sf) - base, end: node.getEnd() - base, text: shapeToName.get(shape) });
      return;
    }
    // A. 内联对象字面量类型
    if (ts.isTypeLiteralNode(node)) {
      const shape = `obj:{${literalMembersText(node, sf)}}`;
      if (!shapeToName.has(shape)) {
        const n = nameFor(shape, 'Item');
        hoisted.push({ shape, text: `export interface ${n} {\n${literalMembersText(node, sf)}\n}` });
      }
      // Record<T, {...}> 的第二个 typeArg：不生成替换（E 规则会整体替换 type，避免区间重叠）
      const parent = node.parent;
      const isRecordItem =
        parent &&
        ts.isTypeReferenceNode(parent) &&
        parent.typeName.text === 'Record' &&
        parent.typeArguments?.[1] === node;
      if (!isRecordItem) {
        replacements.push({ start: node.getStart(sf) - base, end: node.getEnd() - base, text: shapeToName.get(shape) });
      }
      return;
    }
    // B. unknown/any → Object
    if (node.kind === ts.SyntaxKind.UnknownKeyword || node.kind === ts.SyntaxKind.AnyKeyword) {
      replacements.push({ start: node.getStart(sf) - base, end: node.getEnd() - base, text: 'Object' });
      return;
    }
    ts.forEachChild(node, visit);
  };

  // D. 泛型 type alias：`type X<T> = {...}` → interface X<T>（短路：不再做对象类型提升）
  let genericAliasReplaced = null;
  if (
    ts.isTypeAliasDeclaration(stmt) &&
    stmt.typeParameters?.length &&
    ts.isTypeLiteralNode(stmt.type)
  ) {
    const tps = stmt.typeParameters.map((p) => p.getText(sf)).join(', ');
    const members = literalMembersText(stmt.type, sf);
    const n = stmt.name.text;
    genericAliasReplaced = `export interface ${n}<${tps}> {\n${members}\n}`;
  }

  if (!genericAliasReplaced) {
    ts.forEachChild(stmt, visit);
  }

  // E. Record<T, I> 值对象 → 生成显式键集 interface `X_Table`，const 注解指向它
  //    （ArkTS 对象字面量必须直接对应显式 interface，Record 值推断与 as 断言均不可靠）
  if (ts.isVariableStatement(stmt)) {
    for (const d of stmt.declarationList.declarations) {
      const init = d.initializer;
      const type = d.type;
      if (
        init &&
        ts.isObjectLiteralExpression(init) &&
        type &&
        ts.isTypeReferenceNode(type) &&
        type.typeName.text === 'Record' &&
        type.typeArguments?.[1]
      ) {
        const itemTypeNode = type.typeArguments[1];
        let itemType = itemTypeNode.getText(sf);
        if (ts.isTypeLiteralNode(itemTypeNode)) {
          itemType = shapeToName.get(`obj:{${literalMembersText(itemTypeNode, sf)}}`) ?? itemType;
        }
        const keys = init.properties
          .map((p) => (ts.isPropertyAssignment(p) ? p.name.getText(sf) : null))
          .filter(Boolean);
        if (keys.length) {
          const n = nameFor(`table:${declName}`, 'Table');
          hoisted.push({
            shape: `table:${declName}`,
            text: `export interface ${n} {\n${keys.map((k) => `  ${k}: ${itemType};`).join('\n')}\n}`,
          });
          replacements.push({ start: type.getStart(sf) - base, end: type.getEnd() - base, text: n });
        }
      }
      // F. OPTIONS 派生数组编译期求值（替换整个 initializer）
      const evaluated = evalOptions(sf, init);
      if (evaluated) {
        replacements.push({ start: init.getStart(sf) - base, end: init.getEnd() - base, text: evaluated });
      }
    }
  }

  let text = fullText;
  if (genericAliasReplaced) {
    text = genericAliasReplaced;
  } else {
    for (const r of replacements.sort((a, b) => b.start - a.start)) {
      text = text.slice(0, r.start) + r.text + text.slice(r.end);
    }
  }
  return { text, hoisted };
}

// ---------------------------------------------------------------------------
// 单文件翻译
// ---------------------------------------------------------------------------
function translateFile(filePath, fileName) {
  let src = fs.readFileSync(filePath, 'utf8');
  const rules = FILE_RULES[fileName];
  if (rules) {
    for (const [re, repl] of rules.transforms) src = src.replace(re, repl); // 文本级先处理
  }
  const sf = ts.createSourceFile(fileName, src, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
  const drop = new Set(rules?.dropSymbols ?? []);
  const chunks = [];
  const hoistedAll = [];
  const exported = [];
  let hasConst = false;

  for (const stmt of sf.statements) {
    if (ts.isImportDeclaration(stmt)) continue;
    const name = declNameOf(stmt);
    if (name && drop.has(name)) continue;
    if (!ts.isEmptyStatement(stmt)) {
      if (ts.isVariableStatement(stmt)) hasConst = true;
      if (name) exported.push(name);
      const { text, hoisted } = applyArkTsTransforms(stmt, sf);
      hoistedAll.push(...hoisted);
      chunks.push(text);
    }
  }

  let result = chunks.join('\n').trimEnd() + '\n';
  const seenName = new Set();
  const hoistedNames = [];
  for (const h of hoistedAll) {
    if (seenName.has(h.text)) continue; // 同接口文本去重（shape 跨 stmt 同名不共用，不能按 shape 去重）
    seenName.add(h.text);
    const m = h.text.match(/interface (\w+)/);
    if (m) hoistedNames.push(m[1]);
    result += `\n// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----\n${h.text}\n`;
  }
  return { result, exported, hasConst, hoistedNames };
}

// ---------------------------------------------------------------------------
// index.ets —— 工具类型 + 业务全量显式导出（跨模块冲突符号单来源，其余深路径可访问）
// ---------------------------------------------------------------------------
function buildIndex(indexTsPath, businessFiles, allExports) {
  const src = fs.readFileSync(indexTsPath, 'utf8');
  const sf = ts.createSourceFile('index.ts', src, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
  const parts = [];
  const hoistedAll = [];
  for (const stmt of sf.statements) {
    const name = declNameOf(stmt);
    if (name && INDEX_TOOL_TYPES.includes(name)) {
      const { text, hoisted } = applyArkTsTransforms(stmt, sf);
      hoistedAll.push(...hoisted);
      parts.push(text.trimEnd());
    }
  }
  const seenName = new Set();
  const hoistedText = [];
  for (const h of hoistedAll) {
    if (seenName.has(h.text)) continue;
    seenName.add(h.text);
    hoistedText.push(h.text);
  }

  // 冲突检测：符号出现 >1 个模块 → 只归第一个出现的模块导出
  const counts = {};
  for (const syms of Object.values(allExports)) {
    for (const s of syms) counts[s] = (counts[s] ?? 0) + 1;
  }
  const conflicts = new Set(Object.entries(counts).filter(([, c]) => c > 1).map(([s]) => s));
  const owner = {};
  for (const [f, syms] of Object.entries(allExports)) {
    for (const s of syms) {
      if (conflicts.has(s) && !(s in owner)) owner[s] = f;
    }
  }

  const lines = [
    '/**',
    ' * ArkTS 契约聚合入口（生成器产出 · 勿手改）',
    ' * 对应 lieshou-contract-types/src/index.ts',
    ' * 跨模块同名符号（如 STATUS_META）只从首个模块导出；其余走深路径 business/<module>',
    ' */',
    ...parts,
    ...(hoistedText.length ? ['', ...hoistedText] : []),
    '',
    '// -------- 业务 DTO（显式导出 · 冲突单来源）--------',
  ];
  for (const f of businessFiles) {
    const base = f.replace(/\.ts$/, '');
    const syms = (allExports[f] ?? []).filter((s) => !conflicts.has(s) || owner[s] === f);
    if (syms.length) lines.push(`export { ${syms.join(', ')} } from './business/${base}';`);
  }
  return lines.join('\n') + '\n';
}

// ---------------------------------------------------------------------------
// 产物自检
// ---------------------------------------------------------------------------
const ARKTS_FORBIDDEN = [
  { re: /\bany\b/, hint: 'any 类型（ArkTS 禁用）' },
  { re: /\bnamespace\b/, hint: 'namespace（ArkTS 禁用）' },
  { re: /import\s+[^'"()]+from/, hint: '残留 import' },
];
const ARKTS_SUSPECT = [{ re: /\bunknown\b/, hint: 'unknown（待实测）' }];

function selfCheck(files) {
  const problems = [];
  const suspects = [];
  for (const [rel, text] of files) {
    for (const { re, hint } of ARKTS_FORBIDDEN) {
      const m = text.match(re);
      if (m) problems.push(`${rel}: ${hint}（命中 "${m[0]}"）`);
    }
    for (const { re, hint } of ARKTS_SUSPECT) {
      const m = text.match(re);
      if (m) suspects.push(`${rel}: ${hint}（命中 "${m[0]}"）`);
    }
  }
  return { problems, suspects };
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
function parseArgs(argv) {
  const args = { input: DEFAULT_INPUT, output: DEFAULT_OUTPUT };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--input') args.input = path.resolve(argv[++i]);
    else if (argv[i] === '--output') args.output = path.resolve(argv[++i]);
  }
  return args;
}

const { input, output } = parseArgs(process.argv.slice(2));
const businessSrc = path.join(input, 'business');
const businessFiles = fs.readdirSync(businessSrc).filter((f) => f.endsWith('.ts')).sort();

fs.mkdirSync(path.join(output, 'business'), { recursive: true });

const generated = [];
const allExports = {}; // file → [symbols]
for (const f of businessFiles) {
  const { result, exported, hasConst, hoistedNames } = translateFile(path.join(businessSrc, f), f);
  const outName = f.replace(/\.ts$/, '.ets');
  fs.writeFileSync(path.join(output, 'business', outName), result);
  generated.push([`business/${outName}`, result]);
  allExports[outName] = [...exported, ...hoistedNames];
  console.log(`✓ ${f} → ${outName}（${exported.length + hoistedNames.length} 个导出符号）`);
  if (!hasConst) console.log(`  ℹ ${f} 无 const，纯类型模块`);
}

const indexEts = buildIndex(path.join(input, 'index.ts'), businessFiles.map((f) => f.replace(/\.ts$/, '.ets')), allExports);
fs.writeFileSync(path.join(output, 'index.ets'), indexEts);
generated.push(['index.ets', indexEts]);
console.log('✓ index.ts → index.ets（聚合导出）');

const { problems, suspects } = selfCheck(generated);
if (problems.length) {
  console.error('\n❌ ArkTS 自检未通过：');
  for (const p of problems) console.error(`  - ${p}`);
  process.exit(1);
}
if (suspects.length) {
  console.warn('\n⚠️ 待实测验证：');
  for (const s of suspects) console.warn(`  - ${s}`);
}
console.log('\n✅ ArkTS 自检通过（无 any/namespace/import 残留）');
console.log(`输出目录：${output}`);
