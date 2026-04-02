Complete Explanation: What We Built and Why

The Problem We Started With
The original project had all code in one place — every JSP file was doing everything:

index.jsp was doing:
  - Connecting to MySQL (JDBC code)
  - Running SQL queries
  - Processing results
  - Rendering HTML
This is called spaghetti code — everything tangled together. If the database URL changed, you'd have to edit 6 files. If a SQL query broke, you'd be hunting through HTML.

What We Built: Layered Architecture
We separated the app into 4 distinct layers, each with one job:

Browser / JSP  (shows UI)
      ↓ HTTP Request
  Servlet       (handles HTTP — reads request, writes response)
      ↓ Java method call
  Service       (business rules — validates data)
      ↓ Java method call
  DAO           (database — runs SQL)
      ↓ JDBC
  MySQL         (stores data)
This is called Separation of Concerns — each layer only knows about its own job.

File by File Explanation

1. DBConnection.java — Already existed, kept as-is

public class DBConnection {
    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mednet_db", "root", "MednetLabs123"
        );
    }
}
What it does: One single place where the database URL, username, and password live. Every other class calls DBConnection.getConnection() instead of hardcoding credentials.
Why it matters: Before this, all 6 JSP files had the same connection code copy-pasted. If the password changed, you'd have to change 6 files and miss one.

2. model/Patient.java — The Data Blueprint

public class Patient {
    private int id;
    private String name;
    private int age;
    private String gender;
    private String diagnosis;
    private Integer doctorId;    // Integer not int — can be NULL in DB
    private String doctorName;   // from JOIN, not stored in patients table
    private String admittedOn;
    private String status;
    // + getters and setters
}
What it does: A plain Java class (called a POJO — Plain Old Java Object) that represents one patient. It's just a container for data — no logic, no SQL, no HTTP.
Why Integer instead of int for doctorId: In the database schema, doctor_id can be NULL (a patient might not have a doctor assigned). In Java, int can never be null — it defaults to 0. Integer (capital I, the object wrapper) can be null. So we use Integer to faithfully represent what the database can store.
The Gson annotations:

@SerializedName("doctorId")
private Integer doctorId;
Gson is the JSON library. By default, it would serialize doctorId as "doctorId" (camelCase), which is already what we want. The @SerializedName annotation lets you explicitly control the JSON key name if you ever need it different from the Java field name.

3. dao/PatientDAO.java — The Database Layer
DAO stands for Data Access Object. This is the only class allowed to write SQL.
getAll() method:

String sql = "SELECT p.patient_id, p.patient_name, p.age, p.gender, " +
             "p.diagnosis, p.doctor_id, d.doctor_name, " +
             "p.admitted_on, p.status " +
             "FROM patients p " +
             "LEFT JOIN doctors d ON p.doctor_id = d.doctor_id " +
             "ORDER BY p.admitted_on DESC";
Why LEFT JOIN not INNER JOIN: If a patient has no doctor assigned (doctor_id = NULL), an INNER JOIN would exclude that patient entirely from results. LEFT JOIN keeps all patients and just puts null in the doctorName field if there's no doctor.
The result is mapped row by row into Patient objects:

