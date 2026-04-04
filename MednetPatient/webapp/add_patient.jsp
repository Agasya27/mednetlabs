<!DOCTYPE html>
<%@ page isELIgnored="true" %>
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

<div id="errorBox" class="alert alert-error" style="display:none;">Please fill all required fields correctly.</div>

<div class="card">
    <div class="card-header">
        <span class="card-title">Patient Information</span>
    </div>

    <div class="form-grid">

        <div class="form-group">
            <label>Full Name <span style="color:#e74c3c">*</span></label>
            <input type="text" id="name" placeholder="e.g. Arjun Kapoor" required>
        </div>

        <div class="form-group">
            <label>Age <span style="color:#e74c3c">*</span></label>
            <input type="number" id="age" min="1" max="149" placeholder="1 – 149" required>
        </div>

        <div class="form-group">
            <label>Gender</label>
            <select id="gender">
                <option value="Male">Male</option>
                <option value="Female">Female</option>
                <option value="Other">Other</option>
            </select>
        </div>

        <div class="form-group">
            <label>Status</label>
            <select id="status">
                <option value="Active">Active</option>
                <option value="Discharged">Discharged</option>
            </select>
        </div>

        <div class="form-group full-width">
            <label>Diagnosis</label>
            <input type="text" id="diagnosis" placeholder="e.g. Hypertension">
        </div>

        <div class="form-group full-width">
            <label>Assign Doctor</label>
            <select id="doctor_id"></select>
        </div>

        <div class="form-actions">
            <button onclick="addPatient()" class="btn btn-success">Save Patient</button>
            <a href="patients.jsp" class="btn btn-outline">Cancel</a>
        </div>

    </div>
</div>

</div>

<script>
// Load doctors from API
function loadDoctors() {
    fetch('/MednetPatient/api/doctors')
    .then(res => res.json())
    .then(data => {
        let select = document.getElementById('doctor_id');
        select.innerHTML = '<option value="">-- No Doctor Assigned --</option>';

        data.forEach(d => {
            let option = document.createElement('option');
            option.value = d.id;
            option.textContent = d.name + (d.specialty ? ' \u2014 ' + d.specialty : '');
            select.appendChild(option);
        });
    })
    .catch(err => {
        console.error(err);
        document.getElementById('doctor_id').innerHTML = '<option>Error loading doctors</option>';
    });
}

// Add patient using POST API
function addPatient() {

    let name = document.getElementById('name').value.trim();
    let age = parseInt(document.getElementById('age').value);

    if (!name || !age) {
        document.getElementById('errorBox').style.display = 'block';
        return;
    }
    document.getElementById('errorBox').style.display = 'none';

    let doctorIdRaw = document.getElementById('doctor_id').value;

    let data = {
        name: name,
        age: age,
        gender: document.getElementById('gender').value,
        diagnosis: document.getElementById('diagnosis').value,
        status: document.getElementById('status').value
    };

    if (doctorIdRaw) {
        data.doctorId = parseInt(doctorIdRaw);
    }

    fetch('/MednetPatient/api/patients', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            alert('Patient Added Successfully');
            window.location.href = 'patients.jsp';
        } else {
            alert('Error: ' + result.message);
        }
    })
    .catch(err => {
        console.error(err);
        alert('Error adding patient');
    });
}

// Initial load
loadDoctors();
</script>

</body>
</html>
