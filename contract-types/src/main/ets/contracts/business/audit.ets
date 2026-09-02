/**
 * 审计日志类型（与 user-service AuditLog 实体对齐 · DATA_SECURITY §7 六要素）.
 */

export type AuditAction = "CREATE" | "UPDATE" | "DELETE" | "DENIED" | "LOGIN" | "READ";


export type AuditOutcome = "SUCCESS" | "DENIED" | "ERROR";


export interface AuditLog {
  id: number;
  /** 作用域租户（平台操作 = 操作者租户） */
  tenantId?: number | null;
  /** 操作者（who） */
  userId?: number | null;
  action: AuditAction;
  /** USER / TENANT / ROLE / ... */
  resourceType: string;
  resourceId?: number | null;
  detail?: string | null;
  sourceIp?: string | null;
  userAgent?: string | null;
  outcome: AuditOutcome;
  requestId?: string | null;
  createdAt: string;
}


export const AUDIT_ACTION_TEXT: AUDIT_ACTION_TEXT_Table = {
  CREATE: "创建",
  UPDATE: "更新",
  DELETE: "删除",
  DENIED: "拒绝",
  LOGIN: "登录",
  READ: "读取",
};


export const AUDIT_OUTCOME_TEXT: AUDIT_OUTCOME_TEXT_Table = {
  SUCCESS: "成功",
  DENIED: "拒绝",
  ERROR: "失败",
};


export const AUDIT_RESOURCE_TEXT: AUDIT_RESOURCE_TEXT_Table = {
  USER: "用户",
  TENANT: "租户",
  ROLE: "角色",
  CUSTOMER: "客户",
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface AUDIT_ACTION_TEXT_Table {
  CREATE: string;
  UPDATE: string;
  DELETE: string;
  DENIED: string;
  LOGIN: string;
  READ: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface AUDIT_OUTCOME_TEXT_Table {
  SUCCESS: string;
  DENIED: string;
  ERROR: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface AUDIT_RESOURCE_TEXT_Table {
  USER: string;
  TENANT: string;
  ROLE: string;
  CUSTOMER: string;
}
