/**
 * DispatchRecord 类型（与 edu-service DispatchRecord 实体对齐 · zhiye 教育行业版师资派遣排期）.
 *
 * 业务语义：智野把师资按排期派遣到合作伙伴的课程时段（设计文档 §3.4 派遣单）。
 * teacher_id / partner_customer_id / course_id 为跨服务逻辑引用（无 FK），展示用名称快照
 * （teacher_name 由服务端取师资档案，partner_name / course_name 创建时由调用方传入）。
 * isDeleted 后端 @JsonIgnore 不下发；此处不声明。
 */

export type DispatchStatus = "DISPATCHED" | "COMPLETED" | "CANCELLED";


export interface DispatchRecord {
  id: number;
  /** 归属租户（强制取 JWT tid，请求体不允许指定） */
  tenantId: number;
  /** 派遣师资（逻辑 ref -> edu.teachers.id） */
  teacherId: number;
  /** 师资名快照（服务端写入） */
  teacherName: string;
  /** 合作伙伴（逻辑 ref -> crm.customers.id） */
  partnerCustomerId?: number | null;
  /** 合作伙伴名快照 */
  partnerName?: string | null;
  /** 课程产品（逻辑 ref -> inventory.products.id） */
  courseId?: number | null;
  /** 课程名快照 */
  courseName?: string | null;
  /** 派遣时段开始（ISO-8601） */
  slotStart: string;
  /** 派遣时段结束（ISO-8601） */
  slotEnd: string;
  /** 本次派遣课时数 */
  lessonCount: number;
  status: DispatchStatus;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建派遣（对应后端 CreateDispatchRequest；tenant 由后端强制取请求租户，teacher_name 由后端取师资档案） */
export interface CreateDispatchRequest {
  teacherId: number;
  partnerCustomerId?: number;
  partnerName?: string;
  courseId?: number;
  courseName?: string;
  slotStart: string;
  slotEnd: string;
  lessonCount?: number;
  remark?: string;
}


/** 派遣状态 → 中文/颜色 映射（UI 共用） */
export const STATUS_META: STATUS_META_Table = {
  DISPATCHED: { text: "派遣中", color: "gold" },
  COMPLETED: { text: "已完成", color: "green" },
  CANCELLED: { text: "已取消", color: "red" },
};


/** 派遣时段格式化（起止 ISO → 本地短时间，如 09:00 - 11:00） */
export function formatSlot(start: string, end: string): string {
  const s = new Date(start);
  const e = new Date(end);
  if (Number.isNaN(s.getTime()) || Number.isNaN(e.getTime())) return `${start} ~ ${end}`;
  const fmt = (d: Date) =>
    `${d.getMonth() + 1}月${d.getDate()}日 ${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(
      2,
      "0",
    )}`;
  return `${fmt(s)} - ${fmt(e)}`;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Table {
  DISPATCHED: STATUS_META_Item;
  COMPLETED: STATUS_META_Item;
  CANCELLED: STATUS_META_Item;
}
