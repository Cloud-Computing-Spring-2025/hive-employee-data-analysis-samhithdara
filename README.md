# Hive Employee and Department Data Analysis 
**README.md** file for the **Hive Employee and Department Data Analysis** project.  

---

## Assignment Overview  
This assignment focuses on analyzing employee and department data using **Apache Hive**. It involves **loading datasets, transforming data, partitioning tables, and executing Hive queries** to extract meaningful insights such as salary analysis, job role distribution, employee ranking, and department-wise statistics.  

---


## Execution Steps  

### **1. Copy Dataset to Namenode Container**  
```bash
docker cp input_dataset namenode:/tmp/
```

### **2. Move Dataset to HDFS**  
```bash
hdfs dfs -mkdir -p /user/hive/warehouse/employees/
hdfs dfs -mkdir -p /user/hive/warehouse/departments/

hdfs dfs -put /tmp/input_dataset/employees.csv /user/hive/warehouse/employees/
hdfs dfs -put /tmp/input_dataset/departments.csv /user/hive/warehouse/departments/
```

### **3. Create Temporary Hive Tables and Load Data**  
```sql
CREATE TABLE employees_temp (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING,
    department STRING
)
ROW FORMAT DELIMITED  
FIELDS TERMINATED BY ','  
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hive/warehouse/employees/employees.csv' INTO TABLE employees_temp;
```

```sql
CREATE TABLE departments (
    dept_id INT,
    department_name STRING,
    location STRING
)
ROW FORMAT DELIMITED  
FIELDS TERMINATED BY ','  
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hive/warehouse/departments/departments.csv' INTO TABLE departments;
```

### **4. Create Partitioned Table and Insert Data**
```sql
CREATE TABLE employees (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING
)
PARTITIONED BY (department STRING)
ROW FORMAT DELIMITED  
FIELDS TERMINATED BY ','  
STORED AS TEXTFILE;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT INTO TABLE employees PARTITION (department)
SELECT emp_id, name, age, job_role, salary, project, join_date, department
FROM employees_temp;
```

---

## Hive Queries for Data Analysis  

### **1. Retrieve Employees Who Joined After 2015**  
```sql
SELECT '------ Employees Who Joined After 2015 ------';
SELECT * FROM employees WHERE year(join_date) > 2015;
```

### **2. Find the Average Salary of Employees in Each Department**  
```sql
SELECT '------ Average Salary by Department ------';
SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department;
```

### **3. Identify Employees Working on the 'Alpha' Project**  
```sql
SELECT '------ Employees Working on Alpha Project ------';
SELECT * FROM employees WHERE project = 'Alpha';
```

### **4. Count the Number of Employees in Each Job Role**  
```sql
SELECT '------ Employee Count by Job Role ------';
SELECT job_role, COUNT(*) AS employee_count FROM employees GROUP BY job_role;
```

### **5. Retrieve Employees Whose Salary is Above the Average Salary of Their Department**  
```sql
SELECT '------ Employees Earning Above Department Average ------';
SELECT emp_id, name, salary, department  
FROM employees e  
WHERE salary > (SELECT AVG(salary) FROM employees WHERE department = e.department);
```

### **6. Find the Department with the Highest Number of Employees**  
```sql
SELECT '------ Department with Highest Number of Employees ------';
SELECT department, COUNT(*) AS employee_count  
FROM employees  
GROUP BY department  
ORDER BY employee_count DESC  
LIMIT 1;
```

### **7. Check for Employees with NULL Values and Exclude Them**  
```sql
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
```

### **8. Join Employees and Departments Tables to Display Employee Details Along with Department Locations**  
```sql
SELECT '------ Employee Details with Department Locations ------';
SELECT e.emp_id, e.name, e.job_role, e.salary, e.project, d.location  
FROM employees e  
JOIN departments d  
ON e.department = d.department_name;
```

### **9. Rank Employees Within Each Department Based on Salary**  
```sql
SELECT '------ Employee Salary Ranking Within Each Department ------';
SELECT emp_id, name, department, salary,  
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank  
FROM employees;
```

### **10. Find the Top 3 Highest-Paid Employees in Each Department**  
```sql
SELECT '------ Top 3 Highest Paid Employees in Each Department ------';
SELECT emp_id, name, department, salary  
FROM (  
    SELECT emp_id, name, department, salary,  
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank  
    FROM employees  
) ranked  
WHERE rank <= 3;
```

---

## Output Storage and Redirection  

### **1.Store Query Results in a File**
```bash
hive -f /tmp/queries.hql > /tmp/hive_output.txt
```

### **2. View Query Results Inside the Hive Container**
```bash
cat /tmp/hive_output.txt
```

### **3. Copy Query Results to Local Machine**
```bash
docker cp hive-server:/tmp/hive_output.txt ./hive_output.txt
```


This README provides **clear execution steps, query explanations**