# lieshou-ark-contract-types

鸿蒙共享契约层 HAR —— `lieshou-contract-types` → ArkTS 翻译（**生成器产出，禁止手写漂移**）。

## 结构

```
scripts/gen-ark.mjs          # 契约翻译生成器（核心资产）
open/contract-types/         # submodule：React 侧契约唯一事实源
src/main/ets/contracts/      # 生成产物（.ets）
  index.ets                  # 工具类型 + 全量业务聚合导出
  business/*.ets             # 每个 business 模块一个文件
Index.ets                    # HAR 导出入口
```

## 使用

```bash
# 1. 初始化输入源
git submodule update --init --recursive

# 2. 契约变更后重新生成（唯一正确流程）
node scripts/gen-ark.mjs
# 可选参数：--input <contract-types/src> --output <ets 目录>
```

## 翻译规则（改规则不改产物）

| 源 | ArkTS 处理 |
| --- | --- |
| `interface` / `type` / `enum` | 直译（ArkTS 兼容） |
| META / OPTIONS 常量 | 保留显式类型标注（`Record<T, {...}>`、`{...}[]`） |
| 纯函数（Date/String 运算） | 直译 |
| `edition.ts` `ComponentType`（react） | 改写 `load` 为 `() => Promise<void>`（鸿蒙 Navigation 编译期路由语义） |
| `supply.ts` `dayjs` | 剔除 dayjs 函数（`defaultSettlementPeriod`），其余类型保留 |
| `generated*.ts`（OpenAPI 快照） | 不翻译（业务代码走 business 层，与 React 侧一致） |

> ⚠️ `unknown`（iot.ets 影子数据/参数）属待实测语法，构建验证通过前不擅改。

## 构建验证

```bash
/opt/node/bin/devecocli build   # Linux CLT（WSL）
# 或 Windows: C:\dev\node\devecocli.cmd build（工程须在 Windows 原生盘）
```
