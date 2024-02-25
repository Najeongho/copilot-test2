package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;

@RestController
public class HelloController {

    @Autowired
    private HelloRepository helloRepository;

    @GetMapping("/hello")
    public String hello() {
        Hello hello = new Hello();
        hello.setMessage("Hello, Spring Boot!");
        helloRepository.save(hello);
        return hello.getMessage();
    }
}