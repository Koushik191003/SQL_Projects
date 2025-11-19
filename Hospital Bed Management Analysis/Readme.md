# Hospital Bed Management Analysis
## Description

This project uses SQL to explore key hospital datasets, including patients, staff, and services.It performs data cleaning, trend analysis, and KPI calculation for operational insights.Queries help identify high-usage services and attendance behavior across departments.The final results support informed decision-making for hospital management.

## Data Aggregation
### Create the Database
Query :
````sql
CREATE DATABASE Hospital_Management;
USE HOSPITAL_MANAGEMENT;
````
### Import Datasets : Patients , services_weekly , staff , staff_schedule & Analyze the Fact table and Dimension table. 

Query :
````sql
SELECT * FROM PATIENTS LIMIT 5;
````
Result:

<img width="616" height="120" alt="image" src="https://github.com/user-attachments/assets/7ae82d35-7436-40a7-b652-74eeed63cd9b" />

Query :
````sql
SELECT * FROM STAFF LIMIT 5;
````
Result:

<img width="452" height="122" alt="image" src="https://github.com/user-attachments/assets/ef94df71-d5e1-4109-8ad6-29a1079c895d" />

Query :
````sql
SELECT * FROM SERVICES_WEEKLY LIMIT 5;
````
Result:

<img width="864" height="125" alt="image" src="https://github.com/user-attachments/assets/cc70b1ac-588a-42b5-889f-06e517787760" />

Query :
````sql
SELECT * FROM STAFF_SCHEDULE LIMIT 5;
````
Result:

<img width="420" height="127" alt="image" src="https://github.com/user-attachments/assets/163ff467-6733-490c-8895-48c053035a82" />

### DATA CLEANING PROCESS
### 1. Check Main column null values for all table.

Query :
````sql
SELECT SUM(CASE WHEN PATIENT_ID IS NULL THEN 1 END) AS NULL_PATIENT_ID,
       SUM(CASE WHEN NAME IS NULL THEN 1 END) AS NULL_NAME,
       SUM(CASE WHEN AGE IS NULL THEN 1 END) AS NULL_AGE
FROM PATIENTS;
````
Result:

<img width="300" height="50" alt="image" src="https://github.com/user-attachments/assets/0eefda2e-104b-477a-952c-6d23ab8c12b7" />

Query :
````sql
SELECT SUM(CASE WHEN STAFF_ID IS NULL THEN 1 END) AS NULL_STAFF_ID,
	   SUM(CASE WHEN STAFF_NAME IS NULL THEN 1 END) AS NULL_STAFF_NAME,
	   SUM(CASE WHEN ROLE IS NULL THEN 1 END) AS NULL_ROLE
FROM STAFF;
````
Result:

<img width="320" height="50" alt="image" src="https://github.com/user-attachments/assets/6debe451-8778-4578-8a5d-6d99650868cd" />

Query :
````sql
SELECT  SUM(CASE WHEN WEEK IS NULL THEN 1 END) AS NULL_WEEK,
		SUM(CASE WHEN MONTH IS NULL THEN 1 END) AS NULL_MONTH,
		SUM(CASE WHEN SERVICE IS NULL THEN 1 END) AS NULL_SERVICE
FROM SERVICES_WEEKLY;
````
Result:

<img width="294" height="52" alt="image" src="https://github.com/user-attachments/assets/73ed81ed-976a-4726-ada5-b5425af9d649" />

Query :
````sql
SELECT SUM(CASE WHEN WEEK IS NULL THEN 1 END) AS NULL_WEEK,
	   SUM(CASE WHEN STAFF_ID IS NULL THEN 1 END) AS NULL_STAFF_ID,
       SUM(CASE WHEN PRESENT IS NULL THEN 1 END) AS NULL_PRESENT
FROM STAFF_SCHEDULE;
````
Result:

<img width="304" height="48" alt="image" src="https://github.com/user-attachments/assets/14b48e71-fdac-401a-87ae-05cde0ae60dd" />

### 2. Check Duplicates for main tables.

PATIENT DUPLICATES

Query :
````sql
SELECT PATIENT_ID, COUNT(*)
FROM PATIENTS
GROUP BY PATIENT_ID
HAVING COUNT(*) > 1;
````
Result:

<img width="186" height="46" alt="image" src="https://github.com/user-attachments/assets/6877778c-0b35-4ab0-882c-c5bd4ab30a64" />

STAFF DUPLICATES

Query :
````sql
SELECT STAFF_ID, COUNT(*)
FROM STAFF
GROUP BY STAFF_ID
HAVING COUNT(*) > 1;
````
Result:

<img width="180" height="49" alt="image" src="https://github.com/user-attachments/assets/7003fb69-87e6-4856-995a-39aaf06b3acb" />

### 3. Validate date ranges

Query :
````sql
SELECT *
FROM PATIENTS
WHERE DEPARTURE_DATE < ARRIVAL_DATE;
````
Result:

<img width="480" height="48" alt="image" src="https://github.com/user-attachments/assets/ce371c3c-5381-4a76-beec-fbd2b4ebee17" />

