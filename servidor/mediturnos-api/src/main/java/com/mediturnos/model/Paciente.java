package com.mediturnos.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "pacientes")
@Data
public class Paciente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    private Usuario usuario;

    @Column(nullable = false, unique = true, length = 20)
    private String dni;

    @Column(length = 30)
    private String telefono;
}