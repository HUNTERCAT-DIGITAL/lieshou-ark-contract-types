/**
 * User 类型（与 user-service User 实体对齐，Phase 7 · 用户管理 CRUD）.
 *
 * passwordHash 后端 WRITE_ONLY 绝不下发；此处不声明。
 */

export type UserStatus = "ACTIVE" | "DISABLED" | "LOCKED";


export interface User {
  id: number;
  /** 归属租户（多租户 · ADR-0022） */
  tenantId: number;
  username: string;
  displayName: string;
  email?: string | null;
  phone?: string | null;
  /** 头像 URL（上传文件或默认头像 · 2026-09） */
  avatarUrl?: string | null;
  status: UserStatus;
  roles: string[];
  createdAt: string;
  updatedAt?: string;
  lastLoginAt?: string | null;
}


/** 新建用户（对应后端 CreateUserRequest） */
export interface CreateUserRequest {
  username: string;
  displayName: string;
  /** 密码可选（2026-08：管理员建用户可不设密码，首次登录用验证码激活设置） */
  password?: string;
  email?: string;
  phone?: string;
}


/** 编辑用户（对应后端 UpdateUserRequest；password 传入才改） */
export interface UpdateUserRequest {
  displayName: string;
  email?: string;
  phone?: string;
  status: UserStatus;
  roles: string[];
  password?: string;
}


/** 状态 → 中文/颜色 映射（UI 共用） */
export const STATUS_META: STATUS_META_Table = {
  ACTIVE: { text: "启用", color: "green" },
  DISABLED: { text: "停用", color: "default" },
  LOCKED: { text: "锁定", color: "orange" },
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Table {
  ACTIVE: STATUS_META_Item;
  DISABLED: STATUS_META_Item;
  LOCKED: STATUS_META_Item;
}
