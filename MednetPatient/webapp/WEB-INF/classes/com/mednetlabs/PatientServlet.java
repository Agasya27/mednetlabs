package com.mednetlabs;

import com.google.gson.Gson;
import com.mednetlabs.model.Patient;
import com.mednetlabs.service.PatientService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PatientServlet — thin HTTP layer only.
 * Reads the request, delegates to PatientService, writes JSON response.
 * No SQL, no business logic here.
 *
 * Endpoints:
 *   GET  /api/patients          → list all patients
 *   POST /api/patients          → add a new patient
 */
@WebServlet("/api/patients")
public class PatientServlet extends HttpServlet {

    private final PatientService service = new PatientService();
    private final Gson gson = new Gson();

    // ── GET /api/patients ────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);

        try {
            List<Patient> patients = service.getAllPatients();
            writeJson(res, HttpServletResponse.SC_OK, patients);

        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to fetch patients: " + e.getMessage());
        }
    }

    // ── POST /api/patients ───────────────────────────────────────────────────
    //
    //  Expected JSON body:
    //  {
    //    "name":      "Riya Sharma",
    //    "age":       28,
    //    "gender":    "Female",          // Male | Female | Other
    //    "diagnosis": "Typhoid",
    //    "doctorId":  2,                 // optional — omit or 0 if unassigned
    //    "status":    "Active"           // optional — defaults to Active
    //  }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);

        try {
            // 1. Read full request body
            StringBuilder body = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }

            if (body.toString().trim().isEmpty()) {
                writeError(res, HttpServletResponse.SC_BAD_REQUEST,
                        "Request body is empty.");
                return;
            }

            // 2. Deserialize JSON → Patient  (Gson handles this cleanly)
            Patient patient = gson.fromJson(body.toString(), Patient.class);

            // 3. Validate + insert via service layer
            int newId = service.addPatient(patient);

            // 4. Return 201 Created with the new patient's id
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Patient added successfully.");
            result.put("patientId", newId);
            writeJson(res, HttpServletResponse.SC_CREATED, result);

        } catch (IllegalArgumentException e) {
            // Validation errors (bad input from client)
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());

        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Server error: " + e.getMessage());
        }
    }
    @Override
protected void doDelete(HttpServletRequest req, HttpServletResponse res)
        throws IOException {

    setJsonResponse(res);

    try {
        String idParam = req.getParameter("id");

        if (idParam == null) {
            throw new IllegalArgumentException("ID parameter is required");
        }

        int id = Integer.parseInt(idParam);

        service.deletePatient(id);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "Patient deleted successfully.");

        writeJson(res, HttpServletResponse.SC_OK, result);

    } catch (IllegalArgumentException e) {
        writeError(res, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());

    } catch (Exception e) {
        writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Delete failed: " + e.getMessage());
    }
}

    // ── Helpers ──────────────────────────────────────────────────────────────

    private void setJsonResponse(HttpServletResponse res) {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
    }

    private void writeJson(HttpServletResponse res, int status, Object data)
            throws IOException {
        res.setStatus(status);
        PrintWriter out = res.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    private void writeError(HttpServletResponse res, int status, String message)
            throws IOException {
        Map<String, Object> err = new HashMap<>();
        err.put("success", false);
        err.put("message", message);
        writeJson(res, status, err);
    }
}
