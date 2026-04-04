package com.mednetlabs.dao;

import com.mednetlabs.model.Patient;
import com.mednetlabs.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class PatientDAO {

    // ── GET ALL ─────────────────────────────────────────────
    public List<Patient> getAll() {

        Session session = HibernateUtil.getSessionFactory().openSession();

        List<Patient> list = session
                .createQuery("from Patient", Patient.class)
                .list();

        session.close();

        return list;
    }

    // ── ADD PATIENT ─────────────────────────────────────────
    public int addPatient(Patient p) {

        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = session.beginTransaction();

        int id = (int) session.save(p);

        tx.commit();
        session.close();

        return id;
    }

    // ── DELETE PATIENT ──────────────────────────────────────
    public void delete(int id) {

        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = session.beginTransaction();

        Patient p = session.get(Patient.class, id);

        if (p == null) {
            throw new RuntimeException("Patient not found");
        }

        session.delete(p);

        tx.commit();
        session.close();
    }
}