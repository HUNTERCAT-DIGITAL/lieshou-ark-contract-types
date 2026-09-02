/**
 * Contract 类型（与 crm-service Contract 实体对齐 · V5 补齐）.
 *
 * isDeleted 后端 @JsonIgnore 不下发；此处不声明。
 */

export type ContractStatus = "DRAFT" | "ACTIVE" | "EXPIRED" | "TERMINATED";


export const CONTRACT_STATUS_META: CONTRACT_STATUS_META_Table = {
  DRAFT: { text: "草稿", color: "default" },
  ACTIVE: { text: "生效", color: "green" },
  EXPIRED: { text: "已到期", color: "orange" },
  TERMINATED: { text: "已终止", color: "red" },
};


export interface Contract {
  id: number;
  /** 归属租户（强制取 JWT tid，请求体不允许指定） */
  tenantId: number;
  /** 所属客户（customers.id） */
  customerId: number;
  /** 合同编号（租户内唯一） */
  contractNo: string;
  title: string;
  /** 合同金额（元） */
  amount?: number | null;
  /** 签约日期 */
  signedAt?: string | null;
  /** 生效起始日期 */
  startDate?: string | null;
  /** 生效截止日期 */
  endDate?: string | null;
  status: ContractStatus;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建合同（对应后端 CreateContractRequest；tenant 由后端强制取请求租户） */
export interface CreateContractRequest {
  customerId: number;
  contractNo: string;
  title: string;
  amount?: number;
  signedAt?: string;
  startDate?: string;
  endDate?: string;
  status?: ContractStatus;
  remark?: string;
}


/** 编辑合同（对应后端 UpdateContractRequest；字段传入才更新） */
export interface UpdateContractRequest {
  customerId?: number;
  contractNo?: string;
  title?: string;
  amount?: number;
  signedAt?: string;
  startDate?: string;
  endDate?: string;
  status?: ContractStatus;
  remark?: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface CONTRACT_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface CONTRACT_STATUS_META_Table {
  DRAFT: CONTRACT_STATUS_META_Item;
  ACTIVE: CONTRACT_STATUS_META_Item;
  EXPIRED: CONTRACT_STATUS_META_Item;
  TERMINATED: CONTRACT_STATUS_META_Item;
}
