package com.mednetlabs.service;

import com.mednetlabs.dao.PatientDAO;
import com.mednetlabs.model.Patient;

import java.util.List;

/**
 * PatientService — business logic and validation sit here.
 * The servlet calls this layer; it never touches JDBC directly.
 */
public class PatientService {

    private final PatientDAO dao = new PatientDAO();

    // ── GET ──────────────────────────────────────────────────────────────────

    public List<Patient> getAllPatients() throws Exception {
        return dao.getAll();
    }

    // ── POST ─────────────────────────────────────────────────────────────────

    /**
     * Validates input, then delegates insert to the DAO.
     *
     * @return the newly generated patient_id
     * @throws IllegalArgumentException for any validation failure
     */
    public int addPatient(Patient p) throws Exception {
        validate(p);
        return dao.addPatient(p);
    }

    // ── Validation ───────────────────────────────────────────────────────────

    private void validate(Patient p) {
        if (p == null) {
            throw new IllegalArgumentException("Request body is missing or malformed JSON.");
        }
        if (p.getName() == null || p.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Patient name is required.");
        }
        if (p.getName().trim().length() > 100) {
            throw new IllegalArgumentException("Patient name must be 100 characters or fewer.");
        }
        if (p.getAge() <= 0 || p.getAge() >= 150) {
            throw new IllegalArgumentException("Age must be between 1 and 149.");
        }
        if (p.getGender() == null ||
                (!p.getGender().equals("Male") &&
                 !p.getGender().equals("Female") &&
                 !p.getGender().equals("Other"))) {
            throw new IllegalArgumentException("Gender must be Male, Female, or Other.");
        }
        if (p.getStatus() != null &&
                !p.getStatus().equals("Active") &&
                !p.getStatus().equals("Discharged")) {
            throw new IllegalArgumentException("Status must be Active or Discharged.");
        }
    }
}
