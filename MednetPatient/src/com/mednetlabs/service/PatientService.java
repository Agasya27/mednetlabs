package com.mednetlabs.service;

import com.mednetlabs.dao.PatientDAO;
import com.mednetlabs.model.Patient;

import java.util.List;

/**
 * PatientService — business logic and validation sit here.
 * The servlet calls this layer; it never touches DB directly.
 */
public class PatientService {

    private final PatientDAO dao = new PatientDAO();

    // ── GET ──────────────────────────────────────────────────────────────────

    public List<Patient> getAllPatients() throws Exception {
        return dao.getAll();
    }

    // ── POST ─────────────────────────────────────────────────────────────────

    public int addPatient(Patient p) throws Exception {
        validate(p);
        return dao.addPatient(p);
    }

    // ── PUT ──────────────────────────────────────────────────────────────────

    public Patient updatePatient(int id, Patient incoming) throws Exception {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid patient ID.");
        }
        Patient existing = dao.getById(id);
        if (existing == null) {
            throw new IllegalArgumentException("Patient with id " + id + " not found.");
        }
        // Merge: only overwrite fields that were sent in the request
        if (incoming.getName()      != null) existing.setName(incoming.getName());
        if (incoming.getGender()    != null) existing.setGender(incoming.getGender());
        if (incoming.getDiagnosis() != null) existing.setDiagnosis(incoming.getDiagnosis());
        if (incoming.getStatus()    != null) existing.setStatus(incoming.getStatus());
        if (incoming.getDoctorId()  != null) existing.setDoctorId(incoming.getDoctorId());
        if (incoming.getAge() > 0)           existing.setAge(incoming.getAge());

        validate(existing);  // validate merged result before saving
        return dao.update(existing);
    }

    // ── DELETE ───────────────────────────────────────────────────────────────

    public void deletePatient(int id) throws Exception {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid patient ID.");
        }
        dao.delete(id);  // throws RuntimeException if not found
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
