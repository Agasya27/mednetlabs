# Hospital Management System (HMS)

## Overview
The Hospital Management System (HMS) is a web application designed to manage patient records and streamline hospital operations. This application is built using JSP, Servlets, and MySQL, following a layered architecture to ensure separation of concerns and maintainability.

## Project Structure
```
hms-app
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com
│   │   │       └── hms
│   │   │           ├── controller
│   │   │           │   └── PatientServlet.java
│   │   │           ├── service
│   │   │           │   └── PatientService.java
│   │   │           ├── repository
│   │   │           │   └── PatientRepository.java
│   │   │           ├── model
│   │   │           │   └── Patient.java
│   │   │           └── util
│   │   │               └── DBConnection.java
│   │   └── webapp
│   │       ├── index.jsp
│   │       └── WEB-INF
│   │           └── web.xml
├── pom.xml
└── README.md
```

## Features
- **Patient Management**: Add, retrieve, update, and delete patient records.
- **RESTful API**: Provides endpoints for patient data management.
- **Dynamic Frontend**: Uses JavaScript to fetch and display patient data.

## Getting Started

### Prerequisites
- Java Development Kit (JDK)
- Apache Tomcat or any compatible servlet container
- MySQL Database

### Setup Instructions
1. **Clone the Repository**:
   ```
   git clone <repository-url>
   cd hms-app
   ```

2. **Configure Database**:
   - Create a MySQL database and update the `DBConnection.java` file with your database credentials.

3. **Build the Project**:
   - Use Maven to build the project:
   ```
   mvn clean install
   ```

4. **Deploy the Application**:
   - Deploy the `hms-app.war` file to your servlet container (e.g., Tomcat).

5. **Access the Application**:
   - Open your web browser and navigate to `http://localhost:8080/hms-app`.

## Usage
- **GET /api/patients**: Retrieve a list of all patients in JSON format.
- **POST /api/patients**: Add a new patient by sending a JSON object with patient details.

## Future Enhancements
- Implement full CRUD operations (PUT, DELETE).
- Integrate a JSON library (e.g., Gson or Jackson) for better JSON handling.
- Prepare for migration to Spring Boot for improved scalability and maintainability.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.