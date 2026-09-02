/**
 * Contact 类型（与 crm-service Contact 实体对齐 · V5 补齐）.
 *
 * isDeleted 后端 @JsonIgnore 不下发；此处不声明。
 */

export interface Contact {
  id: number;
  /** 归属租户（强制取 JWT tid，请求体不允许指定） */
  tenantId: number;
  /** 所属客户（customers.id） */
  customerId: number;
  name: string;
  phone?: string | null;
  email?: string | null;
  position?: string | null;
  /** 是否主联系人 */
  primary: boolean;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建联系人（对应后端 CreateContactRequest；tenant 由后端强制取请求租户） */
export interface CreateContactRequest {
  customerId: number;
  name: string;
  phone?: string;
  email?: string;
  position?: string;
  primary?: boolean;
  remark?: string;
}


/** 编辑联系人（对应后端 UpdateContactRequest；字段传入才更新） */
export interface UpdateContactRequest {
  customerId?: number;
  name?: string;
  phone?: string;
  email?: string;
  position?: string;
  primary?: boolean;
  remark?: string;
}
