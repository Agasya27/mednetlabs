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
 *
 * Endpoints:
 *   GET    /api/patients          → list all patients
 *   POST   /api/patients          → add a new patient
 *   PUT    /api/patients?id=1     → update an existing patient (partial update)
 *   DELETE /api/patients?id=1     → delete a patient
 */
@WebServlet("/api/patients")
public class PatientServlet extends HttpServlet {

    private final PatientService service = new PatientService();
    private final Gson gson = new Gson();

    // ── GET ──────────────────────────────────────────────────────────────────

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

    // ── POST ─────────────────────────────────────────────────────────────────
    //
    //  Body: { "name":"Riya","age":28,"gender":"Female","diagnosis":"Typhoid",
    //          "doctorId":2, "status":"Active" }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);
        try {
            Patient patient = parseBody(req, res);
            if (patient == null) return;

            int newId = service.addPatient(patient);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Patient added successfully.");
            result.put("patientId", newId);
            writeJson(res, HttpServletResponse.SC_CREATED, result);

        } catch (IllegalArgumentException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Server error: " + e.getMessage());
        }
    }

    // ── PUT ──────────────────────────────────────────────────────────────────
    //
    //  URL:  PUT /api/patients?id=5
    //  Body: any fields you want to change (only sent fields are updated)
    //  { "diagnosis":"Malaria", "status":"Discharged" }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);
        try {
            String idParam = req.getParameter("id");
            if (idParam == null) {
                writeError(res, HttpServletResponse.SC_BAD_REQUEST,
                        "Query parameter 'id' is required.");
                return;
            }

            int id = Integer.parseInt(idParam);
            Patient incoming = parseBody(req, res);
            if (incoming == null) return;

            Patient updated = service.updatePatient(id, incoming);
            writeJson(res, HttpServletResponse.SC_OK, updated);

        } catch (NumberFormatException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, "id must be a number.");
        } catch (IllegalArgumentException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Update failed: " + e.getMessage());
        }
    }

    // ── DELETE ───────────────────────────────────────────────────────────────
    //
    //  URL:  DELETE /api/patients?id=5

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);
        try {
            String idParam = req.getParameter("id");
            if (idParam == null) {
                writeError(res, HttpServletResponse.SC_BAD_REQUEST,
                        "Query parameter 'id' is required.");
                return;
            }

            int id = Integer.parseInt(idParam);
            service.deletePatient(id);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Patient deleted successfully.");
            writeJson(res, HttpServletResponse.SC_OK, result);

        } catch (NumberFormatException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, "id must be a number.");
        } catch (IllegalArgumentException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Delete failed: " + e.getMessage());
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    /** Reads + parses the JSON request body. Returns null and writes a 400 if body is empty. */
    private Patient parseBody(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        StringBuilder body = new StringBuilder();
        BufferedReader reader = req.getReader();
        String line;
        while ((line = reader.readLine()) != null) body.append(line);

        if (body.toString().trim().isEmpty()) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, "Request body is empty.");
            return null;
        }
        return gson.fromJson(body.toString(), Patient.class);
    }

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