### 4. Check the Validate foreign keys (Service names matching)

Query :
````sql
SELECT DISTINCT P.SERVICE
FROM PATIENTS AS P
LEFT JOIN SERVICES_WEEKLY AS S ON P.SERVICE = S.SERVICE
WHERE S.SERVICE IS NULL;
````
Result:

<img width="112" height="53" alt="image" src="https://github.com/user-attachments/assets/65d934c3-fb88-4bd4-9933-1943a8767ed7" />

## BASIC ANALYSIS QUERIES
### 1. Total Patients per Service

Query :
````sql
SELECT SERVICE, COUNT(*) AS TOTAL_PATIENTS
FROM PATIENTS
GROUP BY SERVICE
ORDER BY TOTAL_PATIENTS DESC;
````
Result:

<img width="247" height="103" alt="image" src="https://github.com/user-attachments/assets/3f7d0a33-8ca5-46c7-b9a2-f053fb963cb6" />

### 2. Avg Satisfaction by Service

Query :
````sql
SELECT  SERVICE, 
		ROUND(AVG(SATISFACTION),2) AS AVG_SATISFACTION
FROM PATIENTS
GROUP BY SERVICE
ORDER BY AVG_SATISFACTION DESC;
````
Result:

<img width="254" height="102" alt="image" src="https://github.com/user-attachments/assets/19d8e36f-5782-4262-92b8-8dea50ade106" />

### 3. Average Length of Stay

Query :
````sql
SELECT SERVICE,
       FLOOR(AVG(DATEDIFF(DEPARTURE_DATE, ARRIVAL_DATE))) AS AVG_LOS
FROM PATIENTS
GROUP BY SERVICE;
````
Result:

<img width="203" height="104" alt="image" src="https://github.com/user-attachments/assets/e5803027-c7b3-4fc6-bc62-9b24d6303a8c" />

### 4. Top 10 low bed used weeks.

Query :
````sql
SELECT WEEK, 
	   SERVICE,
       ROUND((PATIENTS_ADMITTED / AVAILABLE_BEDS) * 100, 2) AS UTILIZATION_PERCENT
FROM SERVICES_WEEKLY
WHERE (PATIENTS_ADMITTED / AVAILABLE_BEDS) * 100 < 100
ORDER BY WEEK ASC
LIMIT 10;
````
Result:

<img width="274" height="199" alt="image" src="https://github.com/user-attachments/assets/f93b52b7-b7d5-4462-b225-9bb4fc88dbc9" />

### 5. Staff Attendance % by Service

Query :
````sql
SELECT SERVICE,
       SUM(PRESENT) AS DAYS_PRESENT,
       COUNT(*) AS TOTAL_DAYS,
       ROUND((SUM(PRESENT) / COUNT(*)) * 100, 2) AS ATTENDANCE_PERCENT
FROM STAFF_SCHEDULE
GROUP BY SERVICE;
````
Result:

<img width="450" height="101" alt="image" src="https://github.com/user-attachments/assets/44ff6e44-ea48-4660-89ae-9e5abf272717" />

## COMPLEX ANALYSIS USING JOINS
### 1. Service-Wise Totalcount Patients and Staff 

Query :
````sql
SELECT P.SERVICE,
       COUNT(DISTINCT P.PATIENT_ID) AS TOTAL_PATIENTS,
       COUNT(DISTINCT S.STAFF_ID) AS TOTAL_STAFF
FROM  PATIENTS AS P 
LEFT JOIN STAFF AS S ON P.SERVICE = S.SERVICE
GROUP BY P.SERVICE;
````
Result:

<img width="327" height="100" alt="image" src="https://github.com/user-attachments/assets/080ede10-5c64-4638-a231-ad4d0ba99080" />

### 2. Top 10 Excess Bed Requests

Query :
````sql
SELECT SERVICE, 
       WEEK,
       PATIENTS_REQUEST, 
       AVAILABLE_BEDS,
       (PATIENTS_REQUEST - AVAILABLE_BEDS) AS EXCESS_REQUESTS
FROM SERVICES_WEEKLY
WHERE PATIENTS_REQUEST > AVAILABLE_BEDS
ORDER BY EXCESS_REQUESTS DESC
LIMIT 10;
````
Result:

<img width="512" height="204" alt="image" src="https://github.com/user-attachments/assets/8f80d6ae-0ec7-42c8-a6eb-5294145a2a52" />

### 3. Lowest Satisfaction Patients Under Nurse

Query :
````sql
SELECT P.NAME ,
	   S.STAFF_NAME ,
	   S.SERVICE ,
       P.SATISFACTION
FROM STAFF AS S
LEFT JOIN PATIENTS AS P ON S.SERVICE = P.SERVICE
WHERE ROLE = 'NURSE' 
ORDER BY SATISFACTION ASC
LIMIT 10;
````
Result:

<img width="447" height="206" alt="image" src="https://github.com/user-attachments/assets/b2f28e30-8446-42ed-8fd1-aacaffc7e6a5" />

