<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard — MednetLabs</title>
    <%@ include file="header.jsp" %>
</head>
<body>
<div class="container">

    <div class="page-header">
        <div>
            <p class="page-title">Dashboard</p>
            <p class="page-subtitle">Welcome to MednetLabs Patient Management System</p>
        </div>
        <a href="add_patient.jsp" class="btn btn-success">+ New Patient</a>
    </div>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = null;
    int totalPatients = 0;
    int activePatients = 0;
    int totalDoctors = 0;
    try {
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mednet_db",
            "root",
            "MednetLabs123"
        );

        Statement stA = conn.createStatement();
        ResultSet rsA = stA.executeQuery("SELECT COUNT(*) FROM patients");
        if (rsA.next()) totalPatients = rsA.getInt(1);
        rsA.close(); stA.close();

        Statement stB = conn.createStatement();
        ResultSet rsB = stB.executeQuery("SELECT COUNT(*) FROM patients WHERE status='Active'");
        if (rsB.next()) activePatients = rsB.getInt(1);
        rsB.close(); stB.close();

        Statement stC = conn.createStatement();
        ResultSet rsC = stC.executeQuery("SELECT COUNT(*) FROM doctors");
        if (rsC.next()) totalDoctors = rsC.getInt(1);
        rsC.close(); stC.close();
%>

    <div class="stats-row">
        <div class="stat-card">
            <span class="stat-label">Total Patients</span>
            <span class="stat-number"><%= totalPatients %></span>
        </div>
        <div class="stat-card">
            <span class="stat-label">Active Patients</span>
            <span class="stat-number"><%= activePatients %></span>
        </div>
        <div class="stat-card">
            <span class="stat-label">Total Doctors</span>
            <span class="stat-number"><%= totalDoctors %></span>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <span class="card-title">Recent Admissions</span>
            <a href="patients.jsp" class="btn btn-sm btn-outline">View All</a>
        </div>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Patient Name</th>
                        <th>Diagnosis</th>
                        <th>Doctor</th>
                        <th>Admitted On</th>
                    </tr>
                </thead>
                <tbody>
<%
        Statement stR = conn.createStatement();
        ResultSet rsR = stR.executeQuery(
            "SELECT p.patient_name, p.diagnosis, p.admitted_on, d.doctor_name " +
            "FROM patients p " +
            "INNER JOIN doctors d ON p.doctor_id = d.doctor_id " +
            "ORDER BY p.admitted_on DESC LIMIT 5"
        );
        while (rsR.next()) {
%>
                    <tr>
                        <td><strong><%= rsR.getString("patient_name") %></strong></td>
                        <td><%= rsR.getString("diagnosis") %></td>
                        <td><%= rsR.getString("doctor_name") %></td>
                        <td><%= rsR.getDate("admitted_on") %></td>
                    </tr>
<%
        }
        rsR.close(); stR.close();
%>
                </tbody>
            </table>
        </div>
    </div>

<%
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Database Error: " + e.getMessage() + "</div>");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>

</div>
</body>
</html>
