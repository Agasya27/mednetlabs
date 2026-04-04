package com.mednetlabs.dao;

import com.mednetlabs.DBConnection;
import com.mednetlabs.model.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DoctorDAO — all SQL for the doctors table via plain JDBC.
 * Uses DBConnection (same as PatientDAO) — no Hibernate dependency needed.
 */
public class DoctorDAO {

    // ── GET all ──────────────────────────────────────────────────────────────

    public List<Doctor> getAllDoctors() throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT doctor_id, doctor_name, specialty, phone, email " +
                     "FROM doctors ORDER BY doctor_name";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt  = conn.createStatement();
             ResultSet rs    = stmt.executeQuery(sql)) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── GET by ID ────────────────────────────────────────────────────────────

    public Doctor getDoctorById(int id) throws Exception {
        String sql = "SELECT doctor_id, doctor_name, specialty, phone, email " +
                     "FROM doctors WHERE doctor_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        }
        return null;  // not found
    }

    // ── POST: add a new doctor ───────────────────────────────────────────────

    public Doctor addDoctor(Doctor doctor) throws Exception {
        String sql = "INSERT INTO doctors (doctor_name, specialty, phone, email) " +
                     "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, doctor.getName().trim());
            stmt.setString(2, doctor.getSpecialty().trim());
            stmt.setString(3, doctor.getPhone());   // nullable
            stmt.setString(4, doctor.getEmail());   // nullable

            stmt.executeUpdate();

            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) {
                doctor.setId(keys.getInt(1));
            }
        }
        return doctor;
    }

    // ── Row mapper ───────────────────────────────────────────────────────────

    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("doctor_id"));
        d.setName(rs.getString("doctor_name"));
        d.setSpecialty(rs.getString("specialty"));
        d.setPhone(rs.getString("phone"));
        d.setEmail(rs.getString("email"));
        return d;
    }
}
