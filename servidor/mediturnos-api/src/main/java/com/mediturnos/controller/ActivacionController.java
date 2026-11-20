package com.mediturnos.controller;

import com.mediturnos.dto.UsuarioRespuesta;
import com.mediturnos.service.ActivacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Endpoints para la activación de cuentas (invitados).
 */
@RestController
@RequestMapping("/activacion")
@CrossOrigin(origins = "*")
public class ActivacionController {

    @Autowired
    private ActivacionService activacionService;

    /**
     * Confirma la activación con el código y guarda la nueva contraseña.
     */
    @PostMapping("/confirmar")
    public ResponseEntity<UsuarioRespuesta> confirmar(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String codigo = body.get("codigo");
        String contrasena = body.get("contrasena");

        UsuarioRespuesta respuesta = activacionService.confirmar(email, codigo, contrasena);
        return ResponseEntity.ok(respuesta);
    }

    /**
     * Reenvía el código de activación.
     */
    @PostMapping("/reenviar")
    public ResponseEntity<Map<String, Object>> reenviar(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String codigo = activacionService.reenviar(email);
        
        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("venceEnDias", 7);
        if (codigo != null) {
            respuesta.put("codigoDemostracion", codigo);
        }
        return ResponseEntity.ok(respuesta);
    }
}
