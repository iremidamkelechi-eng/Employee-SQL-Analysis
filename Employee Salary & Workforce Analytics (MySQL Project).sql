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


You’re improving — but this answer would still get pushed hard in an interview. I’ll break it down cleanly so you see exactly where you’re solid and where you’re leaking marks.

🔍 PART 1 — Your Query
❌ First Line (Already off target)
SELECT COUNT(DISTINCT emp_no) AS total_employee 
FROM employees;

👉 Problem:

This answers: “How many employees exist?”

The question was:

“For each gender: total employees AND those above average”

👉 You ignored:

Gender ❌
Above-average grouping ❌
❌ Main Query Issues
WHERE cs.current_salary > ac.Avg_salary;

👉 This column does not exist

Should be:

cs.salary
❌ Bigger Logical Miss

You returned:

SELECT cs.emp_no, cs.first_name...

👉 That gives rows of employees

But the question asked for:

counts per gender

👉 You didn’t aggregate ❌

✅ Correct Version (What Interviewer Expects)
WITH current_salary AS (
    SELECT 
        e.emp_no,
        e.gender,
        s.salary
    FROM employees e
    JOIN salaries s
        ON e.emp_no = s.emp_no
    WHERE s.to_date = '9999-01-01'
),

avg_salary AS (
    SELECT AVG(salary) AS avg_sal
    FROM current_salary
)

SELECT 
    cs.gender,
    COUNT(DISTINCT cs.emp_no) AS total_employees,
    SUM(CASE 
            WHEN cs.salary > a.avg_sal THEN 1 
            ELSE 0 
        END) AS above_avg
FROM current_salary cs
CROSS JOIN avg_salary a
GROUP BY cs.gender;
🧠 What You Missed

👉 You didn’t combine:

Aggregation
CASE
Grouping

👉 This is core analyst thinking

🔥 PART 2 — Your Explanation (DENSE_RANK)

You said:

“Row_Number would not work…”

👉 This is too weak

❌ Why It’s Weak

You explained:

What happens ❌
But not:
Why it matters
✅ Strong Answer

“DENSE_RANK is appropriate when ranking salary levels because it assigns the same rank to equal values without skipping ranks. This ensures that we capture distinct salary tiers rather than individual row positions, which is what ROW_NUMBER would produce.”

🔥 PART 3 — Your Final Answer (Critical)

You said:

“Yes they will always have same rank”

👉 ⚠️ This is where I push you.

❌ That answer is incomplete

It assumes:

Only salary matters

✅ Correct Thinking

“They will have the same rank only if the ORDER BY column(s) are identical. If additional columns are included in the ORDER BY, then even with the same salary, they may receive different ranks.”

🔥 Example
DENSE_RANK() OVER (ORDER BY salary DESC)

👉 Same salary → same rank ✅

DENSE_RANK() OVER (ORDER BY salary DESC, emp_no)

👉 Now:

salary same
emp_no different

👉 Different rank ❗

🚨 Brutal Assessment
Area	Score
SQL Writing	7.5/10
Question Interpretation	5/10 ❌
Analytical Thinking	6/10
Precision	6/10
🔥 What’s Holding You Back

You:

Understand tools ✅
But sometimes don’t align answer to the question ❌

👉 That’s the difference between:

“knows SQL”
“gets hired”
🎯 Next Step (We Push Harder)
New Question (Real Interview Level)

👉 “For each gender, find the percentage of employees earning above the average salary.”

⚠️ Requirements:

Use current salaries
Avoid duplicates
Return:
gender
percentage

This one forces:

Aggregation
CASE
Math
Clean thinking

Take your time — but don’t be sloppy.

give me 20 queries to solve in my portfolio. remeber i also have departments as part of my table and also have departments, dept_emp as department have just department number and departments, they is salaries table also as you know. i also have in my database dept_manager and dept_emp_latest_date. keep the queries professional and high standard as we have been learning

Good — this is the right move. But I’m not giving you random queries.
These are portfolio-grade, meaning:

They reflect real business questions
They force you to combine concepts
They expose weak thinking if you try to shortcut
🔥 STRUCTURE

I’ve grouped them by level:

Level 1 — Solid Analyst (Foundation done right)
Level 2 — Intermediate (Joins + Logic)
Level 3 — Advanced (Window + CTE + Thinking)
🟢 LEVEL 1 — FOUNDATION (Don’t rush these)
1

👉 Total number of employees per department

2

👉 Number of male vs female employees per department

3

👉 Average salary per department (current salaries only)

4

👉 Highest salary in each department

5

👉 Lowest salary in each department

6

👉 Number of employees hired after 2000 per department

7

👉 Count of employees currently working (use dept_emp.to_date)

🟡 LEVEL 2 — INTERMEDIATE (This is where thinking starts)
8

👉 Employees earning above company average salary

9

👉 Employees earning above their department average salary

⚠️ This separates beginners from analysts

10

👉 Departments with average salary above company average

11

👉 Top 5 highest paid employees in each department

12

👉 Employees who have changed departments more than once

13

👉 Current department managers and their salaries

14

👉 Departments with more than 100 employees

15