while (rs.next()) {
    Patient p = new Patient();
    p.setId(rs.getInt("patient_id"));
    // ...
    int docId = rs.getInt("doctor_id");
    p.setDoctorId(rs.wasNull() ? null : docId);  // handle NULL FK
The rs.wasNull() check: When you call rs.getInt() on a NULL column, JDBC returns 0 (not an exception). So we check wasNull() immediately after to know if it was actually NULL in the DB.
addPatient() method:

PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
Two important things here:
* PreparedStatement — parameters are passed with ? placeholders, never by string concatenation. This prevents SQL injection attacks.
* RETURN_GENERATED_KEYS — after insert, MySQL auto-generates a patient_id. This flag tells JDBC to give it back to us, so we can return the new ID in the response.
try-with-resources:

try (Connection conn = DBConnection.getConnection();
     PreparedStatement stmt = ...) {
The try(...) syntax automatically closes conn and stmt when the block ends, even if an exception is thrown. This prevents connection leaks — a common bug in older JDBC code.

4. service/PatientService.java — The Business Logic Layer

public class PatientService {
    private final PatientDAO dao = new PatientDAO();

    public List<Patient> getAllPatients() throws Exception {
        return dao.getAll();
    }

    public int addPatient(Patient p) throws Exception {
        validate(p);          // check rules first
        return dao.addPatient(p);  // then save
    }
What it does: Sits between the servlet and the DAO. Its job is to enforce business rules before any data is saved.
Why have this layer at all? Right now it seems thin — it just validates and calls the DAO. But consider these real scenarios:
* Before adding a patient, you might need to check the doctor exists
* You might want to send an email notification on admit
* You might need to log an audit trail
All of that goes here — not in the servlet (which should only care about HTTP), not in the DAO (which should only care about SQL).
The validate() method:

private void validate(Patient p) {
    if (p.getName() == null || p.getName().trim().isEmpty()) {
        throw new IllegalArgumentException("Patient name is required.");
    }
    if (p.getAge() <= 0 || p.getAge() >= 150) {
        throw new IllegalArgumentException("Age must be between 1 and 149.");
    }
    if (!p.getGender().equals("Male") && !p.getGender().equals("Female") ...) {
        throw new IllegalArgumentException("Gender must be Male, Female, or Other.");
    }
}
IllegalArgumentException is a standard Java exception for "the caller passed bad data". The servlet catches this specifically and returns a 400 Bad Request — meaning "your input was wrong", not "the server crashed".

5. PatientServlet.java — The HTTP Layer (Controller)
This is the entry point for all HTTP requests. It has exactly two jobs: read the request and write the response. Nothing else.

@WebServlet("/api/patients")
public class PatientServlet extends HttpServlet {
    private final PatientService service = new PatientService();
    private final Gson gson = new Gson();
@WebServlet("/api/patients") — this annotation registers the servlet with Tomcat at that URL path. No web.xml entry needed.
doGet() — GET /api/patients:

List<Patient> patients = service.getAllPatients();
writeJson(res, HttpServletResponse.SC_OK, patients);
Calls the service, gets a List<Patient>, hands it to Gson which converts the entire list to a JSON array automatically. Clean.
doPost() — POST /api/patients:

// 1. Read the raw JSON body text
StringBuilder body = new StringBuilder();
BufferedReader reader = req.getReader();
String line;
while ((line = reader.readLine()) != null) body.append(line);

// 2. Deserialize JSON text → Patient object (Gson does the mapping)
Patient patient = gson.fromJson(body.toString(), Patient.class);

// 3. Validate + save
int newId = service.addPatient(patient);
Gson's fromJson() maps JSON keys to Java field names automatically. {"name":"Riya","age":28} becomes a Patient object with name="Riya" and age=28.
HTTP status codes used:
Code	Meaning	When used
200 OK	Success	GET response
201 Created	Resource created	POST success
400 Bad Request	Client sent bad data	Validation failure
500 Internal Server Error	Server crashed	Unexpected exception
This is proper REST — the status code itself communicates what happened, not just the JSON body.

The Old Way vs The New Way
	Old (JSP scriptlets)	New (Layered)
SQL location	Scattered in 6 JSP files	Only in PatientDAO.java
DB credentials	Hardcoded everywhere	Only in DBConnection.java
JSON building	Manual string concat (bug-prone)	Gson (safe, automatic)
Validation	None	PatientService.validate()
HTTP status codes	Always 200	Correct 200/201/400/500
Testability	Cannot test without browser	Each layer testable independently
The Flow for a POST Request (end to end)

1. Browser sends:
   POST /MednetPatient/api/patients
   Body: {"name":"Riya","age":28,"gender":"Female","diagnosis":"Typhoid","doctorId":2}

2. Tomcat receives it → routes to PatientServlet.doPost()

3. Servlet reads the body text → Gson converts it to a Patient object

4. Servlet calls service.addPatient(patient)

5. Service.validate() checks: name not empty? age 1-149? gender valid?
   → If invalid: throws IllegalArgumentException
   → Servlet catches it → sends 400 {"success":false,"message":"..."}

6. If valid: service calls dao.addPatient(patient)

7. DAO builds a PreparedStatement, sets ? parameters safely, executes INSERT

8. MySQL inserts the row, returns auto-generated patient_id = 14

9. DAO returns 14 → Service returns 14 → Servlet receives 14

10. Servlet sends:
    201 Created
    {"success":true,"message":"Patient added successfully.","patientId":14}

Why This Matters for Spring Boot Later
Everything we just built is exactly how Spring Boot works, just with annotations doing the wiring automatically:
What we built manually	Spring Boot equivalent
PatientServlet extending HttpServlet	@RestController class
@WebServlet("/api/patients")	@GetMapping, @PostMapping
gson.fromJson(body, Patient.class)	@RequestBody Patient patient (auto)
PatientService class	@Service class (identical)
PatientDAO class	@Repository / JpaRepository
DBConnection.getConnection()	application.properties + auto-config
When you move to Spring Boot, your PatientService.java and PatientDAO.java will look almost identical — the architecture is the same, Spring just removes the boilerplate.
