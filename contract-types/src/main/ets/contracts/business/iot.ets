/**
 * 物联网类型（iot-service · ADR-0040 · Phase 2 管理页）.
 * 与后端 iot 域实体对齐：产品物模型 / 设备 / 规则（强制租户模式）。
 */

/** 产品（设备型号 + 协议类型） */
export interface IotProduct {
  id: number;
  tenantId: number;
  name: string;
  code?: string | null;
  /** 接入协议类型：BINARY_FRAME / JSON_LINE / HTTP（与 device-gateway ProtocolCodec 对应） */
  protocolType: string;
  enabled: boolean;
  description?: string | null;
  createdAt: string;
  updatedAt?: string;
}


/** 物模型属性定义（设备上报的数据点） */
export interface ProductProperty {
  id: number;
  productId: number;
  /** 属性 key（设备报文中的字段名） */
  name: string;
  /** 显示名 */
  label: string;
  /** 数据类型：NUMBER / STRING / BOOL / ENUM */
  dataType: string;
  unit?: string | null;
  /** 读写权限：R / RW */
  rw: string;
  sortOrder?: number;
  description?: string | null;
}


/** 物模型命令定义（平台可下发给设备的操作） */
export interface ProductCommand {
  id: number;
  productId: number;
  /** 命令 key（下发给设备的命令名） */
  name: string;
  label: string;
  /** JSON 数组：参数定义 [{name,label,dataType,required}] */
  paramsJson?: string | null;
  description?: string | null;
}


/** 产品详情（含属性定义 + 命令定义） */
export interface ProductDetail {
  product: IotProduct;
  properties: ProductProperty[];
  commands: ProductCommand[];
}


/** 设备 */
export interface IotDevice {
  id: number;
  tenantId: number;
  productId: number;
  name: string;
  /** 设备接入凭证（全局唯一） */
  deviceKey: string;
  /** 设备密钥（创建时返回，之后不完整返回） */
  deviceSecret?: string | null;
  status: "ONLINE" | "OFFLINE";
  lastOnlineAt?: string | null;
  lastOfflineAt?: string | null;
  groupName?: string | null;
  /** 安装地址（电网项目：电缆井/杆塔位置） */
  installAddress?: string | null;
  /** 设备照片 URL（无则前端占位图） */
  photoUrl?: string | null;
  tagsJson?: string | null;
  remark?: string | null;
  createdAt: string;
  updatedAt?: string;
  /** 影子摘要：最高节点温度（列表页 · 无节点上报为 null） */
  maxTemperature?: number | null;
  /** 影子摘要：心跳信号强度 0~100（无上报为 null） */
  signalStrength?: number | null;
  /** 影子摘要：未确认告警数（列表「告警」Tag 联动） */
  pendingAlerts?: number;
}


/** 设备详情（含影子快照） */
export interface DeviceDetail {
  device: IotDevice;
  /** 最新属性快照 {"temperature":23.5,"humidity":60} */
  shadow: Record<string, Object>;
}


/** 设备属性时序记录 */
export interface DevicePropertyRecord {
  id: number;
  tenantId: number;
  deviceId: number;
  propertyKey: string;
  /** 值统一存字符串，展示端按物模型 dataType 解析 */
  valueStr: string;
  reportedAt: string;
}


/** 设备事件记录 */
export interface DeviceEventRecord {
  id: number;
  tenantId: number;
  deviceId: number;
  eventKey: string;
  payloadJson?: string | null;
  occurredAt: string;
}


/** 规则（规则引擎配置） */
export interface IotRule {
  id: number;
  tenantId: number;
  name: string;
  enabled: boolean;
  /** 规则级别：WARN（预警）/ CRITICAL（告警） */
  severity?: string;
  /** 触发类型：PROPERTY（属性阈值）/ EVENT（事件） */
  triggerType: "PROPERTY" | "EVENT";
  productId: number;
  propertyKey?: string | null;
  /** 比较操作符：GT / GTE / LT / LTE / EQ / NEQ */
  operator?: string | null;
  /** 阈值（字符串存，按物模型 dataType 解析比较） */
  threshold?: string | null;
  /** 持续秒数（>=0） */
  windowSec?: number;
  /** 多条件组合（JSON 数组 [{key,operator,threshold},...]；为空回退单条件） */
  conditionsJson?: string | null;
  /** 多条件组合逻辑：AND / OR */
  conditionLogic?: string | null;
  eventKey?: string | null;
  /** JSON 数组：动作列表 */
  actionsJson: string;
  description?: string | null;
  createdAt: string;
  updatedAt?: string;
}


/** 告警（规则引擎 NOTIFY 落库 · 值班确认闭环） */
export interface IotAlert {
  id: number;
  tenantId: number;
  deviceId: number;
  ruleId?: number | null;
  ruleName?: string | null;
  severity: "WARN" | "CRITICAL";
  triggerType: "PROPERTY" | "EVENT";
  propertyKey?: string | null;
  actualValue?: string | null;
  threshold?: string | null;
  message?: string | null;
  status: "PENDING" | "ACKNOWLEDGED";
  ackedBy?: string | null;
  ackedAt?: string | null;
  ackRemark?: string | null;
  /** 同规则同设备未确认告警重复命中次数（去重合并计数） */
  repeatCount?: number;
  /** 是否发生级别升级（WARN→CRITICAL） */
  escalated?: boolean;
  /** 最近一次命中时间 */
  lastTriggeredAt?: string | null;
  createdAt: string;
}


