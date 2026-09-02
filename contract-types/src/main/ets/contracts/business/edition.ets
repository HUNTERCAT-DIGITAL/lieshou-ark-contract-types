/**
 * 跨端 Edition（版别）类型 · 2026-08 上游重构统一
 *
 * 背景：5 端（admin-web/desktop/mobile/mobile-web/mini-program）重建为 React 骨架后，
 * 各端各自维护一份 EditionConfig 副本（仅字段子集不同）——本文件为唯一事实源：
 * - 端内不再定义 EditionConfig/EditionExtraRoute/EditionTab（删除副本，从本包导入）
 * - 客户仓 editions/<client>.extra.ts 也按本类型注入（deploy 脚本同源）
 * - 各端只取自己需要的字段（未用字段忽略）
 */


/**
 * 登录能力配置（端薄壳化 · 2026-08-29 决策）.
 *
 * 登录是「可配置的平台能力」而非固定页面：
 * - required=false → 纯展示端（官网/门户）游客直达, 不拦截路由
 * - mode 决定登录形态（账号密码 / 验证码 / SSO / 无）
 * - 客户要完全自定义登录页 → 端仓 Edition.extraRoutes 注入 standalone 登录页
 */
export interface EditionLogin {
  /** 是否需要登录（false = 游客直达, 不拦截路由） */
  required?: boolean;
  /** 登录模式: password 账号密码 / sms 短信验证码 / sso 单点 / none 无 */
  mode?: "password" | "sms" | "sso" | "none";
  /** 登录页品牌标语（客户注入, 缺省用 edition.slogan） */
  brandMessage?: string;
  /** 隐藏租户输入框（单租户版：默认租户静默使用 edition.tenantCode, 不展示给用户） */
  hideTenantInput?: boolean;
}


/** 底部导航项（H5 / 小程序 tab · 2026-08 统一） */
export interface EditionTab {
  /** 路由 path 首段（如 home / overview） */
  name: string;
  title: string;
  /** 图标（emoji 或资源路径，各端自行解释） */
  icon?: string;
}


/** 客户菜单声明（后台端注入菜单用 · 2026-08 客户字段上收） */
export interface EditionRouteMenu {
  name: string;
  icon?: string;
  order?: number;
  /** 同 group 的菜单项收进分组子菜单 */
  group?: string;
  /** 可见角色列表（缺省 = 所有登录用户可见；后台端与 CurrentUser.roles 求交集过滤） */
  roles?: string[];
  /** 菜单角标：轮询端点 → 计数字段（如告警「待确认」数） */
  badge?: EditionRouteMenu_Item;
}


/**
 * 客户注入路由（懒加载组件工厂 · 2026-08 统一为 React load 语义）.
 * 由客户仓 deploy 生成 editions/<client>.extra.ts 注入，平台只渲染槽位。
 */
export interface EditionExtraRoute {
  path: string;
  /** 懒加载组件工厂（客户包模块，如 () => import('@lieshoucloud/<client>/pages/XxxPage')） */
  /** 动态加载语义（鸿蒙 Navigation 编译期路由；此字段保留兼容占位） */
  load?: () => Promise<void>;
  title?: string;
  /** 客户菜单声明（后台端） */
  menu?: EditionRouteMenu;
  /** 声明后作为底部 tab 展示（path 首段；H5/小程序用） */
  tab?: EditionTab;
  /** true = 独立页（不带布局，如外部落地页） */
  standalone?: boolean;
  /** 权限码（缺省 = 登录可见；admin-web 等使用） */
  accessKey?: string;
}


/** 门户页功能卡片 */
export interface EditionPortalFeature {
  title: string;
  desc: string;
}


/** 门户页多端入口（二维码 / 下载按钮） */
export interface EditionPortalEntry {
  /** 显示名（如「H5 移动端」「桌面端」） */
  label: string;
  /** 说明（如「浏览器直接访问」） */
  desc?: string;
  /** 访问/下载 URL（qrcode 类型编码此 URL 为二维码） */
  url?: string;
  /** 类型：qrcode=展示二维码 / download=下载按钮 */
  kind?: 'qrcode' | 'download';
}


/** 门户页配置（产品介绍 + 功能列表 + 多端入口） */
export interface EditionPortal {
  /** 产品介绍段落 */
  intro?: string[];
  /** 功能列表 */
  features?: EditionPortalFeature[];
  /** 多端入口 */
  entries?: EditionPortalEntry[];
}


/**
 * 跨端 EditionConfig（2026-08 统一最小集）.
 * 各端/客户取所需字段；端级专有扩展（如 admin-web 门户卡片/行业装配）留在端内组合。
 */
export interface EditionConfig {
  id: string;
  /** 品牌名（导航栏/登录页/启动页展示） */
  brandName: string;
  /** 品牌标语 */
  slogan?: string;
  /** 品牌 logo（public 资源路径 / 端内资源路径） */
  logo?: string;
  /** 版权署名主体（缺省回退 brandName） */
  companyName?: string;
  /** 登录默认租户（缺省 default） */
  tenantCode?: string;
  /** 登录能力配置 */
  login?: EditionLogin;
  /** 底部导航（H5/小程序） */
  tabs?: EditionTab[];
  /** 客户注入路由 */
  extraRoutes?: EditionExtraRoute[];
  /** 裁剪底部 tab */
  hiddenTabs?: string[];
  /** 品牌主色（antd/端主题色值 · 2026-08 客户字段上收，如 dwjk #02429B） */
  primaryColor?: string;
  /** 门户副文案（登录/门户页 hero 描述） */
  heroDesc?: string;
  /** 门户页配置（产品介绍/功能/多端入口） */
  portal?: EditionPortal;
  /** 菜单路径裁剪（后台端隐藏非本客户业务菜单 · 如 dwjk 隐藏 CRM/财务） */
  hiddenMenus?: string[];
  /** 顶栏快捷入口（如「驾驶舱」大屏按钮，渲染在顶部右侧 · 2026-09-01） */
  headerActions?: Array<EditionConfig_Item>;
  /** 值班员控制台模式：登录直进工作台，只展示行业核心看板（dwjk 电网监控） */
  dutyConsole?: boolean;
  /** 登录后默认落地页（客户版指向客户工作台） */
  homePath?: string;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface EditionRouteMenu_Item {

    /** 轮询端点（如 /api/iot/devices/overview） */
    endpoint: string;

    /** 响应 JSON 中计数字段（如 pendingAlerts） */
    field: string;

    /** 轮询间隔 ms（缺省 30000） */
    intervalMs?: number;
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface EditionConfig_Item {
 label: string;
 path: string
}
