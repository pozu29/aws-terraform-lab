# AWS Infrastructure with Terraform (LocalStack)

Este repositorio contiene una arquitectura automatizada en AWS utilizando **Terraform** como herramienta de Infraestructura como Código (IaC). 

El proyecto está diseñado para ser desplegado tanto en **AWS Cloud** como en entornos de pruebas locales mediante **LocalStack**.

## 🏗️ Arquitectura Desplegada

- **VPC**: Red privada virtual aislada (10.0.0.0/16).
- **Subredes**:
  - Subred Pública (10.0.1.0/24) para recursos expuestos a internet.
  - Subred Privada (10.0.2.0/24) para capas internas/bases de datos.
- **Security Group**: Cortafuegos con reglas de ingreso restringidas (Puertos HTTP 80 y SSH 22).
- **EC2 Instance**: Servidor virtual Linux (t2.micro) desplegado dentro de la subred pública.

## 🚀 Despliegue Local (LocalStack)

### Requisitos
- Docker Desktop
- Terraform CLI
- AWS CLI

### Instrucciones
1. Iniciar LocalStack:
   docker run --rm -it -e DISABLE_EVENTS=1 -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:3.0

2. Inicializar Terraform:
   terraform init

3. Aplicar la infraestructura:
   terraform apply
