CREATE DATABASE project;

USE project;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN Ã¯Â»Â¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;   

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;   

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

SET sql_mode = 'ALLOW_INVALID_DATES';

SELECT termdate FROM hr;
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());
SELECT birthdate, age FROM hr;

SELECT
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*) FROM hr WHERE age<18;

-- Gender breakdown
SELECT gender, count(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY gender;

-- Race/ethinicity breakdown
SELECT race, COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;

-- Age distribution
SELECT 
	min(age) AS youngest,
    max(age) AS oldest
 FROM hr
 WHERE age>=18 AND termdate = '0000-00-00';
 
 SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '44-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) AS count
FROM hr
 WHERE age>=18 AND termdate = '0000-00-00'
 GROUP BY age_group
 ORDER BY age_group;
 
 SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '44-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
    count(*) AS count
FROM hr
 WHERE age>=18 AND termdate = '0000-00-00'
 GROUP BY age_group, gender
 ORDER BY age_group, gender;
 
 -- location-wise breakdown
 SELECT location, count(*) AS count
 FROM hr
  WHERE age>=18 AND termdate = '0000-00-00'
  GROUP BY location;
  
  -- average length of employment
  SELECT
	round(avg(datediff(termdate, hire_date))/365,0) AS avg_len_emp
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age>= 18;

-- gender distribution across departments and job titles
SELECT department, gender, COUNT(*) AS count
FROM hr
 WHERE age>=18 AND termdate = '0000-00-00'
 GROUP BY department, gender
 ORDER BY department;
 
 -- distribution of job titles across company
 SELECT jobtitle, count(*) AS count
 FROM hr
  WHERE age>=18 AND termdate = '0000-00-00'
  GROUP BY jobtitle
  ORDER BY jobtitle DESC;
  
  -- department with highest turnover rate
  SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age>=18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;

-- distribution across locations 
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- change of employee count over time
SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100, 2) AS net_change_percent
FROM(
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) terminations
    FROM hr
    WHERE age>=18
    GROUP BY YEAR(hire_date)
    ) AS SUBQUERY
ORDER BY year ASC;

-- department-wise tenure distribution
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate<= curdate() AND termdate <> '0000-00-00' AND age>=18
GROUP BY department;