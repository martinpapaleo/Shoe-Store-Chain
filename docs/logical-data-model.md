# School Shoe Store Chain — Logical Data Model

This document defines the logical entity-relationship model for a
multi-branch school shoe retail chain, covering in-store and online
sales, returns, inventory, employment history, and stock auditability.
Promotions are explicitly out of scope for this iteration.

Data types, constraints, and indexes are intentionally **not** defined
here — they belong to the physical model.

## Entity-Relationship Diagram

```mermaid
erDiagram
    PRODUCT ||--o{ PRODUCT_MODEL : has
    PRODUCT_MODEL ||--o{ PRICE_HISTORY : "priced over time"
    PRODUCT_MODEL ||--o{ PRODUCT_MODEL_X_BRANCH : "stocked as"
    BRANCH ||--o{ PRODUCT_MODEL_X_BRANCH : stocks
    PRODUCT_MODEL_X_BRANCH ||--o{ STOCK_MOVEMENT : "history of"

    BRANCH ||--o{ EMPLOYEE_EMPLOYMENT_PERIOD : hosts
    EMPLOYEE ||--o{ EMPLOYEE_EMPLOYMENT_PERIOD : has
    ROLE ||--o{ EMPLOYEE_EMPLOYMENT_PERIOD : "held during"

    BRANCH ||--o{ RECEIPT_HEADER : issues
    CUSTOMER |o--o{ RECEIPT_HEADER : places
    EMPLOYEE_EMPLOYMENT_PERIOD |o--o{ RECEIPT_HEADER : sold_by
    SALES_CHANNEL ||--o{ RECEIPT_HEADER : "channel of"

    RECEIPT_HEADER ||--|{ RECEIPT_DETAIL : contains
    PRODUCT_MODEL ||--o{ RECEIPT_DETAIL : "sold as"

    RECEIPT_HEADER ||--o{ RECEIPT_PAYMENT : "paid via"
    PAYMENT_METHOD ||--o{ RECEIPT_PAYMENT : "used in"

    RECEIPT_HEADER ||--o| SHIPMENT : "shipped via"

    RECEIPT_HEADER ||--o{ RETURN : "returned via"
    RETURN ||--|{ RETURN_DETAIL : contains
    RECEIPT_DETAIL ||--o{ RETURN_DETAIL : "returned as"

    BRANCH {
        int branch_id PK
        string name
        string address
        string phone
        date opening_date
        date closing_date "nullable"
    }

    PRODUCT {
        int product_id PK
        string product_name
        string brand
        string category "boys / girls / unisex"
        string season
        date created_at
        date discontinued_at "nullable"
    }

    PRODUCT_MODEL {
        int model_id PK
        int product_id FK
        string size
        string color
        string sku UK
        date created_at
        date discontinued_at "nullable"
    }

    PRICE_HISTORY {
        int price_id PK
        int model_id FK
        decimal price
        date valid_from
        date valid_to "nullable"
    }

    ROLE {
        int role_id PK
        string role_description
        date created_at
        date deactivated_at "nullable"
    }

    EMPLOYEE {
        int employee_id PK
        string first_name
        string last_name
        string national_id
        date date_of_birth
        date created_at
        date deactivated_at "nullable"
    }

    EMPLOYEE_EMPLOYMENT_PERIOD {
        int emp_period_id PK
        int employee_id FK
        int branch_id FK
        int role_id FK
        date start_date
        date end_date "nullable"
    }

    PAYMENT_METHOD {
        int payment_method_id PK
        string name
        date created_at
        date deactivated_at "nullable"
    }

    SALES_CHANNEL {
        int channel_id PK
        string name "in_store, online"
        date created_at
        date deactivated_at "nullable"
    }

    CUSTOMER {
        int customer_id PK
        string first_name
        string last_name
        string national_id
        string email "nullable"
        string phone "nullable"
        date created_at
        date deactivated_at "nullable"
    }

    PRODUCT_MODEL_X_BRANCH {
        int branch_id PK,FK
        int model_id PK,FK
        int quantity
        datetime updated_at
    }

    STOCK_MOVEMENT {
        int movement_id PK
        int branch_id FK
        int model_id FK
        int quantity_delta
        string reason
        datetime created_at
    }

    RECEIPT_HEADER {
        int receipt_id PK
        int branch_id FK
        int emp_period_id FK "nullable"
        int customer_id FK "nullable"
        int channel_id FK
        string delivery_type "nullable"
        datetime datetime
        string status
        decimal total
    }

    RECEIPT_DETAIL {
        int detail_id PK
        int receipt_id FK
        int model_id FK
        int quantity
        decimal unit_price
        decimal subtotal
    }

    RECEIPT_PAYMENT {
        int payment_id PK
        int receipt_id FK
        int payment_method_id FK
        decimal amount
    }

    SHIPMENT {
        int shipment_id PK
        int receipt_id FK,UK
        string carrier
        string tracking_number
        string delivery_address
        string status "pending, in_transit, delivered"
        datetime shipped_at
        datetime delivered_at "nullable"
    }

    RETURN {
        int return_id PK
        int receipt_id FK
        date date
        string reason
        string status
    }

    RETURN_DETAIL {
        int return_detail_id PK
        int return_id FK
        int detail_id FK
        int quantity_returned
    }
```