/** 设备节点（线缆温度节点 · node{n}_temperature / node{n}_battery） */
export interface DeviceNode {
  nodeId: number;
  temperature: number | null;
  battery: number | null;
}


/** 设备健康聚合（GET /api/iot/devices/health · 驾驶舱一次拉全量影子摘要） */
export interface DeviceHealth {
  deviceId: number;
  name: string;
  status: "ONLINE" | "OFFLINE";
  /** 最高节点温度 */
  maxTemperature?: number | null;
  /** 最热节点 key（node{n}_temperature） */
  hottestNodeKey?: string | null;
  /** 节点列表（node{n}_temperature / node{n}_battery，按节点号升序） */
  nodes?: DeviceNode[];
  /** 心跳信号强度 0~100 */
  signalStrength?: number | null;
  /** 最低节点电池电压 V */
  battery?: number | null;
  /** 局放超声波峰值 dBuv（0/-1=无效 → null） */
  ultrasonicPeak?: number | null;
  /** 局放地电波峰值 dBmv（0/-1=无效 → null） */
  tevPeak?: number | null;
  /** 环境温度 ℃ */
  environmentTemp?: number | null;
  /** 环境湿度 % */
  humidity?: number | null;
  pendingAlerts?: number;
}


/** 电网拓扑（电路图式节点图 · GET /api/iot/topo） */
export interface IotTopo {
  nodes: IotTopo_Item[];
  links: IotTopo_Item2[];
}


/** 拓扑节点位置（PUT /api/iot/topo/nodes 元素） */
export interface TopoNodePosition {
  deviceId: number;
  x: number;
  y: number;
}


/** 监控总览（GET /api/iot/devices/overview） */
export interface IotOverview {
  deviceCount: IotOverview_Item;
  alertsToday: number;
  pendingAlerts: number;
  maxTemperature: IotOverview_Item2;
  offlineDevices: IotOverview_Item3[];
  alertDevices: IotOverview_Item4[];
}


/** 规则动作（actionsJson 数组元素） */
export interface RuleAction {
  type: "COMMAND" | "WEBHOOK" | "NOTIFY";
  /** COMMAND：命令 key */
  command?: string;
  /** COMMAND：命令参数 */
  params?: Record<string, Object>;
  /** WEBHOOK：回调地址 */
  url?: string;
  /** NOTIFY：站内通知内容 */
  message?: string;
}


// ────────────────────────── 请求体 ──────────────────────────

export interface CreateIotProductRequest {
  name: string;
  code?: string;
  protocolType: string;
  description?: string;
  enabled?: boolean;
}


export interface CreateProductPropertyRequest {
  name: string;
  label: string;
  dataType: string;
  unit?: string;
  rw?: string;
  sortOrder?: number;
  description?: string;
}


export interface CreateProductCommandRequest {
  name: string;
  label: string;
  paramsJson?: string;
  description?: string;
}


export interface CreateIotDeviceRequest {
  name: string;
  productId: number;
  /** 自定义设备 Key（私有协议设备=设备号，如 GJXA 0610000012；缺省自动生成） */
  deviceKey?: string;
  /** 自定义设备密钥（与 device-gateway 协议约定值配对；缺省自动生成） */
  deviceSecret?: string;
  groupName?: string;
  /** 安装地址 */
  installAddress?: string;
  /** 设备照片 URL */
  photoUrl?: string;
  tagsJson?: string;
  remark?: string;
}


export interface CreateIotRuleRequest {
  name: string;
  enabled?: boolean;
  /** WARN / CRITICAL */
  severity?: string;
  triggerType: "PROPERTY" | "EVENT";
  productId: number;
  propertyKey?: string;
  operator?: string;
  threshold?: string;
  windowSec?: number;
  eventKey?: string;
  /** JSON 字符串（动作数组） */
  actionsJson: string;
  description?: string;
}


// ────────────────────────── 展示元信息 ──────────────────────────

export const IOT_PROTOCOL_META: IOT_PROTOCOL_META_Table = {
  BINARY_FRAME: { text: "二进制帧", color: "blue" },
  JSON_LINE: { text: "JSON 行", color: "green" },
  HTTP: { text: "HTTP", color: "purple" },
};


export const IOT_DATA_TYPE_META: IOT_DATA_TYPE_META_Table = {
  NUMBER: "数值",
  STRING: "字符串",
  BOOL: "布尔",
  ENUM: "枚举",
};


export const IOT_OPERATOR_META: IOT_OPERATOR_META_Table = {
  GT: ">",
  GTE: "≥",
  LT: "<",
  LTE: "≤",
  EQ: "=",
  NEQ: "≠",
};


