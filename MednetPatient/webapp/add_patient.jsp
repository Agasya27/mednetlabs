<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Patient — MednetLabs</title>
    <%@ include file="header.jsp" %>
</head>
<body>
<div class="container">

    <div class="page-header">
        <div>
            <p class="page-title">Add New Patient</p>
            <p class="page-subtitle">Register a new patient and assign a doctor</p>
        </div>
        <a href="patients.jsp" class="btn btn-outline">&larr; Back to Patients</a>
    </div>

<%
    if ("1".equals(request.getParameter("error"))) {
%>
    <div class="alert alert-error">Please fill all required fields correctly.</div>
<%
    }
%>

    <div class="card">
        <div class="card-header">
            <span class="card-title">Patient Information</span>
        </div>

        <form action="save_patient.jsp" method="POST">
            <div class="form-grid">

                <div class="form-group">
                    <label for="patient_name">Full Name <span style="color:#e74c3c">*</span></label>
                    <input type="text" id="patient_name" name="patient_name" placeholder="e.g. Arjun Kapoor" required>
                </div>

                <div class="form-group">
                    <label for="age">Age <span style="color:#e74c3c">*</span></label>
                    <input type="number" id="age" name="age" min="1" max="149" placeholder="1 – 149" required>
                </div>

                <div class="form-group">
                    <label for="gender">Gender <span style="color:#e74c3c">*</span></label>
                    <select id="gender" name="gender">
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Other">Other</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="status">Admission Status</label>
                    <select id="status" name="status">
                        <option value="Active">Active</option>
                        <option value="Discharged">Discharged</option>
                    </select>
                </div>

                <div class="form-group full-width">
                    <label for="diagnosis">Diagnosis</label>
                    <input type="text" id="diagnosis" name="diagnosis" placeholder="e.g. Hypertension, Migraine">
                </div>

                <div class="form-group full-width">
                    <label for="doctor_id">Assign Doctor <span style="color:#e74c3c">*</span></label>
                    <select id="doctor_id" name="doctor_id">
<%
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
            "SELECT doctor_id, doctor_name, specialty FROM doctors ORDER BY doctor_name"
        );
        while (rs.next()) {
%>
                        <option value="<%= rs.getInt("doctor_id") %>">
                            <%= rs.getString("doctor_name") %> &mdash; <%= rs.getString("specialty") %>
                        </option>
<%
        }
        rs.close(); st.close();
    } catch (Exception e) {
        out.println("<option value=''>Error loading doctors</option>");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-success">Save Patient</button>
                    <a href="patients.jsp" class="btn btn-outline">Cancel</a>
                </div>

            </div>
        </form>
    </div>

</div>
</body>
</html>
