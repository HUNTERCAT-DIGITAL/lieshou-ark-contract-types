/**
 * 组织架构契约（project-services /api/orgs · ADR-0025 强制租户模式）.
 *
 * 组织树组件上平台（P-2）的类型基座：子公司/部门两级组织 + 人员统计 + 用户归属。
 * 投资属性（equityRatio/registeredCapital/legalPerson/profile）为被投企业档案字段，
 * 非投资场景可忽略（可选字段）。
 */

/** 组织类型：子公司（一级） / 部门（二级） */
export type OrgType = "COMPANY" | "DEPARTMENT";


/** 组织状态 */
export type OrgStatus = "ACTIVE" | "DISABLED";


/** 组织节点（子公司/部门） */
export interface Organization {
  id: number;
  code: string;
  name: string;
  type: OrgType;
  parentId?: number;
  city?: string;
  status: OrgStatus;
  /** 被投企业档案 · 仅子公司（R1.2） */
  equityRatio?: number;
  registeredCapital?: number;
  legalPerson?: string;
  profile?: string;
}


/** 组织创建入参 */
export interface CreateOrgInput {
  code: string;
  name: string;
  type: OrgType;
  parentId?: number;
  city?: string;
  equityRatio?: number;
  registeredCapital?: number;
  legalPerson?: string;
  profile?: string;
}


/** 组织更新入参（档案编辑） */
export interface UpdateOrgInput {
  code: string;
  name: string;
  type: OrgType;
  city?: string;
  equityRatio?: number;
  registeredCapital?: number;
  legalPerson?: string;
  profile?: string;
}


/** 人员统计（按组织分组：总数/试用/在职/转出/离职 · /api/employees/stats） */
export interface OrgStaffStats {
  orgId: number;
  total: number;
  probation: number;
  active: number;
  transferred: number;
  resigned: number;
}


/** 当前用户所属组织（/api/orgs/user-org/me · 数据隔离） */
export interface UserOrgInfo {
  userId: number | null;
  orgId: number | null;
  orgName: string | null;
}
