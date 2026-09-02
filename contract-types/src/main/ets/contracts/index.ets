/**
 * ArkTS 契约聚合入口（生成器产出 · 勿手改）
 * 对应 lieshou-contract-types/src/index.ts
 * 跨模块同名符号（如 STATUS_META）只从首个模块导出；其余走深路径 business/<module>
 */
export interface ApiResponse<T> {

  data: T;

  success: boolean;

  message?: string;
}


/** 健康状态 / 跨端共享 */
export type HealthStatus = "up" | "down" | "degraded";


/**
 * 行业能力 ID（客户定制层与行业层解耦的公共契约 · 2026-09）.
 * 行业层（LieShouCloudPro-industry 包）提供能力；客户 Edition 声明启用哪些行业。
 */
export type IndustryId = "generic" | "edu" | "legal" | "iot";


/** 状态 → 中文文本 + antd Tag 颜色（共享给 ui 包的 StatusTag） */
export interface StatusMeta {
  text: string;
  color: string;
}


/** 安全查找：避免任何 key 不存在的运行时崩 */
export function getStatusMeta<T extends string>(meta: Record<T, StatusMeta>, key: T): StatusMeta {
  return meta[key];
}


/** antd Tag 可用颜色 */
export type RoleTagColor = string;

// -------- 业务 DTO（显式导出 · 冲突单来源）--------
export { ApprovalType, ApprovalStatus, ApprovalRequest, CreateApprovalRequest, DecideRequest, ApprovalCounts, APPROVAL_TYPE_META, APPROVAL_STATUS_META, APPROVAL_TYPE_META_Item, APPROVAL_TYPE_META_Table, APPROVAL_STATUS_META_Item, APPROVAL_STATUS_META_Table } from './business/approval.ets';
export { AuditAction, AuditOutcome, AuditLog, AUDIT_ACTION_TEXT, AUDIT_OUTCOME_TEXT, AUDIT_RESOURCE_TEXT, AUDIT_ACTION_TEXT_Table, AUDIT_OUTCOME_TEXT_Table, AUDIT_RESOURCE_TEXT_Table } from './business/audit.ets';
export { LoginRequest, TokenResponse, TenantOption, CurrentUser, AuthState } from './business/auth.ets';
export { Contact, CreateContactRequest, UpdateContactRequest } from './business/contact.ets';
export { ContractStatus, CONTRACT_STATUS_META, Contract, CreateContractRequest, UpdateContractRequest, CONTRACT_STATUS_META_Item, CONTRACT_STATUS_META_Table } from './business/contract.ets';
export { CustomerStatus, Customer, CreateCustomerRequest, UpdateCustomerRequest, STATUS_META, STATUS_META_Item, STATUS_META_Table } from './business/customer.ets';
export { LetterType, LetterStatus, ContactLetter, CreateLetterRequest, UpdateLetterRequest, LETTER_TYPE_META, LETTER_STATUS_META, LetterTemplate, CreateTemplateRequest, UpdateTemplateRequest, isSystemTemplate, LETTER_TEMPLATE_LABELS, fillTemplatePlaceholder, ResponseType, ResponseSentiment, ResponseStatus, CustomerResponse, CreateResponseRequest, UpdateResponseRequest, RESPONSE_TYPE_META, SENTIMENT_META, RESPONSE_STATUS_META, CustomerSuccessSummary, FollowUpFilter, FOLLOW_UP_FILTER_META, followUpTone, LETTER_TYPE_META_Item, LETTER_TYPE_META_Table, LETTER_STATUS_META_Item, LETTER_STATUS_META_Table, isSystemTemplate_Expanded, LETTER_TEMPLATE_LABELS_Table, RESPONSE_TYPE_META_Table, SENTIMENT_META_Item, SENTIMENT_META_Table, RESPONSE_STATUS_META_Item, RESPONSE_STATUS_META_Table, FOLLOW_UP_FILTER_META_Item, FOLLOW_UP_FILTER_META_Table, followUpTone_Item } from './business/customerSuccess.ets';
export { DispatchStatus, DispatchRecord, CreateDispatchRequest, formatSlot } from './business/dispatch.ets';
export { EditionLogin, EditionTab, EditionRouteMenu, EditionExtraRoute, EditionPortalFeature, EditionPortalEntry, EditionPortal, EditionConfig, EditionRouteMenu_Item, EditionConfig_Item } from './business/edition.ets';
export { LedgerType, LedgerEntry, LedgerSummary, MonthlySummary, CreateLedgerRequest, UpdateLedgerRequest, LEDGER_TYPE_META, LEDGER_CATEGORIES, LEDGER_TYPE_META_Item, LEDGER_TYPE_META_Table } from './business/finance.ets';
export { Product, StockMovementType, StockMovement, CreateProductRequest, UpdateProductRequest, StockChangeRequest, MOVEMENT_META, MOVEMENT_META_Item, MOVEMENT_META_Table } from './business/inventory.ets';
export { IotProduct, ProductProperty, ProductCommand, ProductDetail, IotDevice, DeviceDetail, DevicePropertyRecord, DeviceEventRecord, IotRule, IotAlert, DeviceNode, DeviceHealth, IotTopo, TopoNodePosition, IotOverview, RuleAction, CreateIotProductRequest, CreateProductPropertyRequest, CreateProductCommandRequest, CreateIotDeviceRequest, CreateIotRuleRequest, IOT_PROTOCOL_META, IOT_DATA_TYPE_META, IOT_OPERATOR_META, IOT_TRIGGER_META, IOT_ACTION_META, DEVICE_STATUS_META, IOT_SEVERITY_META, IOT_ALERT_STATUS_META, isNodeTemperatureKey, nodeIdOfKey, TEMP_ALERT_THRESHOLD, TEMP_WARN_THRESHOLD, TemperatureLevel, temperatureLevel, TEMPERATURE_LEVEL_COLOR, parseRuleActions, formatShadowValue, IotTopo_Item, IotTopo_Item2, IotOverview_Item, IotOverview_Item2, IotOverview_Item3, IotOverview_Item4, IOT_PROTOCOL_META_Item, IOT_PROTOCOL_META_Table, IOT_DATA_TYPE_META_Table, IOT_OPERATOR_META_Table, IOT_TRIGGER_META_Table, IOT_ACTION_META_Table, DEVICE_STATUS_META_Item, DEVICE_STATUS_META_Table, IOT_SEVERITY_META_Item, IOT_SEVERITY_META_Table, IOT_ALERT_STATUS_META_Item, IOT_ALERT_STATUS_META_Table, TEMPERATURE_LEVEL_COLOR_Table } from './business/iot.ets';
export { LeadStatus, LeadSource, FollowUpType, Lead, LeadFollowUp, LeadRequest, FollowUpRequest, LEAD_STATUS_META, LEAD_SOURCE_META, FOLLOW_UP_TYPE_META, LEAD_STATUS_META_Item, LEAD_STATUS_META_Table, LEAD_SOURCE_META_Table, FOLLOW_UP_TYPE_META_Table } from './business/lead.ets';
export { CaseType, CaseStatus, CaseStage, CasePriority, EventType, DocType, ExpenseType, LegalCase, CaseEvent, CreateCaseRequest, UpdateCaseRequest, CaseEventRequest, LegalDocument, DocumentTemplate, DocumentTemplateStatus, DOCUMENT_TEMPLATE_STATUS_META, DocumentTemplateRequest, LegalArchive, LegalArchiveRequest, ArchiveSummary, AnalyticsTrendRow, AnalyticsLawyerRow, AnalyticsDashboard, DocumentRequest, TimeEntry, TimeEntryStatus, TIME_ENTRY_STATUS_META, TimeEntryRequest, TimeEntrySummary, TimeEntryReportDayRow, TimeEntryReportCaseRow, TimeEntryReportItem, TimeEntryReport, Expense, ExpenseRequest, ExpenseSummary, LegalPage, WorkbenchSummary, RecentWorkItem, KnowledgeCardType, KnowledgeCardStatus, KnowledgeCard, KnowledgeCardRequest, KnowledgeSummary, GrowthDimension, GrowthSummary, KNOWLEDGE_TYPE_META, KNOWLEDGE_STATUS_META, CASE_STATUS_META, CASE_STAGE_META, CASE_PRIORITY_META, CASE_TYPE_META, EVENT_TYPE_META, DOC_TYPE_META, EXPENSE_TYPE_META, CaseStageFlow, CASE_STAGE_FLOW, stageIndex, GateType, GateStatus, Gate, GATE_TYPE_META, GATE_STATUS_META, DATA_CLASS_META, LetterDirection, LetterRequest, LetterSummary, LETTER_DIRECTION_META, ClientLifecycleStage, ClientStatus, ClientValueType, LegalClient, ClientValueRecord, ClientRequest, ClientSuccessSummary, CLIENT_STAGE_META, CLIENT_STATUS_META, CLIENT_VALUE_META, healthTone, CLIENT_STAGE_OPTIONS, CLIENT_STATUS_OPTIONS, ScheduleType, ScheduleResponsibility, MatterSchedule, ScheduleRequest, ScheduleConflict, ScheduleCapacity, MatterCalendarSummary, SCHEDULE_TYPE_META, SCHEDULE_RESPONSIBILITY_META, SCHEDULE_TYPE_OPTIONS, SCHEDULE_RESPONSIBILITY_OPTIONS, minuteToTime, WEEKDAY_TEXT, formatDateCN, OrgSignalType, OrgActionType, TeamMember, OrgSignal, OrgBoard, OrgAction, CareerMilestone, EnablementSummary, ORG_SIGNAL_META, ORG_ACTION_META, ORG_BOARD_META, GovernanceCategory, GovernanceStatus, GovernanceItem, AuditEvent, GovernanceRule, GovernanceSummary, GOV_CATEGORY_META, GOV_STATUS_META, GOV_SEVERITY_META, GOV_CATEGORY_OPTIONS, AssignmentStatus, CaseAssignment, AssignmentRequest, ASSIGNMENT_STATUS_META, SeatCode, CaseRole, CaseRoleRequest, SEAT_META, FlowKind, FlowStatus, KnowledgeFlow, KnowledgeFlowRequest, KnowledgeFlowAdvanceRequest, FLOW_KIND_META, FLOW_STATUS_META, LedgerStatus, LedgerRequest, LEDGER_STATUS_META, AgentCode, AiLayer, SuggestionKind, SuggestionStatus, AiSession, AiSessionRequest, AiSessionLayerRequest, AiSuggestion, AiSuggestionRequest, AiSuggestionHandleRequest, AGENT_META, AI_LAYER_META, SUGGESTION_KIND_META, SUGGESTION_STATUS_META, ReviewArtifactType, ReviewStatus, LegalReview, ReviewRequest, ReviewDecisionRequest, REVIEW_ARTIFACT_META, REVIEW_STATUS_META, LegalArticle, ArticleStatus, ARTICLE_STATUS_META, ArticleRequest, ArticleSummary, ConsultTicket, ConsultStatus, CONSULT_STATUS_META, ConsultSubmitRequest, ConsultProcessRequest, ConsultSummary, AiMessage, AiSendMessageRequest, DOCUMENT_TEMPLATE_STATUS_META_Item, DOCUMENT_TEMPLATE_STATUS_META_Table, ArchiveSummary_Item, AnalyticsDashboard_Item, TIME_ENTRY_STATUS_META_Item, TIME_ENTRY_STATUS_META_Table, GrowthSummary_Item, KNOWLEDGE_TYPE_META_Item, KNOWLEDGE_TYPE_META_Table, KNOWLEDGE_STATUS_META_Item, KNOWLEDGE_STATUS_META_Table, CASE_STATUS_META_Item, CASE_STATUS_META_Table, CASE_STAGE_META_Item, CASE_STAGE_META_Table, CASE_PRIORITY_META_Item, CASE_PRIORITY_META_Table, CASE_TYPE_META_Table, EVENT_TYPE_META_Item, EVENT_TYPE_META_Table, DOC_TYPE_META_Item, DOC_TYPE_META_Table, EXPENSE_TYPE_META_Item, EXPENSE_TYPE_META_Table, GATE_TYPE_META_Item, GATE_TYPE_META_Table, GATE_STATUS_META_Item, GATE_STATUS_META_Table, DATA_CLASS_META_Item, DATA_CLASS_META_Table, LETTER_DIRECTION_META_Item, LETTER_DIRECTION_META_Table, CLIENT_STAGE_META_Item, CLIENT_STAGE_META_Table, CLIENT_STATUS_META_Item, CLIENT_STATUS_META_Table, CLIENT_VALUE_META_Item, CLIENT_VALUE_META_Table, CLIENT_STAGE_OPTIONS_Item, CLIENT_STATUS_OPTIONS_Item, SCHEDULE_TYPE_META_Item, SCHEDULE_TYPE_META_Table, SCHEDULE_RESPONSIBILITY_META_Item, SCHEDULE_RESPONSIBILITY_META_Table, SCHEDULE_TYPE_OPTIONS_Item, SCHEDULE_RESPONSIBILITY_OPTIONS_Item, ORG_SIGNAL_META_Item, ORG_SIGNAL_META_Table, ORG_ACTION_META_Item, ORG_ACTION_META_Table, ORG_BOARD_META_Item, ORG_BOARD_META_Table, GovernanceSummary_Item, GovernanceSummary_Item2, GovernanceSummary_Item3, GOV_CATEGORY_META_Item, GOV_CATEGORY_META_Table, GOV_STATUS_META_Item, GOV_STATUS_META_Table, GOV_SEVERITY_META_Item, GOV_SEVERITY_META_Table, GOV_CATEGORY_OPTIONS_Item, ASSIGNMENT_STATUS_META_Item, ASSIGNMENT_STATUS_META_Table, SEAT_META_Item, SEAT_META_Table, FLOW_KIND_META_Item, FLOW_KIND_META_Table, FLOW_STATUS_META_Item, FLOW_STATUS_META_Table, LEDGER_STATUS_META_Item, LEDGER_STATUS_META_Table, AGENT_META_Item, AGENT_META_Table, AI_LAYER_META_Item, AI_LAYER_META_Table, SUGGESTION_KIND_META_Item, SUGGESTION_KIND_META_Table, SUGGESTION_STATUS_META_Item, SUGGESTION_STATUS_META_Table, REVIEW_ARTIFACT_META_Item, REVIEW_ARTIFACT_META_Table, REVIEW_STATUS_META_Item, REVIEW_STATUS_META_Table, ARTICLE_STATUS_META_Item, ARTICLE_STATUS_META_Table, CONSULT_STATUS_META_Item, CONSULT_STATUS_META_Table } from './business/legal.ets';
export { MemberLevel, MemberStatus, MEMBER_LEVEL_META, MEMBER_STATUS_META, Member, CreateMemberRequest, UpdateMemberRequest, MEMBER_LEVEL_META_Item, MEMBER_LEVEL_META_Table, MEMBER_STATUS_META_Item, MEMBER_STATUS_META_Table } from './business/member.ets';
export { MenuNode } from './business/menu.ets';
export { OrgType, OrgStatus, Organization, CreateOrgInput, UpdateOrgInput, OrgStaffStats, UserOrgInfo } from './business/org.ets';
export { Batch, InspectionType, InspectionResult, QualityInspection, BatchDetail, InspectionDetail, ProductTrace, CreateBatchRequest, CreateInspectionRequest, INSPECTION_TYPE_META, INSPECTION_RESULT_META, BatchDetail_Item, ProductTrace_Item, ProductTrace_Item2, INSPECTION_TYPE_META_Item, INSPECTION_TYPE_META_Table, INSPECTION_RESULT_META_Item, INSPECTION_RESULT_META_Table } from './business/quality.ets';
export { RoleScope, Role, CreateRoleRequest, UpdateRoleRequest, ROLE_SCOPE_META, ROLE_SCOPE_META_Item, ROLE_SCOPE_META_Table } from './business/role.ets';
export { SupplyOrderStatus, SupplyOrder, CreateSupplyOrderRequest, SUPPLY_STATUS_META, ConsumptionRecord, CreateConsumptionRequest, SettlementStatus, Settlement, CreateSettlementRequest, SETTLEMENT_STATUS_META, formatMoney, SettleCycle, SUPPLY_STATUS_META_Item, SUPPLY_STATUS_META_Table, SETTLEMENT_STATUS_META_Item, SETTLEMENT_STATUS_META_Table } from './business/supply.ets';
export { TeacherStatus, Teacher, CreateTeacherRequest, UpdateTeacherRequest, SUBJECT_OPTIONS } from './business/teacher.ets';
export { TenantStatus, Tenant, CreateTenantRequest, UpdateTenantRequest, RegisterTenantRequest, RegisterTenantResult, TENANT_STATUS_META, TenantInvite, CreateInviteRequest, TENANT_STATUS_META_Item, TENANT_STATUS_META_Table } from './business/tenant.ets';
export { UserStatus, User, CreateUserRequest, UpdateUserRequest } from './business/user.ets';
