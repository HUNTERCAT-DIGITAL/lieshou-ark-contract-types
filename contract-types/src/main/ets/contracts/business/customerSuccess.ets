/**
 * 客户成功中心类型（与 crm-service CustomerSuccessController 对齐 · ADR-0025 租户模式）.
 *
 * 售后闭环：联系函（主动触达）+ 客户响应（响应深化）。isDeleted 后端 @JsonIgnore 不下发，此处不声明。
 */

// ============================================================
// 联系函
// ============================================================

export type LetterType = "RENEWAL" | "SERVICE_NOTICE" | "VISIT_INVITE" | "FEEDBACK" | "OTHER";


export type LetterStatus = "DRAFT" | "SENT" | "READ" | "COMPLETED" | "CANCELLED";


export interface ContactLetter {
  id: number;
  tenantId: number;
  /** 收函客户（customers.id） */
  customerId: number;
  type: LetterType;
  title: string;
  content?: string | null;
  status: LetterStatus;
  sentAt?: string | null;
  readAt?: string | null;
  completedAt?: string | null;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


export interface CreateLetterRequest {
  customerId: number;
  type: LetterType;
  title: string;
  content?: string;
}


export interface UpdateLetterRequest {
  title?: string;
  content?: string;
}


/** 联系函类型 → 中文/颜色（UI 共用） */
export const LETTER_TYPE_META: LETTER_TYPE_META_Table = {
  RENEWAL: { text: "续费提醒", color: "orange" },
  SERVICE_NOTICE: { text: "服务通知", color: "blue" },
  VISIT_INVITE: { text: "回访邀请", color: "cyan" },
  FEEDBACK: { text: "满意度调查", color: "purple" },
  OTHER: { text: "其他函件", color: "default" },
};


/** 联系函状态 → 中文/颜色（UI 共用） */
export const LETTER_STATUS_META: LETTER_STATUS_META_Table = {
  DRAFT: { text: "草稿", color: "default" },
  SENT: { text: "已发送", color: "blue" },
  READ: { text: "客户已读", color: "cyan" },
  COMPLETED: { text: "已闭环", color: "green" },
  CANCELLED: { text: "已取消", color: "red" },
};


// ============================================================
// 联系函模板（预置 · 系统级）
// ============================================================

/** 联系函模板（后端 /api/letter-templates · 系统预置 tenantId=0 只读 + 租户自定义 CRUD） */
export interface LetterTemplate {
  id: number;
  /** 归属租户；tenantId === 0 为系统预置（只读不可改删） */
  tenantId: number;
  /** 模板键（租户内唯一） */
  templateKey: string;
  type: LetterType;
  title: string;
  /** 模板正文（可含 {customer} 占位符） */
  content: string;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


export interface CreateTemplateRequest {
  templateKey: string;
  type: LetterType;
  title: string;
  content: string;
}


export interface UpdateTemplateRequest {
  type?: LetterType;
  title?: string;
  content?: string;
}


/** 模板来源：系统预置（只读） / 租户自定义 */
export function isSystemTemplate(t: isSystemTemplate_Expanded): boolean {
  return t.tenantId === 0;
}


/** 模板 key → 中文名（系统预置展示；租户自定义直接展示 title） */
export const LETTER_TEMPLATE_LABELS: LETTER_TEMPLATE_LABELS_Table = {
  "renewal-reminder": "续费提醒函",
  "service-notice": "服务变更通知函",
  "visit-invite": "客户回访邀请函",
  "satisfaction-survey": "客户满意度调查函",
};


/** 把模板正文中的 {customer} 占位符替换为客户名（未选客户时保留占位） */
export function fillTemplatePlaceholder(text: string, customerName?: string): string {
  if (!customerName) return text;
  return text.replace(/\{customer\}/g, customerName);
}


// ============================================================
// 客户响应（响应深化）
// ============================================================

export type ResponseType = "PHONE" | "EMAIL" | "VISIT" | "WECHAT" | "LETTER" | "OTHER";


export type ResponseSentiment = "POSITIVE" | "NEUTRAL" | "NEGATIVE";


export type ResponseStatus = "OPEN" | "IN_PROGRESS" | "RESOLVED";


export interface CustomerResponse {
  id: number;
  tenantId: number;
  customerId: number;
  /** 关联联系函（contact_letters.id；空 = 主动回访/其他响应） */
  letterId?: number | null;
  type: ResponseType;
  sentiment: ResponseSentiment;
  content: string;
  /** 下一步动作（响应深化） */
  followUpAction?: string | null;
  followUpAt?: string | null;
  status: ResponseStatus;
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


export interface CreateResponseRequest {
  customerId: number;
  letterId?: number;
  type: ResponseType;
  sentiment: ResponseSentiment;
  content: string;
  followUpAction?: string;
  followUpAt?: string;
}


export interface UpdateResponseRequest {
  type?: ResponseType;
  sentiment?: ResponseSentiment;
  content?: string;
  followUpAction?: string;
  followUpAt?: string;
  status?: ResponseStatus;
}


/** 响应方式 → 中文（UI 共用） */
export const RESPONSE_TYPE_META: RESPONSE_TYPE_META_Table = {
  PHONE: "电话",
  EMAIL: "邮件",
  VISIT: "上门",
  WECHAT: "微信",
  LETTER: "函件回复",
  OTHER: "其他",
};


/** 响应情绪 → 中文/颜色（UI 共用） */
export const SENTIMENT_META: SENTIMENT_META_Table = {
  POSITIVE: { text: "积极", color: "green" },
  NEUTRAL: { text: "中性", color: "blue" },
  NEGATIVE: { text: "消极", color: "red" },
};


/** 响应状态 → 中文/颜色（UI 共用） */
export const RESPONSE_STATUS_META: RESPONSE_STATUS_META_Table = {
  OPEN: { text: "待跟进", color: "orange" },
  IN_PROGRESS: { text: "处理中", color: "blue" },
  RESOLVED: { text: "已闭环", color: "green" },
};


// ============================================================
// 工作台汇总
// ============================================================

export interface CustomerSuccessSummary {
  totalLetters: number;
  /** 待发送（草稿） */
  draftLetters: number;
  /** 已发送未闭环（SENT + READ） */
  sentLetters: number;
  completedLetters: number;
  totalResponses: number;
  /** 待跟进响应（OPEN + IN_PROGRESS） */
  openResponses: number;
  resolvedResponses: number;
  /** 消极响应（需优先跟进） */
  negativeResponses: number;
  /** 近 7 天响应活跃度 */
  weekResponses: number;
  /** 跟进到期提醒：已逾期未闭环响应数 */
  followUpOverdue: number;
  /** 跟进到期提醒：今日到期未闭环响应数 */
  followUpDueToday: number;
}


/** 响应跟进状态筛选（前端 UI 层 · 透传 followUpOverdue / followUpDueToday） */
export type FollowUpFilter = "all" | "overdue" | "dueToday";


/** 跟进状态 → 中文/颜色（UI 共用） */
export const FOLLOW_UP_FILTER_META: FOLLOW_UP_FILTER_META_Table = {
  all: { text: "全部", color: "default" },
  overdue: { text: "已逾期", color: "red" },
  dueToday: { text: "今日到期", color: "orange" },
};


/**
 * 判断响应跟进是否逾期/今日到期（供列表标记 + 筛选）。
 * 已闭环（RESOLVED）或无 followUpAt 不算提醒。
 */
export function followUpTone(
  followUpAt: string | null | undefined,
  status: ResponseStatus,
  now: Date = new Date(),
): followUpTone_Item {
  if (status === "RESOLVED" || !followUpAt) return { tone: "none" };
  const at = new Date(followUpAt).getTime();
  const day = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const nextDay = day.getTime() + 24 * 60 * 60 * 1000;
  if (at < day.getTime()) return { tone: "overdue" };
  if (at < nextDay) return { tone: "dueToday" };
  return { tone: "none" };
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LETTER_TYPE_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LETTER_TYPE_META_Table {
  RENEWAL: LETTER_TYPE_META_Item;
  SERVICE_NOTICE: LETTER_TYPE_META_Item;
  VISIT_INVITE: LETTER_TYPE_META_Item;
  FEEDBACK: LETTER_TYPE_META_Item;
  OTHER: LETTER_TYPE_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LETTER_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LETTER_STATUS_META_Table {
  DRAFT: LETTER_STATUS_META_Item;
  SENT: LETTER_STATUS_META_Item;
  READ: LETTER_STATUS_META_Item;
  COMPLETED: LETTER_STATUS_META_Item;
  CANCELLED: LETTER_STATUS_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface isSystemTemplate_Expanded {

  /** 归属租户；tenantId === 0 为系统预置（只读不可改删） */
  tenantId: number;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface LETTER_TEMPLATE_LABELS_Table {
  "renewal-reminder": string;
  "service-notice": string;
  "visit-invite": string;
  "satisfaction-survey": string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface RESPONSE_TYPE_META_Table {
  PHONE: string;
  EMAIL: string;
  VISIT: string;
  WECHAT: string;
  LETTER: string;
  OTHER: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface SENTIMENT_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface SENTIMENT_META_Table {
  POSITIVE: SENTIMENT_META_Item;
  NEUTRAL: SENTIMENT_META_Item;
  NEGATIVE: SENTIMENT_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface RESPONSE_STATUS_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface RESPONSE_STATUS_META_Table {
  OPEN: RESPONSE_STATUS_META_Item;
  IN_PROGRESS: RESPONSE_STATUS_META_Item;
  RESOLVED: RESPONSE_STATUS_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface FOLLOW_UP_FILTER_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface FOLLOW_UP_FILTER_META_Table {
  all: FOLLOW_UP_FILTER_META_Item;
  overdue: FOLLOW_UP_FILTER_META_Item;
  dueToday: FOLLOW_UP_FILTER_META_Item;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface followUpTone_Item {
 tone: "overdue" | "dueToday" | "none"
}
