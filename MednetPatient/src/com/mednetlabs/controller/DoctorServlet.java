package com.mednetlabs.controller;

import com.google.gson.Gson;
import com.mednetlabs.model.Doctor;
import com.mednetlabs.service.DoctorService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * DoctorServlet — HTTP layer for /api/doctors.
 *
 * Endpoints:
 *   GET  /api/doctors          → list all doctors
 *   GET  /api/doctors?id=1     → get one doctor by ID
 *   POST /api/doctors          → add a new doctor
 */
@WebServlet("/api/doctors")
public class DoctorServlet extends HttpServlet {

    private final DoctorService service = new DoctorService();
    private final Gson gson = new Gson();

    // ── GET ──────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);

        try {
            String idParam = req.getParameter("id");

            if (idParam != null) {
                // GET /api/doctors?id=1
                int id = Integer.parseInt(idParam);
                Doctor doctor = service.getDoctorById(id);

                if (doctor == null) {
                    writeError(res, HttpServletResponse.SC_NOT_FOUND,
                            "Doctor with id " + id + " not found.");
                } else {
                    writeJson(res, HttpServletResponse.SC_OK, doctor);
                }
            } else {
                // GET /api/doctors
                writeJson(res, HttpServletResponse.SC_OK, service.getAllDoctors());
            }

        } catch (NumberFormatException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, "id must be a number.");
        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to fetch doctors: " + e.getMessage());
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    //
    //  Expected JSON body:
    //  {
    //    "name":      "Dr. Priya Sharma",
    //    "specialty": "Cardiology",
    //    "phone":     "9810001234",     // optional
    //    "email":     "priya@mednetlabs.in"  // optional
    //  }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        setJsonResponse(res);

        try {
            StringBuilder body = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) body.append(line);

            if (body.toString().trim().isEmpty()) {
                writeError(res, HttpServletResponse.SC_BAD_REQUEST, "Request body is empty.");
                return;
            }

            Doctor doctor = gson.fromJson(body.toString(), Doctor.class);
            Doctor saved = service.addDoctor(doctor);

            writeJson(res, HttpServletResponse.SC_CREATED, saved);

        } catch (IllegalArgumentException e) {
            writeError(res, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            writeError(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Server error: " + e.getMessage());
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
