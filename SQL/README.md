# Employment Statistics Analysis (SQL)

SQL-based data engineering and analytics project analyzing employment statistics data in Germany.  
The project focuses on building a structured ETL pipeline, creating analytical views, and generating key labor market indicators.

---

## Project Overview

This project processes employment statistics data and transforms raw input into structured analytical views.  
The workflow includes data ingestion, data cleaning, dimensional modeling, KPI generation, and reporting queries.

The goal is to analyze employment trends and differences across regions, qualifications, and nationality groups.

---

## Tools & Technologies

- MySQL
- SQL
- Data Modeling
- ETL Pipeline Design
- Data Quality Checks

---

## Data Pipeline

The project follows a structured SQL pipeline:

1. **Schema Creation**
   - Define database structure
   - Create required tables

2. **Dimension Tables**
   - Build supporting dimension tables
   - Example: Bundesland (federal state)

3. **Data Transformation**
   - Clean and enrich employment data
   - Normalize fields and prepare analysis-ready dataset

4. **Constraints & Data Integrity**
   - Apply constraints and structural validations

5. **Analytical Views**
   - Create reusable SQL views for KPI analysis

6. **Quality Checks**
   - Validate dataset completeness and integrity

7. **Reporting Queries**
   - Generate insights from the cleaned dataset

---

## Repository Structure
```
employment-statistics-analysis
│
├── sql
│ ├── 01_schema.sql
│ ├── 02_dim_bundesland.sql
│ ├── 03_rebuild_ba_clean.sql
│ ├── 04_hardening_constraints.sql
│ ├── 05_views_kpis.sql
│ ├── 06_quality_checks.sql
│ └── 07_reporting.sql
│
├── data
│ └── sample_dataset.csv
│
├── documentation
│ └── project_documentation.pdf
│
├── screenshots
│ ├── analysis_charts.png
│ ├── query_results.png
│ └── kpi_views.png
│
└── README.md
```

---

## Key Analysis Topics

The analysis focuses on:

- Employment trends over time
- Regional distribution of employment
- Qualification structure of employees
- Comparison between German and foreign employees
- Year-over-year employment development
- Labor market structure across federal states

---

## Example Insights

Using SQL queries and analytical views, the project demonstrates how to derive labor market insights such as:

- Regional employment differences
- Changes in workforce qualification levels
- Employment trends across nationality groups
- Structural changes in the labor market

---

## Author

Ayse Tosun  
Aspiring Data Analyst  

Skills demonstrated in this project:

- SQL
- Data Modeling
- Data Cleaning
- Analytical Query Design
- Data Quality Validation
