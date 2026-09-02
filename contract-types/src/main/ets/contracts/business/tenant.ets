/**
 * Tenant 类型（与 user-service Tenant 实体对齐 · Phase 8 多租户）.
 */

export type TenantStatus = "ACTIVE" | "DISABLED";


export interface Tenant {
  id: number;
  name: string;
  code: string;
  status: TenantStatus;
  /** 版别（ADR-0035）：GENERIC / LAYER / ZHIYE / JMZZ */
  edition?: string;
  createdAt: string;
  updatedAt?: string;
}


/** 开通租户（对应后端 CreateTenantRequest） */
export interface CreateTenantRequest {
  name: string;
  code: string;
}


/** 更新租户（对应后端 UpdateTenantRequest；name/status 可选） */
export interface UpdateTenantRequest {
  name?: string;
  status?: TenantStatus;
}


/** 租户自助开通请求（公开端点 POST /api/tenants/register · issue #24） */
export interface RegisterTenantRequest {
  tenantName: string;
  tenantCode: string;
  username: string;
  displayName: string;
  password: string;
  email?: string;
}


/** 租户自助开通结果（登录页预填租户编码 + 用户名） */
export interface RegisterTenantResult {
  tenant: Tenant;
  adminUsername: string;
  adminDisplayName: string;
}


/** 状态 → 中文/颜色 映射 */
export const TENANT_STATUS_META: TENANT_STATUS_META_Table = {
  ACTIVE: { text: "启用", color: "green" },
  DISABLED: { text: "停用", color: "default" },
};


/** 邀请码（ADR-0023 Phase 2） */
export interface TenantInvite {
  id: number;
  tenantId: number;
  code: string;
  role: "USER" | "ADMIN";
  expiresAt?: string | null;
  maxUses?: number | null;
  usedCount: number;
  createdAt: string;
  revokedAt?: string | null;
}


/** 生成邀请码请求 */
export interface CreateInviteRequest {
  role?: "USER" | "ADMIN";
  expiresInDays?: number;
  maxUses?: number;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface TENANT_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface TENANT_STATUS_META_Table {
  ACTIVE: TENANT_STATUS_META_Item;
  DISABLED: TENANT_STATUS_META_Item;
}
