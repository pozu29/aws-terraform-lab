# AWS Two-Tier Architecture with Terraform (LocalStack)

Este repositorio contiene la automatización de una arquitectura de dos capas (Two-Tier) en AWS utilizando **Terraform** (IaC) y **LocalStack**.

## 🏗️ Arquitectura Desplegada

- **VPC**: Red privada virtual (10.0.0.0/16).
- **Capas de Subredes**:
  - Subred Pública (10.0.1.0/24): Servidor Web EC2 con acceso público (HTTP 80 / SSH 22).
  - Subred Privada (10.0.2.0/24): Servidor de Base de Datos EC2 aislado de internet.
- **Seguridad**:
  - Web SG: Permite tráfico HTTP (80) y SSH (22) público.
  - DB SG: Restringe el acceso PostgreSQL (5432) **únicamente a peticiones originadas desde la EC2 pública**.

## 🚀 Despliegue Local

1. Iniciar contenedor de LocalStack:
   docker run --rm -it -e DISABLE_EVENTS=1 -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:3.0

2. Aplicar configuración:
   terraform init
   terraform apply
