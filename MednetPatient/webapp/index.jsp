<!DOCTYPE html>
<html>
<head>
    <title>Dashboard — MednetLabs</title>
    <%@ include file="header.jsp" %>
</head>
<body>
<div class="container">

```
<div class="page-header">
    <div>
        <p class="page-title">Dashboard</p>
        <p class="page-subtitle">Welcome to MednetLabs Patient Management System</p>
    </div>
    <a href="add_patient.jsp" class="btn btn-success">+ New Patient</a>
</div>

<!-- Stats -->
<div class="stats-row">
    <div class="stat-card">
        <span class="stat-label">Total Patients</span>
        <span class="stat-number" id="totalPatients">0</span>
    </div>
    <div class="stat-card">
        <span class="stat-label">Active Patients</span>
        <span class="stat-number" id="activePatients">0</span>
    </div>
    <div class="stat-card">
        <span class="stat-label">Total Doctors</span>
        <span class="stat-number" id="totalDoctors">--</span>
    </div>
</div>

<!-- Recent Admissions -->
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
                    <th>Status</th>
                </tr>
            </thead>
            <tbody id="recentPatients">
                <!-- Filled dynamically -->
            </tbody>
        </table>
    </div>
</div>
```

</div>

<script>
fetch('/MednetPatient/api/patients')
  .then(res => res.json())
  .then(data => {

    // Total Patients
    document.getElementById("totalPatients").innerText = data.length;

    // Active Patients
    let active = data.filter(p => p.status === "Active").length;
    document.getElementById("activePatients").innerText = active;

    // Doctors (not available yet)
    document.getElementById("totalDoctors").innerText = "N/A";

    // Recent Patients (Top 5)
    let table = document.getElementById("recentPatients");
    table.innerHTML = "";

    data.slice(0,5).forEach(p => {
        table.innerHTML += `
            <tr>
                <td><strong>${p.name}</strong></td>
                <td>${p.diagnosis}</td>
                <td>${p.status}</td>
            </tr>
        `;
    });

  })
  .catch(err => {
    console.error("API Error:", err);
  });
</script>

</body>
</html>

