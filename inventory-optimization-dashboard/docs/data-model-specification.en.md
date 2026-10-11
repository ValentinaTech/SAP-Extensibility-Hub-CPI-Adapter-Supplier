# Data Model Specification: Inventory Optimization Dashboard

## 1. Overview and Architecture Strategy
This specification defines the data model migration path from a legacy **SAP ECC6 (Open SQL)** architecture to an optimized **S/4HANA Cloud** environment utilizing **CDS Views**. 

The goal is to replace complex `SELECT` statements with declarative CDS views that leverage HANA in-memory computation, ensuring high performance for the Fiori Elements frontend. The model prioritizes:
*   **Analytical Density:** Combining master data (Materials/Vendors) with transactional data (Stock/Movements).
*   **Predictive Readiness:** Preparing fields specifically for ML/ML algorithms used in inventory optimization.
*   **Cloud-Native Integration:** Ensuring entities are exposed via OData v4 compatible services.

---

## 2. Core Entity Definitions (CDS View Structure)

### 2.1 `Z_INV_OPT_HEADER`
**Purpose**: High-level dashboard aggregation providing stock snapshots and key KPIs per Storage Location Group. Replaces legacy report headers in SAP ECC.

File: /inventory-optimization-dashboard/legacy_group_examples/Z_INV_OPT_HEADER.abap

### 2.2 `Z_MAT_STOCK_DETAILS` (The "Wide Table")
**Purpose**: Detailed transactional view exposing current stock levels across all storage locations and plants. Designed to be consumed by Fiori List Reports or Analysis Pages. This replaces the need for joining multiple tables in ABAP code, pushing joins into CDS logic instead.

File: /inventory-optimization-dashboard/legacy_group_examples/Z_MAT_STOCK_DETAILS.abap
