-- ============================================================
-- MednetLabs Patient Record System — Database Schema
-- MySQL syntax only (MySQL Workbench compatible)
-- ============================================================


-- ============================================================
-- SECTION 1 — Database Creation
-- ============================================================
DROP DATABASE IF EXISTS mednet_db;
CREATE DATABASE mednet_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mednet_db;


-- ============================================================
-- SECTION 2 — doctors table
-- DBMS Concepts: PRIMARY KEY, Entity Integrity
--   PRIMARY KEY uniquely identifies each doctor row.
--   Entity Integrity: no NULL allowed in doctor_id (enforced
--   automatically by PRIMARY KEY constraint).
-- ============================================================
CREATE TABLE doctors (
    doctor_id   INT          PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100) NOT NULL,
    specialty   VARCHAR(100) NOT NULL,
    phone       VARCHAR(15),
    email       VARCHAR(150) UNIQUE
);


-- ============================================================
-- SECTION 3 — patients table
-- DBMS Concepts:
--   FOREIGN KEY — doctor_id references doctors(doctor_id),
--     linking each patient to a doctor.
--   Referential Integrity — ON DELETE SET NULL ensures that if
--     a doctor is deleted, patients are not orphaned but their
--     doctor_id is set to NULL. ON UPDATE CASCADE propagates
--     any change to doctor_id automatically.
--   Domain Integrity — CHECK constraint on age ensures only
--     biologically plausible values (1–149) are stored.
--     ENUM on gender restricts values to a defined domain.
--   Normalization (3NF) — doctor information is stored once in
--     the doctors table and referenced here via FK, eliminating
--     transitive dependency and update anomalies.
-- ============================================================
CREATE TABLE patients (
    patient_id   INT          PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100) NOT NULL,
    age          INT          NOT NULL CHECK (age > 0 AND age < 150),
    gender       ENUM('Male','Female','Other') NOT NULL,
    diagnosis    VARCHAR(200),
    doctor_id    INT,
    admitted_on  DATE         DEFAULT (CURRENT_DATE),
    status       ENUM('Active','Discharged') DEFAULT 'Active',
    CONSTRAINT fk_doctor FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


-- ============================================================
-- SECTION 4 — Indexes
-- ============================================================

-- Used by patients.jsp and search.jsp: WHERE status = 'Active'
CREATE INDEX idx_status   ON patients(status);

-- Used by patients.jsp and stats.jsp: JOIN ON p.doctor_id = d.doctor_id
CREATE INDEX idx_doctor   ON patients(doctor_id);

-- Used by search.jsp: WHERE p.patient_name LIKE ?
-- Used by patients.jsp: ORDER BY p.patient_name ASC
CREATE INDEX idx_name     ON patients(patient_name);

-- Used by patients.jsp: ORDER BY p.admitted_on DESC
-- Used by index.jsp: ORDER BY p.admitted_on DESC (recent admissions)
CREATE INDEX idx_admitted ON patients(admitted_on);


-- ============================================================
-- SECTION 5 — Seed Data
-- ============================================================

INSERT INTO doctors (doctor_name, specialty, phone, email) VALUES
    ('Dr. Anjali Sharma', 'Cardiology',       '9810001111', 'anjali.sharma@mednetlabs.in'),
    ('Dr. Ravi Patel',    'Neurology',         '9820002222', 'ravi.patel@mednetlabs.in'),
    ('Dr. Sunita Mehta',  'General Medicine',  '9830003333', 'sunita.mehta@mednetlabs.in');

INSERT INTO patients (patient_name, age, gender, diagnosis, doctor_id, admitted_on, status) VALUES
    ('Arjun Kapoor',    45, 'Male',   'Hypertension',  1, '2025-11-10', 'Active'),
    ('Priya Nair',      32, 'Female', 'Migraine',       2, '2025-11-15', 'Active'),
    ('Suresh Iyer',     60, 'Male',   'Diabetes',       3, '2025-10-22', 'Discharged'),
    ('Kavitha Reddy',   27, 'Female', 'Fever',          3, '2025-12-01', 'Active'),
    ('Mohan Das',       55, 'Male',   'Epilepsy',       2, '2025-09-30', 'Discharged'),
    ('Neha Singh',      38, 'Female', 'Heart Block',    1, '2025-12-10', 'Active'),
    ('Ramesh Verma',    70, 'Male',   'Typhoid',        3, '2025-11-28', 'Discharged'),
    ('Ananya Bose',     22, 'Female', 'Anaemia',        1, '2025-12-18', 'Active');


-- ============================================================
-- SECTION 6 — Verification Queries (commented out)
-- Run individually in MySQL Workbench to verify data and schema.
-- ============================================================

-- Concept 1: Basic SELECT with ORDER BY
-- Lists all patients alphabetically by name.
-- SELECT * FROM patients ORDER BY patient_name ASC;

-- Concept 2: INNER JOIN — patients + doctors
-- Shows each patient alongside their assigned doctor's name.
-- SELECT p.patient_name, p.diagnosis, p.status,
--        d.doctor_name, d.specialty
-- FROM patients p
-- INNER JOIN doctors d ON p.doctor_id = d.doctor_id;

-- Concept 3: GROUP BY doctor_id with COUNT(*)
-- Counts how many patients are assigned to each doctor.
-- SELECT d.doctor_name, COUNT(p.patient_id) AS total_patients
-- FROM doctors d
-- LEFT JOIN patients p ON d.doctor_id = p.doctor_id
-- GROUP BY d.doctor_id, d.doctor_name
-- ORDER BY total_patients DESC;

-- Concept 4: GROUP BY diagnosis with COUNT(*) and AVG(age)
-- Summarises each diagnosis with case count and average patient age.
-- SELECT diagnosis,
--        COUNT(*) AS total_cases,
--        AVG(age) AS avg_age
-- FROM patients
-- GROUP BY diagnosis
-- ORDER BY total_cases DESC;

-- Concept 5: HAVING COUNT(*) > 1
-- Finds diagnoses that appear more than once among active patients.
-- SELECT diagnosis, COUNT(*) AS cases
-- FROM patients
-- WHERE status = 'Active'
-- GROUP BY diagnosis
-- HAVING COUNT(*) > 1
-- ORDER BY cases DESC;

-- Concept 6: LEFT JOIN doctors + patients with GROUP BY
-- Shows all doctors even if they have zero patients (LEFT JOIN).
-- SELECT d.doctor_name, d.specialty,
--        COUNT(p.patient_id) AS patient_count
-- FROM doctors d
-- LEFT JOIN patients p ON d.doctor_id = p.doctor_id
-- GROUP BY d.doctor_id, d.doctor_name, d.specialty
-- ORDER BY patient_count DESC;
