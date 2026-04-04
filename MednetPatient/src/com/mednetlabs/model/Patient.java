package com.mednetlabs.model;

import com.google.gson.annotations.SerializedName;

import javax.persistence.*;
import javax.persistence.Transient;

@Entity
@Table(name = "patients")
public class Patient {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "patient_id")
    private int id;
    @Column(name = "patient_name")
    private String name;
    private int age;
    private String gender;
    private String diagnosis;

    @SerializedName("doctorId")
    @Column(name = "doctor_id")
    private Integer doctorId;       

    @SerializedName("doctorName")
    @Column(name = "doctor_name")
    @Transient
    private String doctorName;      

    @SerializedName("admittedOn")
    @Column(name = "admitted_on")
    private String admittedOn;      

    private String status;

    

    public int getId()          { return id; }
    public String getName()     { return name; }
    public int getAge()         { return age; }
    public String getGender()   { return gender; }
    public String getDiagnosis(){ return diagnosis; }
    public Integer getDoctorId(){ return doctorId; }
    public String getDoctorName(){ return doctorName; }
    public String getAdmittedOn(){ return admittedOn; }
    public String getStatus()   { return status; }

    

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
