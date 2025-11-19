-- Create the Database 

CREATE DATABASE Hospital_Management;
USE HOSPITAL_MANAGEMENT;

-- Import Datasets : Patients , services_weekly , staff , staff_schedule & Analyze the Fact table and Dimension table. 

SELECT * FROM PATIENTS LIMIT 5;

/*
	Result :
    PATIENT_ID   |       NAME 		  | AGE | ARRIVAL_DATE | DEPARTURE_DATE |    SERVICE       | SATISFACTION |  
     
    PAT-09484753 |	Richard Rodriguez |	24	| 2025-03-16   | 2025-03-22		| surgery		   |    61		  |
	PAT-f0644084 |	Shannon Walker	  |	6	| 2025-12-13   |  2025-12-14	| surgery	       |    83		  |
	PAT-ac6162e4 |	Julia Torres	  | 24	| 2025-06-29   |  2025-07-05	| general_medicine |    83		  |
	PAT-3dda2bb5 |	Crystal Johnson	  | 32	| 2025-10-12   |  2025-10-23	| emergency	       |    81		  |
	PAT-08591375 |	Garrett Lin	      | 25	| 2025-02-18   |  2025-02-25	| ICU	           |    76 		  |
*/

SELECT * FROM STAFF LIMIT 5;

/*
	Result :
    STAFF_ID     |    STAFF_NAME    | ROLE   | SERVICE   |   
     
    STF-5ca26577 |	Allison Hill	| doctor | emergency |
	STF-02ae59ca |	Noah Rhodes		| doctor | emergency |
	STF-d8006e7c |	Angie Henderson	| doctor | emergency |
	STF-212d8b31 |	Daniel Wagner	| doctor | emergency |
	STF-107a58e4 |	Cristian Santos	| doctor | emergency |
*/

SELECT * FROM SERVICES_WEEKLY LIMIT 5;

/*
	Result :
    WEEK | MONTH |   SERVICE       | AVALIABLE_BEDS | PATIENTS_REQUEST | PATIENTS_ADMITTED  | PATIENTS_FEFUSED  | PATIENTS_SATISFACTION | STAFF_MORALE  | EVENT | 
     
     1	 |   1	 | emergency	   |     32			|		76		   |		32			|		44			|		  67			|	  70		| none  |
	 1	 |   1	 | surgery	       |     45			|		130		   |		45			|		85			|		  83			|	  78		| flu   |
	 1	 |   1	 | general_medicine|     37			|		01		   |		37			|		164			|		  97			|	  43		| flu   |
	 1	 |   1	 | ICU			   |     22			|		31		   |		22			|		9			|		  84			|	  91		| flu   |
	 2	 |   1	 | emergency	   |     28			|		169		   |		28			|		141			|		  75			|	  64		| none  |
*/

SELECT * FROM STAFF_SCHEDULE LIMIT 5;

/*
	Result :
	WEEK |   STAFF_ID   |  STAFF_NAME  |  ROLE  |  SERVICE  | PRESENT |
     
     1	 | STF-b77cdc60	| Allison Hill | doctor	| emergency	|   1	  |
	 2	 | STF-b77cdc60	| Allison Hill | doctor	| emergency	|   1     |
	 3	 | STF-b77cdc60	| Allison Hill | doctor	| emergency	|   0     |
	 4	 | STF-b77cdc60	| Allison Hill | doctor	| emergency	|   1     |
	 5	 | STF-b77cdc60	| Allison Hill | doctor	| emergency	|   1     |
*/

-- DATA CLEANING PROCESS

-- 1. Check Main column null values for all table.

SELECT SUM(CASE WHEN PATIENT_ID IS NULL THEN 1 END) AS NULL_PATIENT_ID,
       SUM(CASE WHEN NAME IS NULL THEN 1 END) AS NULL_NAME,
       SUM(CASE WHEN AGE IS NULL THEN 1 END) AS NULL_AGE
FROM PATIENTS;

SELECT SUM(CASE WHEN STAFF_ID IS NULL THEN 1 END) AS NULL_STAFF_ID,
	   SUM(CASE WHEN STAFF_NAME IS NULL THEN 1 END) AS NULL_STAFF_NAME,
	   SUM(CASE WHEN ROLE IS NULL THEN 1 END) AS NULL_ROLE
FROM STAFF;

SELECT  SUM(CASE WHEN WEEK IS NULL THEN 1 END) AS NULL_WEEK,
		SUM(CASE WHEN MONTH IS NULL THEN 1 END) AS NULL_MONTH,
		SUM(CASE WHEN SERVICE IS NULL THEN 1 END) AS NULL_SERVICE
FROM SERVICES_WEEKLY;

SELECT SUM(CASE WHEN WEEK IS NULL THEN 1 END) AS NULL_WEEK,
	   SUM(CASE WHEN STAFF_ID IS NULL THEN 1 END) AS NULL_STAFF_ID,
       SUM(CASE WHEN PRESENT IS NULL THEN 1 END) AS NULL_PRESENT
FROM STAFF_SCHEDULE;

-- 2. Check Duplicates for main tables.

-- PATIENT DUPLICATES
SELECT PATIENT_ID, COUNT(*)
FROM PATIENTS
GROUP BY PATIENT_ID
HAVING COUNT(*) > 1;

-- STAFF DUPLICATES
SELECT STAFF_ID, COUNT(*)
FROM STAFF
GROUP BY STAFF_ID
HAVING COUNT(*) > 1;

-- 3. Validate date ranges
SELECT *
FROM PATIENTS
WHERE DEPARTURE_DATE < ARRIVAL_DATE;