👉 Employees whose salary is below their department average

🔴 LEVEL 3 — ADVANCED (Portfolio-worthy)
16

👉 Top 3 salary levels per department (handle ties correctly)

17

👉 Percentage of employees earning above average salary per department

18

👉 Rank employees by salary within each department and show only top 10%

⚠️ Requires window + math thinking

19

👉 Find salary distribution:

High (>80k)
Medium (50k–80k)
Low (<50k)

Per department

20

👉 Identify departments with salary inequality

👉 Hint:

Compare max vs min salary per department
🔥 BONUS (If you want to stand out)
21 (Optional but powerful)

👉 Find employees who earn more than their manager

🚨 Brutal Truth

If you can:

Solve all 20 cleanly
Explain your logic

👉 You’re ready for real interviews

If you:

Copy patterns
Skip edge cases

👉 You’ll get exposed fast

🎯 How I Want You To Work

Don’t do all at once.

Do:

3–4 queries
Send answers
I tear them apart
You fix
🔥 First Assignment

Start with:

👉 9, 11, 17

These will test:

Subqueries
Window functions
CASE + aggregation

When you’re done, send them.

I’ll review like an interviewer — not a teacher.

write the query for the 20, professionally and high standard as we have been learning. im using this for a research work and im out of time

Alright — since you’re under time pressure, I’ll give you clean, production-level SQL.
But don’t just submit this blindly. If you can’t explain each one, you’ll get exposed.

🔥 ASSUMPTION (IMPORTANT)
salaries.to_date = '9999-01-01' → current salary
dept_emp.to_date = '9999-01-01' → current department
🟢 LEVEL 1
1. Total employees per department
SELECT d.dept_name, COUNT(DISTINCT de.emp_no) AS total_employees
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
WHERE de.to_date = '9999-01-01'
GROUP BY d.dept_name;
2. Male vs Female per department
SELECT d.dept_name, e.gender, COUNT(*) AS total
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
WHERE de.to_date = '9999-01-01'
GROUP BY d.dept_name, e.gender;
3. Avg salary per department
SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;
4. Highest salary per department
SELECT d.dept_name, MAX(s.salary) AS highest_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;
5. Lowest salary per department
SELECT d.dept_name, MIN(s.salary) AS lowest_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;
6. Employees hired after 2000 per department
SELECT d.dept_name, COUNT(*) AS total
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
WHERE e.hire_date > '2000-01-01'
AND de.to_date = '9999-01-01'
GROUP BY d.dept_name;
7. Current employees count
SELECT COUNT(DISTINCT emp_no) AS current_employees
FROM dept_emp
WHERE to_date = '9999-01-01';
🟡 LEVEL 2
8. Employees above company average
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
9. Employees above department average
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
10. Departments above company avg salary
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
11. Top 5 earners per department
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
12. Employees who changed departments more than once
SELECT emp_no, COUNT(DISTINCT dept_no) AS dept_count
FROM dept_emp
GROUP BY emp_no
HAVING dept_count > 1;
13. Current managers and salaries
SELECT d.dept_name, e.emp_no, s.salary
FROM dept_manager dm
JOIN departments d ON dm.dept_no = d.dept_no
JOIN employees e ON dm.emp_no = e.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE dm.to_date = '9999-01-01'
AND s.to_date = '9999-01-01';
14. Departments with more than 100 employees
SELECT dept_no, COUNT(*) AS total
FROM dept_emp
WHERE to_date = '9999-01-01'
GROUP BY dept_no
HAVING total > 100;
15. Employees below department avg
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
🔴 LEVEL 3
16. Top 3 salary levels per department
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


-- 17. % above avg per department

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
SELECT 
    cs.dept_no,
    ROUND(
        SUM(CASE WHEN cs.salary > da.avg_salary THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2
    ) AS percentage_above_avg
FROM cs
JOIN dept_avg da ON cs.dept_no = da.dept_no
GROUP BY cs.dept_no;

-- 18. Top 10% earners per department

WITH ranked AS (
    SELECT 
        de.dept_no,
        e.emp_no,
        s.salary,
        NTILE(10) OVER (
            PARTITION BY de.dept_no
            ORDER BY s.salary DESC
        ) AS percentile
    FROM dept_emp de
    JOIN employees e ON de.emp_no = e.emp_no
    JOIN salaries s ON e.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
)
SELECT *
FROM ranked
WHERE percentile = 1;


-- 19. Salary distribution per department

WITH cs AS (
    SELECT de.dept_no, s.salary
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01'
)
SELECT 
    dept_no,
    SUM(CASE WHEN salary > 80000 THEN 1 ELSE 0 END) AS high,
    SUM(CASE WHEN salary BETWEEN 50000 AND 80000 THEN 1 ELSE 0 END) AS medium,
    SUM(CASE WHEN salary < 50000 THEN 1 ELSE 0 END) AS low
FROM cs
GROUP BY dept_no;


-- 20. Salary inequality per department

SELECT 
    d.dept_name,
    MAX(s.salary) AS max_salary,
    MIN(s.salary) AS min_salary,
    MAX(s.salary) - MIN(s.salary) AS salary_gap
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;