## Relationship Summary

### Catalog

| Relationship | Cardinality | Notes |
|---|---|---|
| Product → ProductModel | 1:N | A product has many size/color variants |
| ProductModel → PriceHistory | 1:N | Price is universal (not per branch) and versioned over time |

### Employment

| Relationship | Cardinality | Notes |
|---|---|---|
| Branch → EmployeeEmploymentPeriod | 1:N | One branch hosts many employment periods |
| Employee → EmployeeEmploymentPeriod | 1:N | Supports unlimited hire/resign/rehire cycles |
| Role → EmployeeEmploymentPeriod | 1:N | Role held during a specific period |

**Business rule:** an employee's `EmployeeEmploymentPeriod` rows must not have overlapping date ranges.

### Inventory

| Relationship | Cardinality | Notes |
|---|---|---|
| Branch → ProductModelXBranch | 1:N | Stock tracked per branch |
| ProductModel → ProductModelXBranch | 1:N | Same variant can have stock rows in multiple branches |
| ProductModelXBranch → StockMovement | 1:N | Auditable history of quantity changes over time |

### Sales

| Relationship | Cardinality | Notes |
|---|---|---|
| Branch → ReceiptHeader | 1:N | Every receipt is always associated with a branch, including online sales |
| Customer → ReceiptHeader | 0/1:N | Optional (guest checkout) |
| EmployeeEmploymentPeriod → ReceiptHeader | 0/1:N | Optional; captures branch + role at time of sale |
| SalesChannel → ReceiptHeader | 1:N | in_store or online |
| ReceiptHeader → ReceiptDetail | 1:N (min 1) | |
| ProductModel → ReceiptDetail | 1:N | |
| ReceiptHeader → ReceiptPayment | 1:N | Supports split/combined payment methods |
| PaymentMethod → ReceiptPayment | 1:N | |
| ReceiptHeader → Shipment | 1:0/1 | Only when `delivery_type = shipping` |

**Business rule:** `ReceiptDetail.unit_price` is a snapshot taken from `PriceHistory` at time of sale — never recalculated later.

### Returns

| Relationship | Cardinality | Notes |
|---|---|---|
| ReceiptHeader → Return | 1:N | A receipt can have multiple return events over time |
| Return → ReturnDetail | 1:N (min 1) | |
| ReceiptDetail → ReturnDetail | 1:N | Total quantity returned must never exceed original quantity sold |

## Business Rules Without a Direct Foreign Key

These are resolved by the application at write time, not enforced by a structural relationship:

- **Price lookup:** when creating a `ReceiptDetail`, the application looks up the currently valid row in `PriceHistory` (`valid_from <= date <= valid_to`) and copies it into `unit_price`.
- **Stock decrement:** when creating a `ReceiptDetail`, the application decrements `quantity` on the matching `ProductModelXBranch` row (same `branch_id` + `model_id`), and inserts a corresponding `StockMovement` row.

## Out of Scope (Current Iteration)

- Promotions and discounts.
- Serialized / per-unit physical inventory tracking (stock is tracked as an aggregate quantity per branch + variant, not per individual physical unit).