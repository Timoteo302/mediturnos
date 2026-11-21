package com.mediturnos.config;

import com.mediturnos.exception.ManejadorAccesoDenegado;
import com.mediturnos.exception.ManejadorAutenticacionNoAutorizada;
import com.mediturnos.service.ServicioToken;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Collections;
import java.util.List;

/**
 * Configuración de seguridad con Spring Security, JWT stateless y control de accesos por rol.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class ConfiguracionSeguridad {

    @Autowired
    private ServicioToken servicioToken;

    @Autowired
    private ManejadorAutenticacionNoAutorizada autenticacionNoAutorizadaHandler;

    @Autowired
    private ManejadorAccesoDenegado accesoDenegadoHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(autenticacionNoAutorizadaHandler)
                .accessDeniedHandler(accesoDenegadoHandler)
            )
            .authorizeHttpRequests(auth -> auth
                // Rutas públicas (permitAll)
                .requestMatchers(HttpMethod.GET, "/salud").permitAll()
                .requestMatchers(HttpMethod.POST, "/login").permitAll()
                .requestMatchers(HttpMethod.POST, "/usuarios").permitAll()
                .requestMatchers(HttpMethod.POST, "/recuperacion/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/activacion/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/reservas/invitado").permitAll()
                .requestMatchers("/respuesta-turno/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/especialidades").permitAll()
                .requestMatchers(HttpMethod.GET, "/medicos").permitAll()
                .requestMatchers(HttpMethod.GET, "/medicos/*").permitAll()
                .requestMatchers(HttpMethod.GET, "/medicos/*/horarios").permitAll()
                .requestMatchers(HttpMethod.GET, "/medicos/*/disponibilidad").permitAll()
                .requestMatchers("/error").permitAll()

                // Solo ADMIN
                .requestMatchers(HttpMethod.POST, "/especialidades/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/especialidades/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PATCH, "/especialidades/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.POST, "/medicos/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/medicos/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PATCH, "/medicos/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/turnos/*").hasRole("ADMIN")

                // Resto requiere estar autenticado
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt
                    .decoder(servicioToken.getJwtDecoder())
                    .jwtAuthenticationConverter(jwtAuthenticationConverter())
                )
                .authenticationEntryPoint(autenticacionNoAutorizadaHandler)
                .accessDeniedHandler(accesoDenegadoHandler)
            );

        return http.build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            String rol = jwt.getClaimAsString("rol");
            if (rol == null || rol.isBlank()) {
                return Collections.emptyList();
            }
            return List.of(new SimpleGrantedAuthority("ROLE_" + rol));
        });
        return converter;
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
