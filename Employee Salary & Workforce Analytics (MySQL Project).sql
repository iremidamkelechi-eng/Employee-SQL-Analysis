--  1. Total employees per department

SELECT d.dept_name, COUNT(DISTINCT de.emp_no) AS total_employees
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
WHERE de.to_date = '9999-01-01'
GROUP BY d.dept_name;
  
  --  2. Male vs Female per department
  
SELECT d.dept_name, e.gender, COUNT(*) AS total
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
WHERE de.to_date = '9999-01-01'
GROUP BY d.dept_name, e.gender;


  --  3. Avgerage salary per department

SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;


  --  4. Highest salary per department

SELECT d.dept_name, MAX(s.salary) AS highest_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;

  --  5. Lowest salary per department
  
SELECT d.dept_name, MIN(s.salary) AS lowest_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;


  -- 6. Employees hired after year 2000 per department
  
SELECT d.dept_name, COUNT(*) AS total
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
WHERE e.hire_date > '2000-01-01'
AND de.to_date = '9999-01-01'
GROUP BY d.dept_name;


  -- 7. Current employees count
  
SELECT COUNT(DISTINCT emp_no) AS current_employees
FROM dept_emp
WHERE to_date = '9999-01-01';


  -- 8. Employees above company average
  
 WITH cs AS (
    SELECT emp_no, salary
    FROM salaries
    WHERE to_date = '9999-01-01'
),
avg_sal AS (
    SELECT AVG(salary) AS avg_salary FROM cs
)
SELECT *
FROM cs
CROSS JOIN avg_sal
WHERE cs.salary > avg_sal.avg_salary;


  -- 9. Employees above department average
  
  
WITH cs AS (
    SELECT de.emp_no, de.dept_no, s.salary
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
),
dept_avg AS (
    SELECT dept_no, AVG(salary) AS avg_salary
    FROM cs
    GROUP BY dept_no
)
SELECT cs.*
FROM cs
JOIN dept_avg da ON cs.dept_no = da.dept_no
WHERE cs.salary > da.avg_salary;


  
  -- 10. Departments above company avg salary
  
  WITH cs AS (
    SELECT de.dept_no, s.salary
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
),
company_avg AS (
    SELECT AVG(salary) AS avg_sal FROM cs
),
dept_avg AS (
    SELECT dept_no, AVG(salary) AS avg_salary
    FROM cs
    GROUP BY dept_no
)
SELECT d.dept_name, da.avg_salary
FROM dept_avg da
JOIN departments d ON da.dept_no = d.dept_no
CROSS JOIN company_avg ca
WHERE da.avg_salary > ca.avg_sal;


  
  --  11. Top 5 earners per department
  
WITH ranked AS (
    SELECT 
        de.dept_no,
        e.emp_no,
        s.salary,
        ROW_NUMBER() OVER (
            PARTITION BY de.dept_no
            ORDER BY s.salary DESC
        ) AS rn
    FROM dept_emp de
    JOIN employees e ON de.emp_no = e.emp_no
    JOIN salaries s ON e.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
)
SELECT *
FROM ranked
WHERE rn <= 5;


  -- 12. Employees who changed departments more than once
  
SELECT emp_no, COUNT(DISTINCT dept_no) AS dept_count
FROM dept_emp
GROUP BY emp_no
HAVING dept_count > 1;


  -- 13. Current managers and salaries
  
  
SELECT d.dept_name, e.emp_no, s.salary
FROM dept_manager dm
JOIN departments d ON dm.dept_no = d.dept_no
JOIN employees e ON dm.emp_no = e.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE dm.to_date = '9999-01-01'
AND s.to_date = '9999-01-01';


  --  14.Departments with more than 100 employees
  
  
SELECT dept_no, COUNT(*) AS total
FROM dept_emp
WHERE to_date = '9999-01-01'
GROUP BY dept_no
HAVING total > 100;
  
  
  -- 15. Employees below department average
  
  WITH cs AS (
    SELECT de.emp_no, de.dept_no, s.salary
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
),
dept_avg AS (
    SELECT dept_no, AVG(salary) AS avg_salary
    FROM cs
    GROUP BY dept_no
)
SELECT cs.*
FROM cs
JOIN dept_avg da ON cs.dept_no = da.dept_no
WHERE cs.salary < da.avg_salary;


-- 16. Top 3 salary levels per department

WITH cs AS (
    SELECT de.dept_no, s.salary
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
),
ranked AS (
    SELECT 
        dept_no,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_no
            ORDER BY salary DESC
        ) AS rnk
    FROM cs
)
SELECT *
FROM ranked
WHERE rnk <= 3;


