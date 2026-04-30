# AuthCore — Sistema de Autenticación Centralizado por Microservicios

Sistema de autenticación distribuido basado en microservicios, diseñado para centralizar el control de identidad de múltiples aplicaciones. Permite gestionar usuarios, perfiles por aplicación y autenticación con múltiples proveedores (Google y login tradicional), emitiendo tokens JWT con contexto específico por aplicación.

---

## Descripcion del proyecto

AuthCore es una plataforma de autenticación que separa la responsabilidad de identidad del resto de los servicios de negocio. En lugar de que cada aplicación maneje su propio sistema de login, todas delegan esa responsabilidad a un servicio centralizado que autentica, valida y emite tokens con la información necesaria para cada contexto.

El sistema permite:

- Login centralizado para múltiples aplicaciones desde un único punto de entrada
- Autenticación con email y contraseña
- Autenticación con Google OAuth2
- Manejo de múltiples perfiles por usuario (un mismo usuario puede tener roles distintos en App1 y App2)
- Control de acceso diferenciado por aplicación
- Emisión de JWT con contexto de aplicación incluido en el payload
- Integración con microservicios en diferentes tecnologías (Node.js, .NET, Spring Boot)

---

## Arquitectura

El sistema está compuesto por los siguientes servicios:

| Servicio | Tecnología | Responsabilidad |
|---|---|---|
| API Gateway | Spring Cloud Gateway (Java) | Punto único de entrada, enrutamiento de tráfico |
| Auth Service | Spring Boot + MySQL | Registro, login, emisión de JWT |
| App1 | Node.js + Express | Microservicio de aplicación |
| App2 | .NET | Microservicio de aplicación |

```
Cliente / Frontend
        │
        ▼  :8080
 [ API Gateway ]   ← único punto de entrada público
        │
        ├── /auth/**   →  [ Auth Service  :8090 ]  ← Spring Boot + MySQL
        ├── /micro1/** →  [ App1          :3000 ]  ← Node.js + Express
        └── /app2/**   →  [ App2          :4000 ]  ← .NET (próximamente)
```

Todos los servicios corren en contenedores Docker dentro de una red privada. Solo el gateway está expuesto al exterior.

---

## Flujo de autenticación

1. El usuario accede a una aplicación cliente
2. Es redirigido al Auth Service a través del gateway
3. Se autentica con email/password o con Google
4. El Auth Service valida credenciales y perfiles
5. Se genera un JWT firmado con contexto de aplicación
6. El cliente usa ese token para consumir los microservicios protegidos

El token JWT generado contiene:

```json
{
  "sub": "usuario@email.com",
  "app": "APP1",
  "roles": ["ADMIN"]
}
```

---

## Ventajas de esta arquitectura

**Separacion de responsabilidades** — La autenticación es un dominio propio. Cada microservicio de negocio no necesita saber cómo autenticar usuarios, solo validar el token que recibe.

**Escalabilidad independiente** — Cada servicio puede escalar por separado. Si el Auth Service recibe mucha carga, se escala solo sin afectar a los demás.

**Tecnología heterogénea** — Los microservicios pueden estar en cualquier lenguaje o framework. El gateway y el token JWT son el contrato común entre todos.

**Aislamiento de fallos** — Si un microservicio falla, los demás siguen funcionando. El gateway responde con error solo en las rutas afectadas.

**Despliegue simplificado** — Con un solo comando se levanta todo el ecosistema en cualquier máquina que tenga Docker, sin instalar dependencias manualmente.

---

## Stack tecnológico

| Tecnología | Uso |
|---|---|
| Spring Boot 4.0.6 | Auth Service y base del gateway |
| Spring Cloud Gateway MVC 2025.1.1 | Enrutamiento y proxy inverso |
| Spring Data JPA + Hibernate | Persistencia en Auth Service |
| MySQL 8.0 | Base de datos del Auth Service |
| Node.js 20 + Express 5 | Microservicio App1 |
| Docker + Docker Compose | Contenedorización y orquestación |
| JWT | Tokens de autenticación stateless |

---

## Requisitos

| Herramienta | Version minima |
|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | 24+ |
| Docker Compose | incluido en Docker Desktop |

No necesitas tener Java, Node.js ni Maven instalados localmente. Todo corre dentro de Docker.

---

## Levantar el proyecto

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/AAAIMX.git
cd AAAIMX

