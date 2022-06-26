package com.example.demo;


import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Driver {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Integer id;

    String test;

    public Driver() {
    }

    public Driver(String test) {
        this.test = test;
    }

    public Integer getId() {
        return id;
    }

    public String getTest() {
        return test;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setTest(String test) {
        this.test = test;
    }
}
