# MednetLabs Patient Record System

A Patient Record Management System for MednetLabs hospital, built with raw JSP and MySQL — no frameworks.

## Tech Stack
- Java JSP (JavaServer Pages) — raw scriptlets, no JSTL/EL
- Apache Tomcat 10
- MySQL (MySQL Workbench)
- JDBC (mysql-connector-j)
- Plain HTML + CSS (no frameworks)

---

## Setup — Step by Step

### Step 1: MySQL Workbench
1. Open MySQL Workbench
2. File > Open SQL Script > select `database/schema.sql`
3. Click the lightning bolt icon (Execute)
4. Verify: you should see `mednet_db` with `doctors` and `patients` tables

### Step 2: Download Required Files

**Apache Tomcat 10**
- Download from: https://tomcat.apache.org/download-10.cgi
- Extract to a folder, e.g. `C:/tomcat10`

**MySQL Connector/J**
- Download from: https://dev.mysql.com/downloads/connector/j/
- Download the JAR file (`mysql-connector-j-x.x.x.jar`)
- Copy the JAR to: `tomcat10/lib/`

### Step 3: Deploy the Project
Copy the entire `webapp/` folder to: `tomcat10/webapps/MednetPatient/`

Final structure inside webapps:
```
webapps/MednetPatient/
├── WEB-INF/
│   └── web.xml
├── css/
│   └── style.css
├── header.jsp
├── index.jsp
├── patients.jsp
├── add_patient.jsp
├── save_patient.jsp
├── search.jsp
└── stats.jsp
```

### Step 4: Update Password
Open every `.jsp` file and replace `YOUR_PASSWORD` with your MySQL root password.

Files to update:
- `webapp/index.jsp`
- `webapp/patients.jsp`
- `webapp/add_patient.jsp`
- `webapp/save_patient.jsp`
- `webapp/search.jsp`
- `webapp/stats.jsp`

### Step 5: Start Tomcat
- **Windows:** double-click `tomcat10/bin/startup.bat`
- **Mac/Linux:** run `sh tomcat10/bin/startup.sh`

### Step 6: Open in Browser
```
http://localhost:8080/MednetPatient/index.jsp
```

---

## Pages

| Page | File | SQL Concepts Used |
|------|------|-------------------|
| Dashboard | index.jsp | COUNT(*), INNER JOIN, ORDER BY, LIMIT |
| All Patients | patients.jsp | INNER JOIN, dynamic ORDER BY |
| Add Patient | add_patient.jsp | SELECT doctors for dropdown |
| Save Patient | save_patient.jsp | INSERT with PreparedStatement |
| Search | search.jsp | WHERE + LIKE, INNER JOIN |
| Statistics | stats.jsp | GROUP BY, HAVING, AVG, MAX, LEFT JOIN |

---

## Database Schema

Two tables — `doctors` and `patients` — linked by a Foreign Key (`doctor_id`).  
Schema is normalized to 3NF. See `database/schema.sql` for full details and inline comments explaining each DBMS concept.

### doctors
| Column | Type | Notes |
|--------|------|-------|
| doctor_id | INT PK AUTO_INCREMENT | Entity Integrity |
| doctor_name | VARCHAR(100) NOT NULL | |
| specialty | VARCHAR(100) NOT NULL | |
| phone | VARCHAR(15) | |
| email | VARCHAR(150) UNIQUE | |

### patients
| Column | Type | Notes |
|--------|------|-------|
| patient_id | INT PK AUTO_INCREMENT | Entity Integrity |
| patient_name | VARCHAR(100) NOT NULL | |
| age | INT CHECK (age > 0 AND age < 150) | Domain Integrity |
| gender | ENUM('Male','Female','Other') | Domain Integrity |
| diagnosis | VARCHAR(200) | |
| doctor_id | INT FK → doctors | Referential Integrity |
| admitted_on | DATE DEFAULT CURRENT_DATE | |
| status | ENUM('Active','Discharged') | |

---

## DBMS Concepts Demonstrated

| Concept | Where |
|---------|-------|
| PRIMARY KEY / Entity Integrity | Both tables |
| FOREIGN KEY / Referential Integrity | patients.doctor_id → doctors |
| Domain Integrity (CHECK + ENUM) | age CHECK, gender/status ENUM |
| Normalization (3NF) | Doctor data separated from patient data |
| Indexes | idx_status, idx_doctor, idx_name, idx_admitted |
| INNER JOIN | index.jsp, patients.jsp, search.jsp |
| LEFT JOIN | stats.jsp (Patients Per Doctor) |
| GROUP BY + Aggregates (COUNT, AVG, MAX) | stats.jsp |
| HAVING | stats.jsp (Repeated Diagnoses) |
| WHERE + LIKE | search.jsp |
| PreparedStatement (parameterized queries) | search.jsp, save_patient.jsp |