-- 4. Check the Validate foreign keys (Service names matching)
SELECT DISTINCT P.SERVICE
FROM PATIENTS AS P
LEFT JOIN SERVICES_WEEKLY AS S ON P.SERVICE = S.SERVICE
WHERE S.SERVICE IS NULL;

-- BASIC ANALYSIS QUERIES

-- 1. Total Patients per Service
SELECT SERVICE, COUNT(*) AS TOTAL_PATIENTS
FROM PATIENTS
GROUP BY SERVICE
ORDER BY TOTAL_PATIENTS DESC;

-- 2. Avg Satisfaction by Service
SELECT  SERVICE, 
		ROUND(AVG(SATISFACTION),2) AS AVG_SATISFACTION
FROM PATIENTS
GROUP BY SERVICE
ORDER BY AVG_SATISFACTION DESC;

-- 3. Average Length of Stay
SELECT SERVICE,
       FLOOR(AVG(DATEDIFF(DEPARTURE_DATE, ARRIVAL_DATE))) AS AVG_LOS
FROM PATIENTS
GROUP BY SERVICE;

-- 4. Top 10 low bed used weeks.
SELECT WEEK, 
	   SERVICE,
       ROUND((PATIENTS_ADMITTED / AVAILABLE_BEDS) * 100, 2) AS UTILIZATION_PERCENT
FROM SERVICES_WEEKLY
WHERE (PATIENTS_ADMITTED / AVAILABLE_BEDS) * 100 < 100
ORDER BY WEEK ASC
LIMIT 10;

-- 5. Staff Attendance % by Service
SELECT SERVICE,
       SUM(PRESENT) AS DAYS_PRESENT,
       COUNT(*) AS TOTAL_DAYS,
       ROUND((SUM(PRESENT) / COUNT(*)) * 100, 2) AS ATTENDANCE_PERCENT
FROM STAFF_SCHEDULE
GROUP BY SERVICE;

-- COMPLEX ANALYSIS + JOIN QUERIES

-- 1. Service-Wise Totalcount Patients and Staff 
SELECT P.SERVICE,
       COUNT(DISTINCT P.PATIENT_ID) AS TOTAL_PATIENTS,
       COUNT(DISTINCT S.STAFF_ID) AS TOTAL_STAFF
FROM  PATIENTS AS P 
LEFT JOIN STAFF AS S ON P.SERVICE = S.SERVICE
GROUP BY P.SERVICE;

-- 2. Top 10 Excess Bed Requests
SELECT SERVICE, 
       WEEK,
       PATIENTS_REQUEST, 
       AVAILABLE_BEDS,
       (PATIENTS_REQUEST - AVAILABLE_BEDS) AS EXCESS_REQUESTS
FROM SERVICES_WEEKLY
WHERE PATIENTS_REQUEST > AVAILABLE_BEDS
ORDER BY EXCESS_REQUESTS DESC
LIMIT 10;

-- 3. Lowest Satisfaction Patients Under Nurse
SELECT P.NAME ,
	   S.STAFF_NAME ,
	   S.SERVICE ,
       P.SATISFACTION
FROM STAFF AS S
LEFT JOIN PATIENTS AS P ON S.SERVICE = P.SERVICE
WHERE ROLE = 'NURSE' 
ORDER BY SATISFACTION ASC
LIMIT 10;

-- 4. Patients Assigned to Each Doctor
SELECT S.STAFF_NAME AS DOCTOR, 
       S.SERVICE,
       COUNT(P.PATIENT_ID) AS TOTAL_PATIENTS
FROM STAFF S
JOIN PATIENTS P ON S.SERVICE = P.SERVICE
WHERE S.ROLE = 'DOCTOR'
GROUP BY S.STAFF_NAME, S.SERVICE;

-- WINDOW FUNCTION QUERIES

-- 1. Rank Services by Satisfaction per Month
SELECT MONTH, 
	   SERVICE, 
       PATIENT_SATISFACTION,
       RANK() OVER ( PARTITION BY MONTH 
					 ORDER BY PATIENT_SATISFACTION DESC
				   ) AS SATISFACTION_RANK
FROM SERVICES_WEEKLY;

-- 2. Dense Rank for Refused Patients
SELECT MONTH,
       SERVICE,
       PATIENTS_REFUSED,
       DENSE_RANK() OVER ( PARTITION BY MONTH
						   ORDER BY PATIENTS_REFUSED DESC
						 ) AS REFUSAL_RANK
FROM SERVICES_WEEKLY;

-- 3. Staff Presence Percentage per Week

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

-- STORED PROCEDURE

-- 1. Average Patient Satisfaction by Service

/*
CREATE PROCEDURE `Avg_Satisfaction` (IN svc VARCHAR(50))
BEGIN
	SELECT SERVICE,
           AVG(SATISFACTION) AS AVG_SATISFACTION
    FROM PATIENTS
    WHERE SERVICE = svc
    GROUP BY SERVICE;
END
*/

CALL Avg_Satisfaction('ICU');

-- 2. Patients Who Stayed More Than 'N' Days

/*
CREATE PROCEDURE `LongStayPatients` (IN minDays INT)
BEGIN
	SELECT PATIENT_ID, 
           NAME, 
           SERVICE,
           DATEDIFF(DEPARTURE_DATE, ARRIVAL_DATE) AS DAYS_STAYED
    FROM PATIENTS
    WHERE DATEDIFF(DEPARTURE_DATE, ARRIVAL_DATE) > minDays;
END
*/

CALL LongStayPatients(10);

-- 3. Monthly Admissions Based on Service

/*
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
*/

CALL MonthlyAdmissions(2);