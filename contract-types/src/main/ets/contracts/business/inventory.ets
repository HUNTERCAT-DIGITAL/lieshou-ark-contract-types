/**
 * 进销存类型（inventory-service · Phase 9）.
 * 与后端 Product / StockMovement 实体对齐（ADR-0025 强制租户模式）。
 */

export interface Product {
  id: number;
  tenantId: number;
  name: string;
  code?: string | null;
  unit?: string | null;
  price?: number | null;
  stockQuantity: number;
  remark?: string | null;
  /** 教育版（zhiye · 课程产品）扩展字段（Phase 1） */
  lessonCount?: number | null;
  lessonPrice?: number | null;
  curriculumUrl?: string | null;
  ageGroup?: string | null;
  classMode?: string | null;
  /** 创建人 / 更新人（后端新增 · L4-3 契约对齐） */
  createdBy?: number | null;
  updatedBy?: number | null;
  createdAt: string;
  updatedAt?: string;
}


export type StockMovementType = "IN" | "OUT";


export interface StockMovement {
  id: number;
  tenantId: number;
  productId: number;
  type: StockMovementType;
  quantity: number;
  remark?: string | null;
  createdAt: string;
}


/** 新建商品 */
export interface CreateProductRequest {
  name: string;
  code?: string;
  unit?: string;
  price?: number;
  remark?: string;
  /** 教育版（zhiye · 课程产品）扩展字段，全部可选 */
  lessonCount?: number;
  lessonPrice?: number;
  curriculumUrl?: string;
  ageGroup?: string;
  classMode?: string;
}


/** 编辑商品（字段可选） */
export interface UpdateProductRequest {
  name?: string;
  code?: string;
  unit?: string;
  price?: number;
  remark?: string;
  /** 教育版（zhiye · 课程产品）扩展字段，全部可选 */
  lessonCount?: number;
  lessonPrice?: number;
  curriculumUrl?: string;
  ageGroup?: string;
  classMode?: string;
}


/** 出入库请求（batchId 可选 · ADR-0037 追溯挂批次） */
export interface StockChangeRequest {
  quantity: number;
  batchId?: number;
  remark?: string;
}


/** 状态 → 中文/颜色（前端展示） */
export const MOVEMENT_META: MOVEMENT_META_Table = {
  IN: { text: "入库", color: "green" },
  OUT: { text: "出库", color: "orange" },
};

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface MOVEMENT_META_Item {
 text: string;
 color: string
}

// ---- 生成器提升（ArkTS 禁内联对象类型 / utility type）----
export interface MOVEMENT_META_Table {
  IN: MOVEMENT_META_Item;
  OUT: MOVEMENT_META_Item;
}