# 2. Dar permisos al script (solo la primera vez en Mac/Linux)
chmod +x stack.sh

# 3. Levantar todo el stack
./stack.sh up
```

La primera vez tarda 3-5 minutos porque Maven y npm descargan dependencias dentro de Docker. Las siguientes veces es mucho más rápido al usar caché.

> El gateway tarda ~15 segundos en estar listo después de que Docker reporta el contenedor como iniciado. Si recibes `Connection reset by peer`, espera unos segundos y vuelve a intentar.

---

## Comandos disponibles

```bash
./stack.sh up                  # Construye imagenes y levanta todo
./stack.sh down                # Baja contenedores (datos de BD se conservan)
./stack.sh clean               # Baja contenedores y borra la base de datos
./stack.sh logs                # Logs de todos los servicios en tiempo real
./stack.sh logs gateway        # Logs solo del gateway
./stack.sh logs auth           # Logs solo del auth
./stack.sh ps                  # Estado de todos los contenedores
./stack.sh rebuild gateway     # Reconstruye solo el gateway
./stack.sh rebuild auth        # Reconstruye solo el auth
```

---

## URLs locales

| Servicio | URL |
|---|---|
| API Gateway | http://localhost:8080 |
| Auth Service (directo) | http://localhost:8090 |
| App1 / Micro1 (directo) | http://localhost:3000 |
| MySQL | localhost:3307 |

---

## Probar los endpoints

```bash
# Ping al microservicio App1 via gateway
curl http://localhost:8080/micro1/api/test/ping

# Saludo personalizado
curl http://localhost:8080/micro1/api/test/greet/TuNombre

# Echo de body JSON
curl -X POST http://localhost:8080/micro1/api/test/echo \
  -H "Content-Type: application/json" \
  -d '{"mensaje": "hola mundo"}'
```

---

## Estructura de repositorios

Este proyecto sigue el patrón **polyrepo**: la infraestructura central vive en un repositorio y cada microservicio de negocio tiene el suyo propio.

```
Repo: AAAIMX  (este repositorio — infraestructura central)
├── docker-compose.yml        # Levanta auth + gateway + mysql + crea la red aaaimx-net
├── stack.sh
├── auth/                     # Auth Service — Spring Boot
└── gateway/                  # API Gateway — Spring Cloud Gateway MVC

Repo: aaaimx_micro1  (repositorio independiente)
├── docker-compose.yml        # Se une a la red aaaimx-net existente
├── micro1.sh
├── Dockerfile
└── src/

Repo: aaaimx_micro2  (repositorio independiente — próximamente)
└── ...
```

Todos los microservicios se comunican a través de la red Docker `aaaimx-net` sin importar en qué repositorio estén.

---

## Agregar un nuevo microservicio (desde su propio repo)

1. Crea el repo del nuevo servicio con su `Dockerfile`

2. Crea un `docker-compose.yml` que se una a la red externa:

```yaml
services:
  nuevoservicio:
    build: .
    container_name: nuevoservicio-service
    ports:
      - "XXXX:XXXX"
    networks:
      - aaaimx-net

networks:
  aaaimx-net:
    external: true
    name: aaaimx-net
```

3. Agrega la ruta en `gateway/src/main/resources/application.yml` (en este repo):

```yaml
- id: nuevoservicio-route
  uri: http://nuevoservicio-service:XXXX
  predicates:
    - Path=/nuevoservicio/**
  filters:
    - StripPrefix=1
```

4. Reconstruye el gateway:

```bash
docker compose build --no-cache gateway && docker compose up -d gateway
```

> El nombre en `uri:` debe coincidir con el `container_name` definido en el `docker-compose.yml` del microservicio.

---

## Notas tecnicas

- En Spring Boot 4.0.x el property de rutas cambio de `spring.cloud.gateway.mvc.routes` a `spring.cloud.gateway.server.webmvc.routes`
- Los servicios se comunican por nombre de contenedor dentro de la red `aaaimx-net` (ejemplo: `http://auth:8090`)
- MySQL persiste datos en el volumen `auth-mysql-data`. Solo se elimina con `./stack.sh clean`
- Todos los servicios tienen `restart: unless-stopped` para recuperarse automaticamente ante fallos
- Las imagenes Docker usan multi-stage build para reducir el tamaño final y usuarios no-root por seguridad
