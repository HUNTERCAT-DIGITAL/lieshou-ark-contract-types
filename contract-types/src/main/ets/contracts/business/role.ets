/**
 * Role 类型（RBAC · ADR-0024）.
 */

export type RoleScope = "PLATFORM" | "TENANT";


export interface Role {
  id: number;
  code: string;
  name: string;
  scope: RoleScope;
  description?: string | null;
  system: boolean;
  createdAt: string;
  updatedAt?: string;
}


/** 创建角色 */
export interface CreateRoleRequest {
  code: string;
  name: string;
  scope?: RoleScope;
  description?: string;
}


/** 更新角色 */
export interface UpdateRoleRequest {
  name?: string;
  scope?: RoleScope;
  description?: string;
}


export const ROLE_SCOPE_META: ROLE_SCOPE_META_Table = {
  PLATFORM: { text: "平台", color: "purple" },
  TENANT: { text: "租户", color: "blue" },
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface ROLE_SCOPE_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface ROLE_SCOPE_META_Table {
  PLATFORM: ROLE_SCOPE_META_Item;
  TENANT: ROLE_SCOPE_META_Item;
}
