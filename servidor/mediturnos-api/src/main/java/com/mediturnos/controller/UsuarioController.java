package com.mediturnos.controller;

import com.mediturnos.dto.UsuarioRespuesta;
import com.mediturnos.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/usuarios")
    public ResponseEntity<UsuarioRespuesta> registrar(@RequestBody Map<String, String> body) {
        UsuarioRespuesta creado = usuarioService.registrarUsuario(body);
        return ResponseEntity.status(HttpStatus.CREATED).body(creado);
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioRespuesta> login(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String contrasena = body.get("contrasena");

        UsuarioRespuesta respuesta = usuarioService.login(email, contrasena);
        return ResponseEntity.ok(respuesta);
    }
}
