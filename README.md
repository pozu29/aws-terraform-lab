# AWS Multi-Tier Secure Architecture with Terraform & LocalStack

Este proyecto despliega una arquitectura en la nube de 3 capas seguras.

## Arquitectura Desplegada
* VPC: 10.0.0.0/16
* Subred Publica: 10.0.1.0/24
* Subred Privada Web: 10.0.2.0/24
* Subred Privada BBDD: 10.0.3.0/24

## Seguridad Multi-Capa
1. SG Frontend: Permite acceso publico HTTP (80).
2. SG Servidor Web: Solo acepta trafico del SG Frontend (80).
3. SG Base de Datos: Solo acepta trafico del SG Servidor Web (5432).
