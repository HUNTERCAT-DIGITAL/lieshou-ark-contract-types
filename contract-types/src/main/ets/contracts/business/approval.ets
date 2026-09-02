/**
 * 审批流类型（approval-service · ADR-0032）.
 * 与后端 ApprovalRequest 实体对齐（ADR-0025 强制租户模式）。
 */

export type ApprovalType = "EXPENSE" | "PURCHASE" | "SALE" | "OTHER";


export type ApprovalStatus = "PENDING" | "APPROVED" | "REJECTED" | "CANCELLED";


export interface ApprovalRequest {
  id: number;
  tenantId: number;
  type: ApprovalType;
  title: string;
  amount?: number | null;
  detail?: string | null;
  requesterId: number;
  approverId: number;
  status: ApprovalStatus;
  comment?: string | null;
  decidedBy?: number | null;
  decidedAt?: string | null;
  createdAt: string;
  updatedAt?: string | null;
}


/** 发起审批 */
export interface CreateApprovalRequest {
  type: ApprovalType;
  title: string;
  amount?: number;
  detail?: string;
  approverId: number;
}


/** 审批/撤销意见 */
export interface DecideRequest {
  comment?: string;
}


/** 待办计数 */
export interface ApprovalCounts {
  inbox: number;
  mine: number;
}


/** 类型 → 中文/颜色 */
export const APPROVAL_TYPE_META: APPROVAL_TYPE_META_Table = {
  EXPENSE: { text: "支出报销", color: "volcano" },
  PURCHASE: { text: "采购", color: "blue" },
  SALE: { text: "销售出库", color: "green" },
  OTHER: { text: "其他", color: "default" },
};


/** 状态 → 中文/颜色 */
export const APPROVAL_STATUS_META: APPROVAL_STATUS_META_Table = {
  PENDING: { text: "待审批", color: "processing" },
  APPROVED: { text: "已通过", color: "success" },
  REJECTED: { text: "已驳回", color: "error" },
  CANCELLED: { text: "已撤销", color: "default" },
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface APPROVAL_TYPE_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface APPROVAL_TYPE_META_Table {
  EXPENSE: APPROVAL_TYPE_META_Item;
  PURCHASE: APPROVAL_TYPE_META_Item;
  SALE: APPROVAL_TYPE_META_Item;
  OTHER: APPROVAL_TYPE_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface APPROVAL_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface APPROVAL_STATUS_META_Table {
  PENDING: APPROVAL_STATUS_META_Item;
  APPROVED: APPROVAL_STATUS_META_Item;
  REJECTED: APPROVAL_STATUS_META_Item;
  CANCELLED: APPROVAL_STATUS_META_Item;
}
