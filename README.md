# \# AWS Multi-Tier Secure Architecture with Terraform \& LocalStack\[cite: 1]

# 

# Este proyecto despliega una arquitectura en la nube de 3 capas seguras siguiendo las mejores prácticas de AWS\[cite: 1].

# 

# \## 🏗️ Arquitectura Desplegada\[cite: 1]

# 

# \* \*\*VPC:\*\* Red principal aislada (`10.0.0.0/16`)\[cite: 1].

# \* \*\*Subred Pública:\*\* Subred (`10.0.1.0/24`) expuesta a internet\[cite: 1].

# \* \*\*Subred Privada Web:\*\* Subred (`10.0.2.0/24`) para la instancia de aplicación web\[cite: 1].

# \* \*\*Subred Privada BBDD:\*\* Subred (`10.0.3.0/24`) para la base de datos PostgreSQL\[cite: 1].

# 

# \## 🛡️ Seguridad Multi-Capa (Security Groups \& NACL)\[cite: 1]

# 

# 1\. \*\*Security Groups (Stateful - Nivel Instancia):\*\*\[cite: 1]

# &#x20;  \* SG Frontend: Permite acceso público HTTP (80)\[cite: 1].

# &#x20;  \* SG Web: Solo acepta tráfico del SG Frontend (80)\[cite: 1].

# &#x20;  \* SG BBDD: Solo acepta tráfico del SG Web (5432)\[cite: 1].

# 

# 2\. \*\*Network ACLs (Stateless - Nivel Subred):\*\*\[cite: 1]

# &#x20;  \* NACL BBDD: Permite tráfico de entrada en el puerto 5432 solo desde la Subred Web (`10.0.2.0/24`) y salida por puertos efímeros (`1024-65535`)\[cite: 1].