### 4. Patients Assigned to Each Doctor

Query :
````sql
SELECT S.STAFF_NAME AS DOCTOR, 
       S.SERVICE,
       COUNT(P.PATIENT_ID) AS TOTAL_PATIENTS
FROM STAFF S
JOIN PATIENTS P ON S.SERVICE = P.SERVICE
WHERE S.ROLE = 'DOCTOR'
GROUP BY S.STAFF_NAME, S.SERVICE;
````
Result:

<img width="371" height="337" alt="image" src="https://github.com/user-attachments/assets/c49a9724-b14e-4e07-b9e7-416e957f9fd8" />

## WINDOW FUNCTION QUERIES
### 1. Rank Services by Satisfaction per Month

Query :
````sql
	   SERVICE, 
       PATIENT_SATISFACTION,
       RANK() OVER ( PARTITION BY MONTH 
					 ORDER BY PATIENT_SATISFACTION DESC
				   ) AS SATISFACTION_RANK
FROM SERVICES_WEEKLY;
````
Result:

<img width="451" height="385" alt="image" src="https://github.com/user-attachments/assets/ecd5023f-3b8c-41e2-8057-09cfd122ee11" />

### 2. Dense Rank for Refused Patients

Query :
````sql
SELECT MONTH,
       SERVICE,
       PATIENTS_REFUSED,
       DENSE_RANK() OVER ( PARTITION BY MONTH
						   ORDER BY PATIENTS_REFUSED DESC
						 ) AS REFUSAL_RANK
FROM SERVICES_WEEKLY;
````
Result:

<img width="404" height="367" alt="image" src="https://github.com/user-attachments/assets/25a26e72-b385-424f-bf93-8bfcc10b361a" />

### 3. Staff Presence Percentage per Week

Query :
````sql
SELECT WEEK,
       STAFF_ID,
       PRESENT,
       ROUND(
           AVG(PRESENT) OVER (
               PARTITION BY STAFF_ID
               ORDER BY WEEK
           ) * 100, 2
       ) AS PRESENCE_PERCENT
FROM STAFF_SCHEDULE;
````
Result:

<img width="341" height="314" alt="image" src="https://github.com/user-attachments/assets/1d5ee8fe-0565-4a50-b498-0c06563b3c39" />

## STORED PROCEDURE
### 1. Average Patient Satisfaction by Service

Stored Procedure :
````sql
CREATE PROCEDURE `Avg_Satisfaction` (IN svc VARCHAR(50))
BEGIN
	SELECT SERVICE,
           AVG(SATISFACTION) AS AVG_SATISFACTION
    FROM PATIENTS
    WHERE SERVICE = svc
    GROUP BY SERVICE;
END
````

Query :
````sql
CALL Avg_Satisfaction('ICU');
````

Result:

<img width="214" height="54" alt="image" src="https://github.com/user-attachments/assets/dda2815c-85ae-4fb5-b525-eaf70eb3dfac" />

### 2. Patients Who Stayed More Than 'N' Days

Stored Procedure :
````sql
CREATE PROCEDURE `LongStayPatients` (IN minDays INT)
BEGIN
	SELECT PATIENT_ID, 
           NAME, 
           SERVICE,
           DATEDIFF(DEPARTURE_DATE, ARRIVAL_DATE) AS DAYS_STAYED
    FROM PATIENTS
    WHERE DATEDIFF(DEPARTURE_DATE, ARRIVAL_DATE) > minDays;
END
````

Query :
````sql
CALL LongStayPatients(10);
````

Result:

<img width="414" height="382" alt="image" src="https://github.com/user-attachments/assets/c54f4e73-ac41-427d-986f-f09e777a5baf" />

### 3. Monthly Admissions Based on Service

Stored Procedure :
````sql
CREATE PROCEDURE `MonthlyAdmissions` (IN monthNo INT)
BEGIN
	SELECT MONTH,
           SERVICE,
           SUM(PATIENTS_ADMITTED) AS TOTAL_ADMITTED,
           SUM(PATIENTS_REFUSED) AS TOTAL_REFUSED
    FROM SERVICES_WEEKLY
    WHERE MONTH = monthNo
    GROUP BY MONTH, SERVICE
    ORDER BY TOTAL_ADMITTED DESC;
END
````

Query :
````sql
CALL MonthlyAdmissions(2);
````

Result:

<img width="399" height="101" alt="image" src="https://github.com/user-attachments/assets/285bd3f8-6597-4759-b64b-dc19e0efd82b" />

## CONCLUSION

In conclusion, the SQL analysis highlights several important operational insights for the hospital.

- The SQL analysis provided clear insights into patient flow, service demand, and hospital operational trends.
- Staff attendance and scheduling patterns revealed areas where efficiency can be improved.
- High-demand services were identified, helping support better resource planning and allocation.
- Data cleaning and transformation steps ensured accurate, reliable, and analysis-ready datasets.
- Overall, the project demonstrated how SQL can be used to support data-driven decision-making in hospital management.











