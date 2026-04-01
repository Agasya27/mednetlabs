<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Search — MednetLabs</title>
    <%@ include file="header.jsp" %>
</head>
<body>
<div class="container">

    <div class="page-header">
        <div>
            <p class="page-title">Search Patients</p>
            <p class="page-subtitle">Find patients by name or diagnosis</p>
        </div>
    </div>

    <div class="card" style="padding: 20px 24px; margin-bottom: 24px;">
        <form method="GET" class="toolbar">
            <input type="text" name="q"
                   value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>"
                   placeholder="Search by name or diagnosis...">
            <button type="submit" class="btn">Search</button>
<%
    if (request.getParameter("q") != null && !request.getParameter("q").trim().isEmpty()) {
%>
            <a href="search.jsp" class="btn btn-outline btn-sm">Clear</a>
<%
    }
%>
        </form>
    </div>

<%
    String q = request.getParameter("q");

    if (q != null && !q.trim().isEmpty()) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mednet_db",
                "root",
                "MednetLabs123"
            );

            String term = "%" + q.trim() + "%";

            PreparedStatement ps = conn.prepareStatement(
                "SELECT p.patient_id, p.patient_name, p.age, p.diagnosis, " +
                "       d.doctor_name, p.status " +
                "FROM patients p " +
                "INNER JOIN doctors d ON p.doctor_id = d.doctor_id " +
                "WHERE p.patient_name LIKE ? OR p.diagnosis LIKE ? " +
                "ORDER BY p.patient_name ASC"
            );
            ps.setString(1, term);
            ps.setString(2, term);
            ResultSet rs = ps.executeQuery();
            boolean hasRows = false;
%>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Patient Name</th>
                    <th>Age</th>
                    <th>Diagnosis</th>
                    <th>Assigned Doctor</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
<%
            while (rs.next()) {
                hasRows = true;
                String status = rs.getString("status");
%>
                <tr>
                    <td style="color:#a0a8b4; font-size:12px;"><%= rs.getInt("patient_id") %></td>
                    <td><strong><%= rs.getString("patient_name") %></strong></td>
                    <td><%= rs.getInt("age") %></td>
                    <td><%= rs.getString("diagnosis") %></td>
                    <td><%= rs.getString("doctor_name") %></td>
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
            rs.close(); ps.close();
%>
            </tbody>
        </table>
    </div>
<%
            if (!hasRows) {
%>
    <div class="empty-state">
        <p>No results found for &ldquo;<strong><%= q %></strong>&rdquo;</p>
    </div>
<%
            }

        } catch (Exception e) {
            out.println("<div class='alert alert-error'>Database Error: " + e.getMessage() + "</div>");
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    } else {
%>
    <div class="empty-state">
        <p>Enter a name or diagnosis above to search the patient registry.</p>
    </div>
<%
    }
%>

</div>
</body>
</html>
