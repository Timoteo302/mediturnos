package com.mediturnos.controller;

import com.mediturnos.service.RecuperacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/recuperacion")
public class RecuperacionController {

    @Autowired
    private RecuperacionService recuperacionService;

    @Value("${mediturnos.recuperacion.modo-demostracion:true}")
    private boolean modoDemostracion;

    @PostMapping("/solicitar")
    public ResponseEntity<?> solicitar(@RequestBody Map<String, String> body) {
        Map<String, Object> respuesta = recuperacionService.solicitar(body, modoDemostracion);
        return ResponseEntity.ok(respuesta);
    }

    @PostMapping("/restablecer")
    public ResponseEntity<?> restablecer(@RequestBody Map<String, String> body) {
        recuperacionService.restablecer(body);
        return ResponseEntity.noContent().build();
    }
}
