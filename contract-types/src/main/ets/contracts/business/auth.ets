/**
 * Auth 类型 (Phase 5 · JWT 鉴权闭环).
 * 与后端 cn.huntercat.lieshoucloudpro.auth.web.dto.AuthDtos 对齐.
 */

export interface LoginRequest {
  /** 租户编码（可选，默认 jxlkas · ADR-0022） */
  tenantCode?: string;
  username: string;
  password: string;
}


export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number; // seconds
  tokenType: "Bearer";
  userId: number;
  username: string;
  /** 租户编码（登录响应 · ADR-0035） */
  tenantCode?: string;
  /** 租户显示名 */
  tenantName?: string;
  /** 租户版别：GENERIC | LAYER | ZHIYE | JMZZ（登录响应 · ADR-0035） */
  tenantEdition?: string;
  /** 首次登录需激活（管理员建用户未设密码 · 2026-08；true → 前端引导设置密码） */
  activationRequired?: boolean;
  /**
   * 该用户名可登录的合法租户（账号存在且 ACTIVE；登录后切换租户用 · 2026-08）
   */
  availableTenants?: TenantOption[];
}


/** 登录/切换后可选租户（先登录后选租户） */
export interface TenantOption {
  tenantId: number;
  tenantCode: string;
  tenantName: string;
  tenantEdition?: string | null;
}


export interface CurrentUser {
  userId: number;
  tenantId?: number;
  tenantCode?: string;
  tenantName?: string;
  tenantEdition?: string;
  username: string;
  /** 头像 URL（个人中心/顶栏展示 · 2026-09） */
  avatarUrl?: string | null;
  roles: string[];
  /** 权限码（ADR-0024 Phase 2 · 菜单可见性与接口鉴权共用数据源） */
  permissions?: string[];
}


/** 鉴权 store 状态 */
export interface AuthState {
  accessToken: string | null;
  refreshToken: string | null;
  user: CurrentUser | null;
  isAuthenticated: boolean;
}
