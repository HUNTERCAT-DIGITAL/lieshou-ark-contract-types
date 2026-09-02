/**
 * 菜单数据驱动类型（ADR-0024 Phase 2 阶段 4 · 平台基础层）.
 *
 * 对应后端 GET /api/users/me/menus 返回的菜单树：
 * 默认清单 ⊕ 租户覆盖 ⊕ 权限过滤 → 已排序树；icon 为字符串 key（前端 ICON_MAP 映射）。
 */

/** 菜单节点（后端返回） */
export interface MenuNode {
  /** 菜单 key（租户覆盖表主键维度，如 legal / today） */
  key: string;
  /** 前端路由路径（必须在前端已注册路由，否则点击 404） */
  path: string;
  name: string;
  /** 图标字符串 key（ICON_MAP 映射为 ReactNode） */
  icon: string;
  /** 所需权限码（后端已过滤，冗余返回供前端校验） */
  accessKey?: string | null;
  /** 排序（越小越靠前） */
  sort: number;
  children: MenuNode[];
}
