# Baby Names Analysis (USA, 1980-2009)

## Overview  

This project explores nearly 30 years of U.S. baby name data (1980-2009).  
Using **SQL for exploratory analysis and data modeling**, and **Power BI for visualization**, I built an interactive dashboard uncovering naming trends, cultural influences, and fun facts.

The goal: to demonstrate a **full BI workflow** - from raw data, through structured modeling and analysis, to a polished, interactive report.  

## Data Preparation & EDA (SQL)  

- Source: CSV file with **2M+ rows** of baby names and births.  
- Loaded into a SQL Server database prepared for analysis.  
- Data was already clean, so I focused on exploration:  
  - gender trends, time trends, demographics, popularity rankings across different dimensions,  
  - identification of outliers, androgynous names, shortest/longest names.  

As a final step, I built optimized views for BI:  
- `v_dim_name` - enriched name dimension (gender, length, flags, popularity indicators),
- `v_dim_state` - state dimension grouped into regions,  
- `v_fact_births` - fact table with births by year, state, and name.  

This stage was also a chance to practice **clean, well-structured SQL** and set a strong foundation for the Power BI layer.  

## Power BI Dashboard  

- Imported SQL views into Power BI and built a relational data model.  
- Defined custom measures (DAX) and filters.  
- Structured the dashboard as a **data story** with six sections:  
  **Overview** - key KPIs and trends,  
  **Popularity & Gender** - distribution, unique names, top male/female/androgynous names,  
  **Pop Culture Names** - influence of celebrities and events,  
  **Name Length** - shortest, longest, and average length analysis,  
  **First Letter** - distribution by starting letters,  
  **Check Your Name** - interactive exploration for any name.  

This structure made the insights both engaging and easy to follow.  
 
👉 [Live dashboard here](https://app.powerbi.com/view?r=eyJrIjoiMjMyYjY3N2YtZGY1NC00YTk0LTllMzMtOGNhMzdlNGVlMTA3IiwidCI6IjE1YzIyNjQ2LTU5M2YtNDMxOC04NTYzLTMwZmU5ZmRmMDdjZSJ9)

## Tools & Skills  
- **SQL Server** - database design, EDA with joins, CTEs, window functions, optimized BI-ready views.  
- **Power BI** - data model, DAX measures, interactive storytelling dashboard.  

## Repository Structure  

- `data/`
  - `raw_data.csv` - source dataset
- `sql/`
   - `tables_creation.sql` - table definition
   - `exploratory_data_analysis.sql` - SQL for EDA
   - `final_views.sql` - BI-ready views
- `powerbi/`
   - `dashboard.pbix` - Power BI dashboard
- `README.md` - project documentation

