<!DOCTYPE html>
<%@ page isELIgnored="true" %>
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

<!-- Sort UI -->
<div class="card" style="padding: 16px 20px; margin-bottom: 20px;">
    <div class="toolbar">
        <label>Sort by:</label>
        <select id="sortSelect">
            <option value="name">Patient Name</option>
            <option value="age">Age (Oldest First)</option>
            <option value="date">Admission Date</option>
        </select>
        <button onclick="loadPatients()" class="btn">Apply Sort</button>
    </div>
</div>

<!-- Table -->
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
        <tbody id="patientsTable"></tbody>
    </table>
</div>

</div>

<script>
function loadPatients() {

    fetch('/MednetPatient/api/patients')
    .then(res => res.json())
    .then(data => {

        let sort = document.getElementById("sortSelect").value;

        // Sorting logic
        if (sort === "age") {
            data.sort((a, b) => b.age - a.age);
        } else if (sort === "date") {
            data.sort((a, b) => new Date(b.admittedOn) - new Date(a.admittedOn));
        } else {
            data.sort((a, b) => a.name.localeCompare(b.name));
        }

        let table = document.getElementById("patientsTable");
        table.innerHTML = "";

        data.forEach(p => {

            let statusBadge = p.status === "Active"
                ? '<span class="badge-active">Active</span>'
                : '<span class="badge-discharged">Discharged</span>';

            let row = document.createElement("tr");
            row.innerHTML =
                '<td style="color:#a0a8b4; font-size:12px;">' + p.id + '</td>' +
                '<td><strong>' + (p.name || '') + '</strong></td>' +
                '<td>' + (p.age || '') + '</td>' +
                '<td>' + (p.gender || '') + '</td>' +
                '<td>' + (p.diagnosis || '') + '</td>' +
                '<td>' + (p.doctorName || '-') + '</td>' +
                '<td>' + (p.admittedOn || '-') + '</td>' +
                '<td>' + statusBadge + '</td>';
            table.appendChild(row);
        });

    })
    .catch(err => {
        console.error("Error:", err);
    });
}

// Load on page open
loadPatients();
</script>

</body>
</html>
