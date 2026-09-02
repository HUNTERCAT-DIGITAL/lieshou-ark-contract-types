/**
 * Customer 类型（与 crm-service Customer 实体对齐 · 首个租户内业务模块 ADR-0025）.
 *
 * isDeleted 后端 @JsonIgnore 不下发；此处不声明。
 */

export type CustomerStatus = "NEW" | "FOLLOWING" | "CONVERTED" | "LOST";


export interface Customer {
  id: number;
  /** 归属租户（强制取 JWT tid，请求体不允许指定） */
  tenantId: number;
  name: string;
  contactName?: string | null;
  contactPhone?: string | null;
  email?: string | null;
  address?: string | null;
  status: CustomerStatus;
  ownerId?: number | null;
  remark?: string | null;
  /** 教育版（zhiye · 合作伙伴）扩展字段（Phase 1） */
  licenseNo?: string | null;
  licenseAttach?: string | null;
  region?: string | null;
  contractPeriod?: string | null;
  settleCycle?: string | null;
  /** 智野分成比例（%，0-100） */
  revenueShare?: number | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建客户（对应后端 CreateCustomerRequest；tenant 由后端强制取请求租户） */
export interface CreateCustomerRequest {
  name: string;
  contactName?: string;
  contactPhone?: string;
  email?: string;
  address?: string;
  status?: CustomerStatus;
  ownerId?: number;
  remark?: string;
  /** 教育版（zhiye · 合作伙伴）扩展字段，全部可选 */
  licenseNo?: string;
  licenseAttach?: string;
  region?: string;
  contractPeriod?: string;
  settleCycle?: string;
  revenueShare?: number;
}


/** 编辑客户（对应后端 UpdateCustomerRequest；字段传入才更新） */
export interface UpdateCustomerRequest {
  name?: string;
  contactName?: string;
  contactPhone?: string;
  email?: string;
  address?: string;
  status?: CustomerStatus;
  ownerId?: number;
  remark?: string;
  /** 教育版（zhiye · 合作伙伴）扩展字段，全部可选 */
  licenseNo?: string;
  licenseAttach?: string;
  region?: string;
  contractPeriod?: string;
  settleCycle?: string;
  revenueShare?: number;
}


/** 跟进状态 → 中文/颜色 映射（UI 共用） */
export const STATUS_META: STATUS_META_Table = {
  NEW: { text: "新客户", color: "blue" },
  FOLLOWING: { text: "跟进中", color: "gold" },
  CONVERTED: { text: "已转化", color: "green" },
  LOST: { text: "已流失", color: "red" },
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Table {
  NEW: STATUS_META_Item;
  FOLLOWING: STATUS_META_Item;
  CONVERTED: STATUS_META_Item;
  LOST: STATUS_META_Item;
}
