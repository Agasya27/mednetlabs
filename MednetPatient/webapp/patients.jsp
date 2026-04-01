<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patients — MednetLabs</title>
    <%@ include file="header.jsp" %>
</head>
<body>
<div class="container">

    <div class="page-header">
        <div>
            <p class="page-title">All Patients</p>
            <p class="page-subtitle">Complete list of all registered patients</p>
        </div>
        <a href="add_patient.jsp" class="btn btn-success">+ Add Patient</a>
    </div>

    <div class="card" style="padding: 16px 20px; margin-bottom: 20px;">
        <form method="GET" class="toolbar">
            <label>Sort by:</label>
            <select name="sort">
                <option value="name"<%= "name".equals(request.getParameter("sort")) || request.getParameter("sort") == null ? " selected" : "" %>>Patient Name</option>
                <option value="age"<%= "age".equals(request.getParameter("sort")) ? " selected" : "" %>>Age (Oldest First)</option>
                <option value="date"<%= "date".equals(request.getParameter("sort")) ? " selected" : "" %>>Admission Date</option>
            </select>
            <button type="submit" class="btn">Apply Sort</button>
        </form>
    </div>

<%
    String sortParam = request.getParameter("sort");
    String orderBy;
    if ("age".equals(sortParam)) {
        orderBy = "ORDER BY p.age DESC";
    } else if ("date".equals(sortParam)) {
        orderBy = "ORDER BY p.admitted_on DESC";
    } else {
        orderBy = "ORDER BY p.patient_name ASC";
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = null;
    try {
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mednet_db",
            "root",
            "MednetLabs123"
        );

        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery(
            "SELECT p.patient_id, p.patient_name, p.age, p.gender, " +
            "       p.diagnosis, d.doctor_name, p.admitted_on, p.status " +
            "FROM patients p " +
            "INNER JOIN doctors d ON p.doctor_id = d.doctor_id " +
            orderBy
        );
%>

    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Patient Name</th>
                    <th>Age</th>
                    <th>Gender</th>
                    <th>Diagnosis</th>
                    <th>Assigned Doctor</th>
                    <th>Admitted On</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
<%
        while (rs.next()) {
            String status = rs.getString("status");
%>
                <tr>
                    <td style="color:#a0a8b4; font-size:12px;"><%= rs.getInt("patient_id") %></td>
                    <td><strong><%= rs.getString("patient_name") %></strong></td>
                    <td><%= rs.getInt("age") %></td>
                    <td><%= rs.getString("gender") %></td>
                    <td><%= rs.getString("diagnosis") %></td>
                    <td><%= rs.getString("doctor_name") %></td>
                    <td><%= rs.getDate("admitted_on") %></td>
                    <td>
<%
            if ("Active".equals(status)) {
%>
                        <span class="badge-active">Active</span>
<%
            } else {
%>
                        <span class="badge-discharged">Discharged</span>
<%
            }
%>
                    </td>
                </tr>
<%
        }
        rs.close(); st.close();
%>
            </tbody>
        </table>
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
