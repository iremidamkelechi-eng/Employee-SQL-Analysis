**ANALYSIS**



**Employee Salary \& Workforce Analytics (MySQL Project)**



**Overview**



This project analyzes employee data to understand workforce distribution, salary structure, and departmental performance using SQL. The dataset includes historical employee and salary records, requiring filtering to focus on current active employees.



**Data Preparation**



To ensure accurate analysis, only current employee and salary records were used:



Filtered active employees using:

to\_date = '9999-01-01'

Removed historical salary records to avoid duplication and inconsistency.





**Exploratory Analysis**

Key Analysis:

* Total employees per department
* Gender distribution across departments
* Hiring trends over time



**Insights**:

Certain departments have significantly higher employee counts, indicating workforce concentration

Gender distribution varies across departments, suggesting potential imbalance in workforce diversity

Hiring activity increased in later years, showing organizational growth trends.





**Salary Analysis**

Key Analysis:

* Average salary per department
* Salary distribution (High, Medium, Low)



**Insights**:

Most employees fall within the medium salary range, indicating a centralized compensation structure

Some departments have noticeably higher average salaries, suggesting specialized or high-value roles

Salary variation across departments highlights differences in job function and responsibility





**Advanced Insights**

Key Analysis:

* Top earners per department
* Percentage of employees earning above average salary
* Salary inequality (max vs min salary gap)



**Insights:**

A small proportion of employees earn above the company average salary, indicating income concentration

Certain departments show high salary inequality, suggesting uneven pay structures

Top salary levels are dominated by a few roles, indicating hierarchical compensation.





**Key Findings**

* Workforce distribution is uneven across departments
* Salary structures vary significantly depending on department
* Majority of employees earn within mid-level salary ranges
* A small percentage of employees account for top earnings





**Recommendations**

* Review departments with high salary inequality to ensure fair compensation
* Standardize salary bands where necessary to reduce imbalance
* Monitor hiring distribution to maintain workforce balance
* Conduct periodic salary reviews to align compensation with industry standards





**Tools Used**

* MySQL
* SQL (CTEs, Window Functions, Aggregations)

