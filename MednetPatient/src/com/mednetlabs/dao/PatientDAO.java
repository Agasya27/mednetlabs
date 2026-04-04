package com.mednetlabs.dao;

import com.mednetlabs.model.Patient;
import com.mednetlabs.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.ArrayList;
import java.util.List;

public class PatientDAO {

    // ── GET ALL (with doctor name via JOIN) ──────────────────────────────────

    @SuppressWarnings("unchecked")
    public List<Patient> getAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String sql =
                "SELECT p.patient_id, p.patient_name, p.age, p.gender, p.diagnosis, " +
                "       p.doctor_id, p.admitted_on, p.status, d.doctor_name " +
                "FROM patients p " +
                "LEFT JOIN doctors d ON p.doctor_id = d.doctor_id";

            List<Object[]> rows = session.createNativeQuery(sql).list();
            List<Patient> result = new ArrayList<>();

            for (Object[] row : rows) {
                Patient p = new Patient();
                p.setId(((Number) row[0]).intValue());
                p.setName((String) row[1]);
                p.setAge(row[2] != null ? ((Number) row[2]).intValue() : 0);
                p.setGender((String) row[3]);
                p.setDiagnosis((String) row[4]);
                p.setDoctorId(row[5] != null ? ((Number) row[5]).intValue() : null);
                p.setAdmittedOn(row[6] != null ? row[6].toString() : null);
                p.setStatus((String) row[7]);
                p.setDoctorName((String) row[8]);
                result.add(p);
            }
            return result;
        }
    }

    // ── GET BY ID ────────────────────────────────────────────────────────────

    public Patient getById(int id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Patient.class, id);  // null if not found
        }
    }

    // ── ADD PATIENT ──────────────────────────────────────────────────────────

    public int addPatient(Patient p) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                int id = (int) session.save(p);
                tx.commit();
                return id;
            } catch (Exception e) {
                tx.rollback();          // rollback BEFORE session closes
                throw e;
            }
        }
    }

    // ── UPDATE PATIENT ───────────────────────────────────────────────────────

    public Patient update(Patient p) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                session.update(p);
                tx.commit();
                return p;
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
        }
    }

    // ── DELETE PATIENT ───────────────────────────────────────────────────────

    public void delete(int id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Patient p = session.get(Patient.class, id);
                if (p == null) {
                    // throw first — catch block below handles rollback
                    throw new RuntimeException("Patient with id " + id + " not found.");
                }
                session.delete(p);
                tx.commit();
            } catch (Exception e) {
                if (tx != null && tx.isActive()) tx.rollback();
                throw e;
            }
        }
    }
}
