package com.hms.service;

import com.hms.model.Patient;
import com.hms.repository.PatientRepository;
import java.sql.SQLException;
import java.util.List;

public class PatientService {

    private final PatientRepository patientRepository;

    public PatientService() {
        this.patientRepository = new PatientRepository();
    }

    public List<Patient> getAllPatients() throws SQLException {
        return patientRepository.getAllPatients();
    }

    public Patient addPatient(Patient patient) throws SQLException {
        return patientRepository.addPatient(patient);
    }

    public Patient updatePatient(Patient patient) throws SQLException {
        return patientRepository.updatePatient(patient);
    }

    public boolean deletePatient(int id) throws SQLException {
        return patientRepository.deletePatient(id);
    }

    public Patient getPatientById(int id) throws SQLException {
        return patientRepository.getPatientById(id);
    }
}
