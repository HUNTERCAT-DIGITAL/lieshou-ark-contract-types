/**
 * 财务记账类型（finance-service · Phase 9）.
 * 与后端 LedgerEntry 实体对齐（ADR-0025 强制租户模式）。
 */

export type LedgerType = "INCOME" | "EXPENSE";


export interface LedgerEntry {
  id: number;
  tenantId: number;
  type: LedgerType;
  amount: number;
  category?: string | null;
  occurredAt: string;
  remark?: string | null;
  /** 创建人（后端新增 · L4-3 契约对齐） */
  createdBy?: number | null;
  createdAt: string;
}


export interface LedgerSummary {
  income: number;
  expense: number;
  balance: number;
  count: number;
}


/** 月度收支行 */
export interface MonthlySummary {
  month: string; // YYYY-MM
  income: number;
  expense: number;
  balance: number;
}


/** 新建记账 */
export interface CreateLedgerRequest {
  type: LedgerType;
  amount: number;
  category?: string;
  occurredAt: string; // yyyy-MM-dd
  remark?: string;
}


/** 编辑记账（字段可选） */
export interface UpdateLedgerRequest {
  type?: LedgerType;
  amount?: number;
  category?: string;
  occurredAt?: string;
  remark?: string;
}


/** 类型 → 中文/颜色 */
export const LEDGER_TYPE_META: LEDGER_TYPE_META_Table = {
  INCOME: { text: "收入", color: "green" },
  EXPENSE: { text: "支出", color: "red" },
};


/** 常用分类（前端选择） */
export const LEDGER_CATEGORIES = ["销售收入", "服务收入", "房租", "工资", "采购", "税费", "办公", "其他"];

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LEDGER_TYPE_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LEDGER_TYPE_META_Table {
  INCOME: LEDGER_TYPE_META_Item;
  EXPENSE: LEDGER_TYPE_META_Item;
}
