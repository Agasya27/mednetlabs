package com.mednetlabs.dao;

import com.mednetlabs.DBConnection;
import com.mednetlabs.model.Patient;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * PatientDAO — all SQL for the patients table lives here.
 * No business logic, no HTTP, no JSON — pure JDBC only.
 */
public class PatientDAO {

    // ── GET: all patients with doctor name via LEFT JOIN ─────────────────────

    public List<Patient> getAll() throws Exception {
        List<Patient> list = new ArrayList<>();

        String sql = "SELECT p.patient_id, p.patient_name, p.age, p.gender, " +
                     "       p.diagnosis, p.doctor_id, d.doctor_name, " +
                     "       p.admitted_on, p.status " +
                     "FROM patients p " +
                     "LEFT JOIN doctors d ON p.doctor_id = d.doctor_id " +
                     "ORDER BY p.admitted_on DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt  = conn.createStatement();
             ResultSet rs    = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Patient p = new Patient();
                p.setId(rs.getInt("patient_id"));
                p.setName(rs.getString("patient_name"));
                p.setAge(rs.getInt("age"));
                p.setGender(rs.getString("gender"));
                p.setDiagnosis(rs.getString("diagnosis"));

                int docId = rs.getInt("doctor_id");
                p.setDoctorId(rs.wasNull() ? null : docId);  // handle NULL FK

                p.setDoctorName(rs.getString("doctor_name"));

                Date admitted = rs.getDate("admitted_on");
                p.setAdmittedOn(admitted != null ? admitted.toString() : null);

                p.setStatus(rs.getString("status"));
                list.add(p);
            }
        }
        return list;
    }

    // ── POST: insert a new patient, return the generated patient_id ──────────

    public int addPatient(Patient p) throws Exception {
        String sql = "INSERT INTO patients " +
                     "  (patient_name, age, gender, diagnosis, doctor_id, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, p.getName().trim());
            stmt.setInt(2, p.getAge());
            stmt.setString(3, p.getGender());
            stmt.setString(4, p.getDiagnosis());

            // doctor_id is nullable
            if (p.getDoctorId() != null && p.getDoctorId() > 0) {
                stmt.setInt(5, p.getDoctorId());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }

            stmt.setString(6, p.getStatus() != null ? p.getStatus() : "Active");

            stmt.executeUpdate();

            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);  // return new patient_id
            }
        }
        return -1;
    }
}
