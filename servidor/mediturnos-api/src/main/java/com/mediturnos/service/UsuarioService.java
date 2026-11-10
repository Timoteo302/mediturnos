package com.mediturnos.service;

import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public Usuario registrarUsuario(Usuario usuario, String dni, String telefono) {
        if (usuarioRepository.existsByEmail(usuario.getEmail())) {
            throw new RuntimeException("El email ya está registrado");
        }
        if (dni != null && pacienteRepository.existsByDni(dni)) {
            throw new RuntimeException("El DNI ya está registrado");
        }

        usuario.setContrasena(passwordEncoder.encode(usuario.getContrasena()));

        Usuario nuevoUsuario = usuarioRepository.save(usuario);

        if (nuevoUsuario.getRol() == Usuario.Rol.PACIENTE && dni != null) {
            Paciente paciente = new Paciente();
            paciente.setUsuario(nuevoUsuario);
            paciente.setDni(dni);
            paciente.setTelefono(telefono);
            pacienteRepository.save(paciente);
        }

        return nuevoUsuario;
    }

    public Optional<Usuario> login(String email, String contrasena) {
        Optional<Usuario> usuario = usuarioRepository.findByEmail(email);
        if (usuario.isPresent() && passwordEncoder.matches(contrasena, usuario.get().getContrasena())) {
            return usuario;
        }
        return Optional.empty();
    }
}