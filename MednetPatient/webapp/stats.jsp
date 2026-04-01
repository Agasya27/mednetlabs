<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Statistics — MednetLabs</title>
    <%@ include file="header.jsp" %>
</head>
<body>
<div class="container">

    <div class="page-header">
        <div>
            <p class="page-title">Analytics &amp; Statistics</p>
            <p class="page-subtitle">Doctor workload, diagnosis trends, and active case analysis</p>
        </div>
    </div>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = null;
    try {
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mednet_db",
            "root",
            "MednetLabs123"
        );
%>

    <!-- SECTION A — Patients Per Doctor -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">Patients Per Doctor</span>
        </div>
        <div class="table-wrap" style="margin-top:14px;">
            <table>
                <thead>
                    <tr>
                        <th>Doctor Name</th>
                        <th>Specialty</th>
                        <th>Patient Count</th>
                    </tr>
                </thead>
                <tbody>
<%
        Statement stA = conn.createStatement();
        ResultSet rsA = stA.executeQuery(
            "SELECT d.doctor_name, d.specialty, " +
            "       COUNT(p.patient_id) AS patient_count " +
            "FROM doctors d " +
            "LEFT JOIN patients p ON d.doctor_id = p.doctor_id " +
            "GROUP BY d.doctor_id, d.doctor_name, d.specialty " +
            "ORDER BY patient_count DESC"
        );
        while (rsA.next()) {
%>
                    <tr>
                        <td><strong><%= rsA.getString("doctor_name") %></strong></td>
                        <td><%= rsA.getString("specialty") %></td>
                        <td>
                            <span style="display:inline-block; background:#e8f4fd; color:#1F4E79; padding:3px 14px; border-radius:20px; font-weight:700; font-size:13px;">
                                <%= rsA.getInt("patient_count") %>
                            </span>
                        </td>
                    </tr>
<%
        }
        rsA.close(); stA.close();
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- SECTION B — Diagnosis Breakdown -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">Diagnosis Breakdown</span>
        </div>
        <div class="table-wrap" style="margin-top:14px;">
            <table>
                <thead>
                    <tr>
                        <th>Diagnosis</th>
                        <th>Total Cases</th>
                        <th>Avg Age</th>
                        <th>Oldest Patient</th>
                    </tr>
                </thead>
                <tbody>
<%
        Statement stB = conn.createStatement();
        ResultSet rsB = stB.executeQuery(
            "SELECT diagnosis, " +
            "       COUNT(*)  AS total_cases, " +
            "       AVG(age)  AS avg_age, " +
            "       MAX(age)  AS oldest_patient " +
            "FROM patients " +
            "GROUP BY diagnosis " +
            "ORDER BY total_cases DESC"
        );
        while (rsB.next()) {
            String avgAge = String.format("%.1f", rsB.getDouble("avg_age"));
%>
                    <tr>
                        <td><strong><%= rsB.getString("diagnosis") %></strong></td>
                        <td><%= rsB.getInt("total_cases") %></td>
                        <td><%= avgAge %> yrs</td>
                        <td><%= rsB.getInt("oldest_patient") %> yrs</td>
                    </tr>
<%
        }
        rsB.close(); stB.close();
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- SECTION C — Repeated Diagnoses -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">Diagnoses Appearing More Than Once</span>
        </div>
<%
        Statement stC = conn.createStatement();
        ResultSet rsC = stC.executeQuery(
            "SELECT diagnosis, COUNT(*) AS cases " +
            "FROM patients " +
            "WHERE status = 'Active' " +
            "GROUP BY diagnosis " +
            "HAVING COUNT(*) > 1 " +
            "ORDER BY cases DESC"
        );
        boolean hasRepeated = false;
%>
        <div class="table-wrap" style="margin-top:14px;">
            <table>
                <thead>
                    <tr>
                        <th>Diagnosis</th>
                        <th>Active Cases</th>
                    </tr>
                </thead>
                <tbody>
<%
        while (rsC.next()) {
            hasRepeated = true;
%>
                    <tr>
                        <td><strong><%= rsC.getString("diagnosis") %></strong></td>
                        <td>
                            <span style="display:inline-block; background:#e8f8f0; color:#1a7a45; padding:3px 14px; border-radius:20px; font-weight:700; font-size:13px;">
                                <%= rsC.getInt("cases") %>
                            </span>
                        </td>
                    </tr>
<%
        }
        rsC.close(); stC.close();

        if (!hasRepeated) {
%>
                    <tr>
                        <td colspan="2" style="text-align:center; color:#a0a8b4; padding:24px;">
                            No repeated diagnoses among active patients.
                        </td>
                    </tr>
<%
        }
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
