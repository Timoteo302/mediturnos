package com.mediturnos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MediturnosApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(MediturnosApiApplication.class, args);
    }
}