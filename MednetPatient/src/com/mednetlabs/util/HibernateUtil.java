package com.mednetlabs.util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * HibernateUtil — builds and holds the singleton SessionFactory.
 * SessionFactory is expensive to create (reads config, sets up connection pool)
 * so it is created once at startup and reused for every request.
 */
public class HibernateUtil {

    private static final SessionFactory sessionFactory = buildSessionFactory();

    private static SessionFactory buildSessionFactory() {
        try {
            // Reads hibernate.cfg.xml from the classpath (WEB-INF/classes/)
            return new Configuration().configure().buildSessionFactory();
        } catch (Exception e) {
            System.err.println("HibernateUtil: failed to build SessionFactory — " + e.getMessage());
            throw new RuntimeException("Failed to initialize Hibernate SessionFactory", e);
        }
    }

    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }

    // Call this on application shutdown (optional but clean)
    public static void shutdown() {
        if (sessionFactory != null && !sessionFactory.isClosed()) {
            sessionFactory.close();
        }
    }
}
