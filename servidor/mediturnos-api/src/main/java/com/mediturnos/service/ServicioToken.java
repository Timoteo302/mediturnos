package com.mediturnos.service;

import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.nimbusds.jose.jwk.JWK;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.OctetSequenceKey;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;

/**
 * Servicio encargado de la generación y validación de tokens JWT utilizando Spring Security y Nimbus.
 */
@Service
public class ServicioToken {

    @Value("${mediturnos.jwt.secreto:}")
    private String secretoBase64;

    @Value("${mediturnos.jwt.duracion-horas:168}")
    private long duracionHoras;

    @Autowired
    private PacienteRepository pacienteRepository;

    private JwtEncoder jwtEncoder;
    private JwtDecoder jwtDecoder;

    public record ResultadoToken(String token, Instant venceEn) {}

    @PostConstruct
    public void init() {
        if (secretoBase64 == null || secretoBase64.isBlank()) {
            throw new IllegalStateException("Falta configurar MEDITURNOS_JWT_SECRETO (mínimo 32 bytes en Base64)");
        }

        byte[] bytes;
        try {
            bytes = Base64.getDecoder().decode(secretoBase64.trim());
        } catch (Exception e) {
            throw new IllegalStateException("Falta configurar MEDITURNOS_JWT_SECRETO (mínimo 32 bytes en Base64)");
        }

        if (bytes.length < 32) {
            throw new IllegalStateException("Falta configurar MEDITURNOS_JWT_SECRETO (mínimo 32 bytes en Base64)");
        }

        SecretKey key = new SecretKeySpec(bytes, "HmacSHA256");

        this.jwtDecoder = NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();

        JWK jwk = new OctetSequenceKey.Builder(key).build();
        JWKSource<SecurityContext> jwks = new ImmutableJWKSet<>(new JWKSet(jwk));
        this.jwtEncoder = new NimbusJwtEncoder(jwks);
    }

    public JwtDecoder getJwtDecoder() {
        return jwtDecoder;
    }

    /**
     * Genera un token JWT para el usuario con los claims id, email, rol, pacienteId, iat y exp.
     */
    public ResultadoToken generar(Usuario usuario) {
        Instant ahora = Instant.now();
        Instant expira = ahora.plus(duracionHoras, ChronoUnit.HOURS);

        Integer pacienteId = null;
        if (usuario.getRol() == Usuario.Rol.PACIENTE) {
            pacienteId = pacienteRepository.findByUsuarioId(usuario.getId())
                    .map(Paciente::getId)
                    .orElse(null);
        }

        JwtClaimsSet.Builder claimsBuilder = JwtClaimsSet.builder()
                .subject(String.valueOf(usuario.getId()))
                .claim("email", usuario.getEmail())
                .claim("rol", usuario.getRol().name())
                .issuedAt(ahora)
                .expiresAt(expira);

        if (pacienteId != null) {
            claimsBuilder.claim("pacienteId", pacienteId);
        }

        JwtClaimsSet claims = claimsBuilder.build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();

        String token = jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
        return new ResultadoToken(token, expira);
    }
}
