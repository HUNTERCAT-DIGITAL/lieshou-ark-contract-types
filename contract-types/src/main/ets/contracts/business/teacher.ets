/**
 * Teacher 类型（与 edu-service Teacher 实体对齐 · zhiye 教育行业版师资档案）.
 *
 * 安全约定：身份证 idCard 只写不读（后端 WRITE_ONLY），响应只含脱敏串 idCardMasked；
 * isDeleted 后端 @JsonIgnore 不下发；此处不声明。
 */

export type TeacherStatus = "AVAILABLE" | "DISPATCHING" | "DISABLED";


export interface Teacher {
  id: number;
  /** 归属租户（强制取 JWT tid，请求体不允许指定） */
  tenantId: number;
  name: string;
  gender?: string | null;
  phone?: string | null;
  email?: string | null;
  /** 授课方向（机器人编程 / 少儿编程 / 科学实验 / 创客教育） */
  subject?: string | null;
  /** 教资证号 */
  licenseNo?: string | null;
  /** 资质证书附件（core.file fileId，非 URL；预览/下载走强制鉴权 blob 通道） */
  certAttach?: string | null;
  /** 身份证脱敏展示（只读，如 360***********1234） */
  idCardMasked?: string | null;
  /** 每周可授课时数（派遣产能） */
  weeklyCap?: number | null;
  status: TeacherStatus;
  remark?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


/** 新建师资（对应后端 CreateTeacherRequest；tenant 由后端强制取请求租户） */
export interface CreateTeacherRequest {
  name: string;
  gender?: string;
  phone?: string;
  email?: string;
  subject?: string;
  licenseNo?: string;
  /** 资质证书附件 fileId（core.file 上传后返回；空串 = 清除） */
  certAttach?: string;
  /** 身份证号（明文传入，后端加密存储 · 只写） */
  idCard?: string;
  weeklyCap?: number;
  status?: TeacherStatus;
  remark?: string;
}


/** 编辑师资（对应后端 UpdateTeacherRequest；字段传入才更新） */
export interface UpdateTeacherRequest {
  name?: string;
  gender?: string;
  phone?: string;
  email?: string;
  subject?: string;
  licenseNo?: string;
  /** 资质证书附件 fileId（core.file 上传后返回；空串 = 清除） */
  certAttach?: string;
  idCard?: string;
  weeklyCap?: number;
  status?: TeacherStatus;
  remark?: string;
}


/** 合作状态 → 中文/颜色 映射（UI 共用） */
export const STATUS_META: STATUS_META_Table = {
  AVAILABLE: { text: "可用", color: "green" },
  DISPATCHING: { text: "派遣中", color: "gold" },
  DISABLED: { text: "停用", color: "red" },
};


/** 授课方向选项（与后端 subject 自由文本对齐，前端提供常用枚举） */
export const SUBJECT_OPTIONS = ["机器人编程", "少儿编程", "科学实验", "创客教育"];

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface STATUS_META_Table {
  AVAILABLE: STATUS_META_Item;
  DISPATCHING: STATUS_META_Item;
  DISABLED: STATUS_META_Item;
}
