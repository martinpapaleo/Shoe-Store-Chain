# Small Business Data Platform — School Shoe Store Chain

## About This Project

This is my main portfolio project as I work toward becoming a Junior Data
Engineer. Instead of using real-world data (which introduces privacy,
access, and unnecessary domain complexity), I designed a **completely
synthetic small business**: a multi-branch chain of school shoe stores,
selling both in-store and online.

The goal is to go through the **full data engineering lifecycle** on a
system small enough that I can understand and build every part of it
myself — from business requirements, to a relational operational database,
to a Data Warehouse, to an orchestrated ETL/ELT pipeline.

## Why This Project Exists

This project follows a career development plan I put together with my
mentor **Nico**, a Data Engineer with 10+ years of experience and my former
Data Management professor at ITBA. Two of his suggestions directly shaped
the approach:

- **Prefer ELT over ETL** when loading a Data Warehouse: extract data as-is
  into a raw/staging layer first (excluding sensitive fields), and only
  transform it afterward into the dimensional model. This keeps the
  ingestion step simple and pushes all business logic into an explicit,
  reviewable transformation step.
- **Don't over-model the transactional side just to have one.** The
  Data Warehouse should be driven by the analytical questions it needs to
  answer, not by exhaustively replicating every operational detail.

## Goals

- Become a Junior Data Engineer, ideally through an internship or
  part-time role.
- Build hands-on depth in: Python, SQL, relational and dimensional data
  modeling, ETL/ELT, Docker, PostgreSQL, and (eventually) Airflow.
- Favor backend/infrastructure-oriented data engineering work over
  BI-heavy roles.
- Build first principles correctly before adding infrastructure — only
  introduce a new tool when the project creates an actual reason for it.

## Roadmap / Current Status

| # | Step | Status |
|---|------|--------|
| 1 | Define the business and its requirements | ✅ Done |
| 2 | Logical Data Model | 🔄 In progress |
| 3 | Physical Data Model | ⬜ Not started |
| 4 | Learn PostgreSQL | ⬜ Not started |
| 5 | Learn Docker | ⬜ Not started |
| 6 | Learn basic Linux/CLI + PostgreSQL tooling | ⬜ Not started |
| 7 | Generate synthetic data with Python | ⬜ Not started |
| 8 | Build and populate the operational database | ⬜ Not started |
| 9 | Design the Data Warehouse | ⬜ Not started |
| 10 | Build the ETL/ELT pipeline | ⬜ Not started |
| 11 | Add data-quality checks | ⬜ Not started |
| 12 | Learn Airflow and orchestrate the pipeline | ⬜ Not started |

I'm applying to internships and part-time roles in parallel with this
roadmap — not waiting until it's finished.

## Business Domain

A chain of school shoe stores with multiple physical branches, plus an
online sales channel. Key aspects the model needs to support:

- Multiple branches, each with independent stock.
- Products sold as specific variants (model + size + color), not as a
  single generic item.
- Universal pricing across the whole chain, versioned over time (price
  history).
- Sales through two channels: in-store and online, with online orders
  either picked up in-branch or shipped via a third-party carrier.
- Split/combined payment methods on a single receipt.
- Returns, referencing the original receipt and line.
- Employees who can be hired, resign, and be rehired an unlimited number
  of times, potentially at different branches and roles over time.
- Stock movement history, not just a current quantity, for auditability.
- Promotions/discounts are explicitly **out of scope** for this iteration.

## Logical Data Model

The logical model is being designed independently of any specific
database engine — no data types yet, just entities, attributes,
relationships, and cardinalities. Data types, constraints, and indexes
are deliberately deferred to the physical model step, where they belong.

Current entity groups:

- **Catalog:** `Branch`, `Product`, `ProductModel` (specific
  size/color/SKU variant), `PriceHistory`, `Role`, `PaymentMethod`,
  `SalesChannel`
- **Employment:** `Employee`, `EmployeeEmploymentPeriod` (supports
  unlimited hire/resign/rehire cycles across branches and roles)
- **Inventory:** `ProductModelXBranch` (stock per branch/variant),
  `StockMovement` (auditable history of stock changes)
- **Sales:** `Customer`, `ReceiptHeader`, `ReceiptDetail`,
  `ReceiptPayment`
- **Fulfillment:** `Shipment` (for online orders shipped rather than
  picked up in-branch)
- **Returns:** `Return`, `ReturnDetail`

Most master entities follow a consistent audit pattern: `created_at` /
`deactivated_at` (soft delete) instead of physical deletion, so historical
records stay valid even after something is discontinued.

Full entity definitions and relationships are documented in
[`docs/logical-data-model.md`](docs/logical-data-model.md).

## Tech Stack

**Currently using:**
- Python
- SQL
- SQL Server (prior coursework projects)
- Git / GitHub
- DBSchema (data modeling)

**Learning next, in this project:**
- PostgreSQL
- Docker / Docker Compose
- Linux / command line fundamentals
- Apache Airflow

**Explicitly postponed** (not needed for this project's scope):
PySpark, Kafka, Kubernetes, Flink, Terraform, Databricks, streaming,
advanced cloud infrastructure.

## Design Principles

- **Reproducibility as a portfolio signal.** The operational database
  should be creatable from scripts, populated, queried, destroyed, and
  rebuilt from scratch at any time.
- **ELT over ETL** for the Data Warehouse load: raw extraction first,
  transformation second, driven by the analytical questions being
  answered (e.g. revenue by month, best-selling products, average order
  value, sales by category).
- **Business rules vs. structural relationships.** Some connections
  between entities (e.g. looking up the current price, or decrementing
  stock on a sale) are resolved by application logic at write time, not
  by a foreign key — this is documented explicitly to avoid confusing
  "how the data is used" with "how the tables are structured."

## Related Projects in This Portfolio

- **Retail Sales ETL Pipeline** — a completed, modular batch ETL
  pipeline (Python, Pandas, Parquet). Demonstrates foundational ETL and
  data validation; considered finished and intentionally not being
  over-polished.
- **SQL Server / Database coursework projects** — demonstrate prior
  relational database design knowledge.

---

*This README is a work-in-progress draft and will be updated as the
project advances through the roadmap above.*