export const IOT_TRIGGER_META: IOT_TRIGGER_META_Table = {
  PROPERTY: "属性阈值",
  EVENT: "事件触发",
};


export const IOT_ACTION_META: IOT_ACTION_META_Table = {
  COMMAND: "命令下发",
  WEBHOOK: "Webhook 回调",
  NOTIFY: "站内通知",
};


export const DEVICE_STATUS_META: DEVICE_STATUS_META_Table = {
  ONLINE: { text: "在线", color: "green" },
  OFFLINE: { text: "离线", color: "default" },
};


export const IOT_SEVERITY_META: IOT_SEVERITY_META_Table = {
  WARN: { text: "预警", color: "orange" },
  CRITICAL: { text: "告警", color: "red" },
};


export const IOT_ALERT_STATUS_META: IOT_ALERT_STATUS_META_Table = {
  PENDING: { text: "未确认", color: "red" },
  ACKNOWLEDGED: { text: "已确认", color: "green" },
};


/** 节点温度 key 判断（GJXA 线缆：node{n}_temperature） */
export function isNodeTemperatureKey(key: string): boolean {
  return /^node\d+_temperature$/.test(key);
}


/** 节点号提取（node2_temperature → 2） */
export function nodeIdOfKey(key: string): number | null {
  const m = /^node(\d+)_temperature$/.exec(key);
  return m ? Number(m[1]) : null;
}


// ── 节点温度分级（与监控总览一致：≥70 告警红 / ≥50 预警橙 / 正常蓝，阈值可在规则配置页调整）──

export const TEMP_ALERT_THRESHOLD = 70;

export const TEMP_WARN_THRESHOLD = 50;


export type TemperatureLevel = "ok" | "warn" | "alert";


/** 节点温度分级（GJXA 线缆默认阈值：≥70 告警 / ≥50 预警） */
export function temperatureLevel(t: number): TemperatureLevel {
  if (t >= TEMP_ALERT_THRESHOLD) return "alert";
  if (t >= TEMP_WARN_THRESHOLD) return "warn";
  return "ok";
}


export const TEMPERATURE_LEVEL_COLOR: TEMPERATURE_LEVEL_COLOR_Table = {
  ok: "#1677ff",
  warn: "#fa8c16",
  alert: "#ff4d4f",
};


/** 解析规则 actionsJson（容错：坏 JSON 返回空数组） */
export function parseRuleActions(actionsJson?: string | null): RuleAction[] {
  if (!actionsJson) return [];
  try {
    const parsed: Object = JSON.parse(actionsJson);
    return Array.isArray(parsed) ? (parsed as RuleAction[]) : [];
  } catch {
    return [];
  }
}


/** 解析影子快照：值 → 展示文本（对象/数组 JSON 化） */
export function formatShadowValue(value: Object): string {
  if (value === null || value === undefined) return "—";
  if (typeof value === "object") return JSON.stringify(value);
  return String(value);
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IotTopo_Item {
 deviceId: number;
 x: number;
 y: number
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IotTopo_Item2 {
 source: number;
 target: number
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IotOverview_Item {
 total: number;
 online: number;
 offline: number
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IotOverview_Item2 {
 deviceId: number;
 name: string;
 value: number | null
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IotOverview_Item3 {

    id: number;

    name: string;

    deviceKey: string;

    lastOfflineAt?: string | null;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IotOverview_Item4 {

    alertId: number;

    deviceId: number;

    name: string;

    ruleName?: string | null;

    severity: "WARN" | "CRITICAL";

    propertyKey?: string | null;

    actualValue?: string | null;

    threshold?: string | null;

    message?: string | null;

    createdAt: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_PROTOCOL_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_PROTOCOL_META_Table {
  BINARY_FRAME: IOT_PROTOCOL_META_Item;
  JSON_LINE: IOT_PROTOCOL_META_Item;
  HTTP: IOT_PROTOCOL_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_DATA_TYPE_META_Table {
  NUMBER: string;
  STRING: string;
  BOOL: string;
  ENUM: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_OPERATOR_META_Table {
  GT: string;
  GTE: string;
  LT: string;
  LTE: string;
  EQ: string;
  NEQ: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_TRIGGER_META_Table {
  PROPERTY: string;
  EVENT: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_ACTION_META_Table {
  COMMAND: string;
  WEBHOOK: string;
  NOTIFY: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface DEVICE_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface DEVICE_STATUS_META_Table {
  ONLINE: DEVICE_STATUS_META_Item;
  OFFLINE: DEVICE_STATUS_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_SEVERITY_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_SEVERITY_META_Table {
  WARN: IOT_SEVERITY_META_Item;
  CRITICAL: IOT_SEVERITY_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_ALERT_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface IOT_ALERT_STATUS_META_Table {
  PENDING: IOT_ALERT_STATUS_META_Item;
  ACKNOWLEDGED: IOT_ALERT_STATUS_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface TEMPERATURE_LEVEL_COLOR_Table {
  ok: string;
  warn: string;
  alert: string;
}
