package com.mednetlabs.model;

import javax.persistence.*;

@Entity
@Table(name = "doctors")
public class Doctor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "doctor_id")
    private int id;

    @Column(name = "doctor_name")
    private String name;

    @Column(name = "specialty")
    private String specialty;

    @Column(name = "phone")
    private String phone;

    @Column(name = "email")
    private String email;

    // Getters
    public int getId() { return id; }
    public String getName() { return name; }
    public String getSpecialty() { return specialty; }
    public String getPhone() { return phone; }
    public String getEmail() { return email; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setSpecialty(String s) { this.specialty = s; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setEmail(String email) { this.email = email; }
}