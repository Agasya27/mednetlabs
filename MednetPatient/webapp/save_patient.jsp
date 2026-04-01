<%@ page import="java.sql.*" %>
<%
    // This page processes POST from add_patient.jsp
    // It has no HTML output — only redirects

    String name      = request.getParameter("patient_name");
    String ageStr    = request.getParameter("age");
    String gender    = request.getParameter("gender");
    String diagnosis = request.getParameter("diagnosis");
    String docIdStr  = request.getParameter("doctor_id");
    String status    = request.getParameter("status");

    // Validation
    boolean valid = true;
    if (name == null || name.trim().isEmpty()) valid = false;

    int age = 0;
    try {
        age = Integer.parseInt(ageStr);
        if (age < 1 || age > 149) valid = false;
    } catch (Exception e) {
        valid = false;
    }

    int docId = 0;
    try {
        docId = Integer.parseInt(docIdStr);
    } catch (Exception e) {
        valid = false;
    }

    if (!valid) {
        response.sendRedirect("add_patient.jsp?error=1");
        return;
    }

    // Database insert using PreparedStatement (no SQL injection risk)
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mednet_db",
            "root",
            "MednetLabs123"
        );

        String sql = "INSERT INTO patients (patient_name, age, gender, diagnosis, doctor_id, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, name.trim());
        ps.setInt(2, age);
        ps.setString(3, gender);
        ps.setString(4, diagnosis);
        ps.setInt(5, docId);
        ps.setString(6, status);
        ps.executeUpdate();
        ps.close();

        response.sendRedirect("patients.jsp");
    } catch (Exception e) {
        response.sendRedirect("add_patient.jsp?error=1");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
