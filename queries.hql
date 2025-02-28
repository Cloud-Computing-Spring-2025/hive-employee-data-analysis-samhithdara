SELECT '------ Employees Who Joined After 2015 ------';
SELECT * FROM employees WHERE year(join_date) > 2015;

SELECT '------ Average Salary by Department ------';
SELECT department, AVG(salary) AS avg_salary  
FROM employees  
GROUP BY department;

SELECT '------ Employees Working on Alpha Project ------';
SELECT * FROM employees WHERE project = 'Alpha';

SELECT '------ Employee Count by Job Role ------';
SELECT job_role, COUNT(*) AS employee_count  
FROM employees  
GROUP BY job_role;

SELECT '------ Employees Earning Above Department Average ------';
SELECT emp_id, name, salary, department  
FROM employees e  
WHERE salary > (SELECT AVG(salary) FROM employees WHERE department = e.department);

SELECT '------ Department with Highest Number of Employees ------';
SELECT department, COUNT(*) AS employee_count  
FROM employees  
GROUP BY department  
ORDER BY employee_count DESC  
LIMIT 1;

SELECT '------ Employees with No NULL Values ------';
SELECT * FROM employees  
WHERE emp_id IS NOT NULL  
AND name IS NOT NULL  
AND age IS NOT NULL  
AND job_role IS NOT NULL  
AND salary IS NOT NULL  
AND project IS NOT NULL  
AND join_date IS NOT NULL  
AND department IS NOT NULL;

SELECT '------ Employee Details with Department Locations ------';
SELECT e.emp_id, e.name, e.job_role, e.salary, e.project, d.location  
FROM employees e  
JOIN departments d  
ON e.department = d.department_name;

SELECT '------ Employee Salary Ranking Within Each Department ------';
SELECT emp_id, name, department, salary,  
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank  
FROM employees;

SELECT '------ Top 3 Highest Paid Employees in Each Department ------';
SELECT emp_id, name, department, salary  
FROM (  
    SELECT emp_id, name, department, salary,  
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank  
    FROM employees  
) ranked  
WHERE rank <= 3;
