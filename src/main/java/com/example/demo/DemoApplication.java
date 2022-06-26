package com.example.demo;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication implements ApplicationRunner {

    public DemoApplication(DriverRepository driverRepository) {
        this.driverRepository = driverRepository;
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    private final DriverRepository driverRepository;

    @Override
    public void run(ApplicationArguments args) {
        Driver driver = new Driver("aaa");
        Driver savedDriver = driverRepository.save(driver);

        System.out.printf("%s,%s", savedDriver.id, savedDriver.test);

    }
}
