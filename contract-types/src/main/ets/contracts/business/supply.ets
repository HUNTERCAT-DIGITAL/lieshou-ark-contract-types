
/**
 * 供应结算类型（与 edu-service 供应单/消课明细/结算单实体对齐 · zhiye 教育行业版供应侧）.
 *
 * 业务语义（设计文档 §3.4）：合作伙伴向智野采购课程课时包（供应单）→ 消课明细按供应单扣减余额 →
 * 结算单按 合作伙伴 × 周期 服务端聚合（采购应付 − 消耗核销 = 应结金额）。
 * partner_customer_id / course_id 为跨服务逻辑引用（无 FK），展示用名称快照。
 * isDeleted 后端 @JsonIgnore 不下发；此处不声明。
 */

// ---------- 供应单 ----------

export type SupplyOrderStatus = "ACTIVE" | "COMPLETED" | "CANCELLED";


export interface SupplyOrder {
  id: number;
  /** 归属租户（强制取 JWT tid） */
  tenantId: number;
  /** 合作伙伴（逻辑 ref -> crm.customers.id） */
  partnerCustomerId?: number | null;
  partnerName?: string | null;
  /** 课程产品（逻辑 ref -> inventory.products.id） */
  courseId?: number | null;
  courseName?: string | null;
  /** 采购课时数 */
  lessonCount: number;
  /** 单课时价（元） */
  unitPrice: number;
  /** 总金额 = 课时 × 单课时价（服务端计算） */
  amount: number;
  /** 有效期（可选，yyyy-MM-dd） */
  validUntil?: string | null;
  status: SupplyOrderStatus;
  remark?: string | null;
  /** 已消课课时（服务端聚合，非持久化字段） */
  consumedLessons?: number;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建供应单（对应后端 CreateSupplyRequest；tenant 由后端强制取请求租户，amount 由后端计算） */
export interface CreateSupplyOrderRequest {
  partnerCustomerId?: number;
  partnerName?: string;
  courseId?: number;
  courseName?: string;
  lessonCount: number;
  unitPrice: number;
  validUntil?: string;
  remark?: string;
}


/** 供应单状态 → 中文/颜色 映射 */
export const SUPPLY_STATUS_META: SUPPLY_STATUS_META_Table = {
  ACTIVE: { text: "有效", color: "blue" },
  COMPLETED: { text: "已完成", color: "green" },
  CANCELLED: { text: "已取消", color: "red" },
};


// ---------- 消课明细 ----------

export interface ConsumptionRecord {
  id: number;
  tenantId: number;
  /** 所属供应单（逻辑 ref -> edu.supply_orders.id） */
  supplyOrderId: number;
  /** 来源派遣单（可选，逻辑 ref -> edu.dispatch_records.id） */
  dispatchId?: number | null;
  partnerCustomerId?: number | null;
  partnerName?: string | null;
  courseId?: number | null;
  courseName?: string | null;
  /** 单课时价快照（创建时从供应单取，结算核销依据） */
  unitPrice: number;
  /** 消课日期（yyyy-MM-dd，结算周期归属依据） */
  consumedAt: string;
  /** 本次消课课时 */
  lessonCount: number;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建消课（对应后端 CreateConsumptionRequest；快照字段由后端从供应单取） */
export interface CreateConsumptionRequest {
  supplyOrderId: number;
  dispatchId?: number;
  consumedAt: string;
  lessonCount: number;
  remark?: string;
}


// ---------- 结算单 ----------

export type SettlementStatus = "PENDING" | "APPROVED" | "REJECTED";


export interface Settlement {
  id: number;
  tenantId: number;
  partnerCustomerId?: number | null;
  partnerName?: string | null;
  /** 结算周期开始（含，yyyy-MM-dd） */
  periodStart: string;
  /** 结算周期结束（含，yyyy-MM-dd） */
  periodEnd: string;
  /** 采购应付（周期内非取消供应单金额和） */
  purchasedAmount: number;
  /** 消耗核销课时数 */
  consumedLessons: number;
  /** 消耗核销金额（Σ 课时 × 单课时价） */
  consumedAmount: number;
  /** 应结金额 = purchased_amount − consumed_amount */
  settleAmount: number;
  /** 智野分成比例快照（%，0-100，空=未约定） */
  revenueShare?: number | null;
  /** 分成金额 = settle_amount × revenue_share ÷ 100（服务端计算） */
  shareAmount: number;
  status: SettlementStatus;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建结算单（对应后端 CreateSettlementRequest；金额字段由后端聚合，请求体不允许出现） */
export interface CreateSettlementRequest {
  partnerCustomerId?: number;
  partnerName?: string;
  periodStart: string;
  periodEnd: string;
  /** 智野分成比例（%，0-100，可空；快照进结算单，share_amount 服务端计算） */
  revenueShare?: number;
  remark?: string;
}


/** 结算单状态 → 中文/颜色 映射 */
export const SETTLEMENT_STATUS_META: SETTLEMENT_STATUS_META_Table = {
  PENDING: { text: "待审批", color: "gold" },
  APPROVED: { text: "已通过", color: "green" },
  REJECTED: { text: "已驳回", color: "red" },
};


/** 金额格式化（元，千分位 + 两位小数，如 3,072.00） */
export function formatMoney(value?: number | null): string {
  if (value === null || value === undefined) return "—";
  return value.toLocaleString("zh-CN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}


// ---------- 结算周期可配置化（CRM customers.settle_cycle 驱动） ----------

/** 合作伙伴结算周期（CRM V4 扩展字段 settle_cycle 的可选值：月 / 季 / 学期） */
export type SettleCycle = "月" | "季" | "学期";

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface SUPPLY_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface SUPPLY_STATUS_META_Table {
  ACTIVE: SUPPLY_STATUS_META_Item;
  COMPLETED: SUPPLY_STATUS_META_Item;
  CANCELLED: SUPPLY_STATUS_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface SETTLEMENT_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface SETTLEMENT_STATUS_META_Table {
  PENDING: SETTLEMENT_STATUS_META_Item;
  APPROVED: SETTLEMENT_STATUS_META_Item;
  REJECTED: SETTLEMENT_STATUS_META_Item;
}
