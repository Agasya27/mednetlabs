package com.mednetlabs.service;

import com.mednetlabs.dao.DoctorDAO;
import com.mednetlabs.model.Doctor;

import java.util.List;

public class DoctorService {

    private final DoctorDAO dao = new DoctorDAO();

    // ── GET all ──────────────────────────────────────────────────────────────

    public List<Doctor> getAllDoctors() throws Exception {
        return dao.getAllDoctors();
    }

    // ── GET by ID ────────────────────────────────────────────────────────────

    public Doctor getDoctorById(int id) throws Exception {
        return dao.getDoctorById(id);
    }

    // ── POST ─────────────────────────────────────────────────────────────────

    public Doctor addDoctor(Doctor doctor) throws Exception {
        validate(doctor);
        return dao.addDoctor(doctor);
    }

    // ── Validation ───────────────────────────────────────────────────────────

    private void validate(Doctor doctor) {
        if (doctor == null) {
            throw new IllegalArgumentException("Request body is missing or malformed.");
        }
        if (doctor.getName() == null || doctor.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Doctor name is required.");
        }
        if (doctor.getSpecialty() == null || doctor.getSpecialty().trim().isEmpty()) {
            throw new IllegalArgumentException("Specialty is required.");
        }
    }
}
