package com.mediturnos.controller;

import com.mediturnos.model.Usuario;
import com.mediturnos.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/usuarios")
    public ResponseEntity<?> registrar(@RequestBody Map<String, String> body) {
        try {
            Usuario usuario = new Usuario();
            usuario.setNombre(body.get("nombre"));
            usuario.setApellido(body.get("apellido"));
            usuario.setEmail(body.get("email"));
            usuario.setContrasena(body.get("contrasena"));

            String dni = body.get("dni");
            String telefono = body.get("telefono");

            Usuario creado = usuarioService.registrarUsuario(usuario, dni, telefono);
            return ResponseEntity.status(HttpStatus.CREATED).body(creado);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String contrasena = body.get("contrasena");

        Optional<Usuario> usuario = usuarioService.login(email, contrasena);
        if (usuario.isPresent()) {
            return ResponseEntity.ok(usuario.get());
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Credenciales inválidas"));
    }
}