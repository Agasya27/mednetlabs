<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Management System</title>
    <script>
        async function fetchPatients() {
            const response = await fetch('/api/patients');
            const patients = await response.json();
            displayPatients(patients);
        }

        function displayPatients(patients) {
            const patientList = document.getElementById('patient-list');
            patientList.innerHTML = '';
            patients.forEach(patient => {
                const listItem = document.createElement('li');
                listItem.textContent = `${patient.name} (Age: ${patient.age}, Gender: ${patient.gender})`;
                patientList.appendChild(listItem);
            });
        }

        async function addPatient(event) {
            event.preventDefault();
            const formData = new FormData(event.target);
            const patientData = {
                name: formData.get('name'),
                age: formData.get('age'),
                gender: formData.get('gender')
            };

            const response = await fetch('/api/patients', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(patientData)
            });

            if (response.ok) {
                fetchPatients();
                event.target.reset();
            } else {
                alert('Failed to add patient');
            }
        }

        window.onload = fetchPatients;
    </script>
</head>
<body>
    <h1>Hospital Management System</h1>
    <h2>Patients</h2>
    <ul id="patient-list"></ul>

    <h2>Add Patient</h2>
    <form onsubmit="addPatient(event)">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required>
        <label for="age">Age:</label>
        <input type="number" id="age" name="age" required>
        <label for="gender">Gender:</label>
        <select id="gender" name="gender" required>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
        </select>
        <button type="submit">Add Patient</button>
    </form>
</body>
</html>