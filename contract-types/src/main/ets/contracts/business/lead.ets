/**
 * Lead 类型（与 crm-service Lead 实体对齐 · 线索池 / 公海 / 跟进）。
 *
 * 与 Customer 的业务差异：ownerId 为空 = 在线索池未认领；认领后超过 7 天无跟进由后端定时任务释放回池（公海）。
 * isDeleted 后端 @JsonIgnore 不下发。
 */

export type LeadStatus = "NEW" | "FOLLOWING" | "CONVERTED" | "LOST";

export type LeadSource = "MANUAL" | "IMPORT" | "CHANNEL" | "OTHER";

export type FollowUpType = "PHONE" | "VISIT" | "WECHAT" | "NOTE";


export interface Lead {
  id: number;
  /** 归属租户（强制取 JWT tid，请求体不允许指定） */
  tenantId: number;
  name: string;
  contactName?: string | null;
  contactPhone?: string | null;
  email?: string | null;
  source: LeadSource;
  status: LeadStatus;
  /** 认领人（NULL = 在线索池未认领） */
  ownerId?: number | null;
  lastFollowUpAt?: string | null;
  nextFollowUpAt?: string | null;
  /** 转化后关联的客户 id（CONVERTED 时非空） */
  convertedCustomerId?: number | null;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 线索跟进记录（时间线） */
export interface LeadFollowUp {
  id: number;
  leadId: number;
  userId?: number | null;
  type: FollowUpType;
  content: string;
  nextFollowUpAt?: string | null;
  createdAt: string;
}


/** 新建 / 编辑线索 */
export interface LeadRequest {
  name: string;
  contactName?: string;
  contactPhone?: string;
  email?: string;
  source?: LeadSource;
  remark?: string;
}


/** 新增跟进 */
export interface FollowUpRequest {
  type?: FollowUpType;
  content: string;
  nextFollowUpAt?: string;
}


/** 状态 → 中文/颜色（StatusTag 共用） */
export const LEAD_STATUS_META: LEAD_STATUS_META_Table = {
  NEW: { text: "新线索", color: "blue" },
  FOLLOWING: { text: "跟进中", color: "gold" },
  CONVERTED: { text: "已转化", color: "green" },
  LOST: { text: "已关闭", color: "red" },
};


/** 来源 → 中文 */
export const LEAD_SOURCE_META: LEAD_SOURCE_META_Table = {
  MANUAL: "手动录入",
  IMPORT: "批量导入",
  CHANNEL: "渠道",
  OTHER: "其他",
};


/** 跟进方式 → 中文 */
export const FOLLOW_UP_TYPE_META: FOLLOW_UP_TYPE_META_Table = {
  PHONE: "电话",
  VISIT: "拜访",
  WECHAT: "微信",
  NOTE: "备注",
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LEAD_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LEAD_STATUS_META_Table {
  NEW: LEAD_STATUS_META_Item;
  FOLLOWING: LEAD_STATUS_META_Item;
  CONVERTED: LEAD_STATUS_META_Item;
  LOST: LEAD_STATUS_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LEAD_SOURCE_META_Table {
  MANUAL: string;
  IMPORT: string;
  CHANNEL: string;
  OTHER: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface FOLLOW_UP_TYPE_META_Table {
  PHONE: string;
  VISIT: string;
  WECHAT: string;
  NOTE: string;
}
