# 📊 Data Warehouse & Analytics Project  

This repository is based on and inspired by the original project:  
👉 https://github.com/DataWithBaraa/sql-data-warehouse-project

It demonstrates a comprehensive **Data Warehousing and Analytics solution**, from raw data ingestion to business-ready analytics.  
It is designed as a **portfolio project** showcasing best practices in **data engineering, data modeling, ETL pipelines, and SQL-based analytics**.  
Created as a **portfolio project** to demonstrate practical skills in data engineering and analytics.

---

## 🚀 Project Overview

The goal of this project is to design and implement a **modern data warehouse** that consolidates sales data from multiple source systems and enables analytical reporting for business decision-making.

### Key Topics Covered
- Data Warehouse Architecture (Medallion Architecture)
- ETL Pipelines (Extract, Transform, Load)
- Data Modeling (Star Schema)
- SQL Analytics & Reporting
- Data Quality & Integration
  
### 📐 Standards & Conventions
To ensure consistency and readability across the project, all database objects follow defined naming standards:

- 📄 **Naming Conventions:**  
  👉 [View naming_conventions](docs/naming_conventions.md)

### 📂 Project Scripts Location

All SQL and ETL scripts used in this project are stored in a dedicated folder within this repository:

- 📁 **Scripts Folder:**  
  👉 [Browse scripts](scripts/)

---

## 🏗️ Data Architecture (Medallion Architecture)

The project follows the **Medallion Architecture** pattern with three layers:

### 🥉 Bronze Layer  
- Stores **raw data** as-is from source systems  
- Data ingested from **CSV files** into **SQL Server**

### 🥈 Silver Layer  
- Data **cleansing, standardization, and normalization**  
- Prepares clean and consistent data for analytics

### 🥇 Gold Layer  
- **Business-ready data models**  
- Fact and dimension tables in **star schema**  
- Optimized for reporting and analytical queries

![Data Warehouse Architecture](docs/images/Architecture.jpg)

---

# 🔄 Integration Diagram

![Integration Diagram](docs/images/integration_diagram.jpg)

The project integrates data from two main source systems:

## CRM System
Contains:
- Customer information
- Product information
- Sales transactions and order details

Tables:
- `crm_cust_info`
- `crm_prd_info`
- `crm_sales_details`

## ERP System
Contains:
- Additional customer information
- Customer location data
- Product category mappings

Tables:
- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

The Silver layer integrates and standardizes these datasets into a unified analytical structure.

---

## 🔄 ETL & Data Modeling

### ETL Pipelines
- Extract data from ERP and CRM source systems (CSV)
- Transform data (cleaning, formatting, normalization)
- Load structured data into the data warehouse

### Data Modeling
- Fact tables for sales and transactions  
- Dimension tables for customers, products, time, etc.  
- Optimized for BI and analytical workloads

---

## 📈 Analytics & Reporting

SQL-based analytical queries provide insights into:

- 👥 Customer Behavior  
- 📦 Product Performance  
- 📊 Sales Trends  

These insights enable **data-driven decision-making** for business stakeholders.

---

## 🧰 Tools & Technologies

- **[Datasets](datasets/):** CSV source files 
- **Database:** SQL Server Express  
- **Management:** SQL Server Management Studio (SSMS)  
- **Modeling & Diagrams:** Draw.io  
- **Project Management:** Notion  

---

## 🎯 Project Requirements

### Data Engineering – Data Warehouse

**Objective:**  
Develop a modern data warehouse in SQL Server for consolidated analytical reporting.

**Specifications:**
- Source systems: ERP & CRM (CSV files)  
- Data quality: cleansing & validation before analysis  
- Integration: unified analytical data model  
- Scope: latest dataset only (no historization)  
- Documentation: clear data model documentation for business & analytics teams  

---

### BI & Analytics

**Objective:**  
Create SQL-based analytics to provide insights into:

- Customer behavior  
- Product performance  
- Sales trends  

These outputs support strategic and operational business decisions.

---


