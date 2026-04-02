package com.mednetlabs.model;

import com.google.gson.annotations.SerializedName;

public class Patient {

    private int id;
    private String name;
    private int age;
    private String gender;
    private String diagnosis;

    @SerializedName("doctorId")
    private Integer doctorId;       // Integer (not int) — can be NULL in DB

    @SerializedName("doctorName")
    private String doctorName;      // populated on GET via JOIN, not stored

    @SerializedName("admittedOn")
    private String admittedOn;      // DATE as String (yyyy-MM-dd)

    private String status;

    // ── Getters ──────────────────────────────────────────────────────────────

    public int getId()          { return id; }
    public String getName()     { return name; }
    public int getAge()         { return age; }
    public String getGender()   { return gender; }
    public String getDiagnosis(){ return diagnosis; }
    public Integer getDoctorId(){ return doctorId; }
    public String getDoctorName(){ return doctorName; }
    public String getAdmittedOn(){ return admittedOn; }
    public String getStatus()   { return status; }

    // ── Setters ──────────────────────────────────────────────────────────────

    public void setId(int id)               { this.id = id; }
    public void setName(String name)        { this.name = name; }
    public void setAge(int age)             { this.age = age; }
    public void setGender(String gender)    { this.gender = gender; }
    public void setDiagnosis(String d)      { this.diagnosis = d; }
    public void setDoctorId(Integer did)    { this.doctorId = did; }
    public void setDoctorName(String dn)    { this.doctorName = dn; }
    public void setAdmittedOn(String ao)    { this.admittedOn = ao; }
    public void setStatus(String status)    { this.status = status; }
}
