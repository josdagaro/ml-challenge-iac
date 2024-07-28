# Arquitectura y Proceso de la Solución

Este archivo `architecture-and-workflow.md` tiene como propósito explicar la arquitectura y el proceso de la solución.
La solución aprovisionada por medio de infraestructura como código despliega los recursos en una cuenta AWS.

A continuación el diagrama:

![AWS Diagrama de Arquitectura](https://github.com/josdagaro/ml-challenge-iac/blob/main/docs/ml-challenge-aws.drawio.png)

## Explicación del Diagrama de Arquitectura

En este diagrama de alto nivel, vamos como la solución se despliega en una arquitectura HA (alta disponibilidad) usando dos zonas (A y B) de la región Virginia de AWS.

Esta cuenta AWS denominada "Account A" en el diagrama, donde se encuentra concentrada la solución, contiene una VPC con la siguiente topología de red:

- **Segmento de red de VPC**: 10.0.0.0/24
- **Segmento de subred pública (zona A)**: 10.0.0.0/26
- **Segmento de subred pública (zona B)**: 10.0.0.64/26
- **Segmento de subred privada (zona A)**: 10.0.0.128/26
- **Segmento de subred privada (zona B)**: 10.0.0.192/26

Y bajo esa misma topología de red, se cuenta con dos NAT Gateways alojados en las subredes públicas, los cuales permiten mediante sus IPs elásticas (públicas) asociadas, enrutar el tráfico hacia el Internet Gateway asociado a la VPC.

En otras palabras, en las tablas de rutas de la VPC:

- **Tablas de rutas privadas (una por zona)**: permiten enrutar el tráfico entre los componentes de las subredes privadas y tener salida a Internet mediante el respectivo NAT Gateway asociado a su zona.
- **Tablas de rutas públicas (una por zona)**: permiten enrutar el tráfico entre los componentes de la DMZ (zona demilitarizada), y tener salida a Internet mediante el Internet Gateway asociado a la VPC.

En las subredes privadas, podemos encontrar alojados los servicios principales de la solución, como lo son:

- **Application Load Balancer (ALB)**: Actúa como gateway permite balancear el tráfico hacia las diferentes réplicas de los servicios contenerizados de la solución (ECS).
- **Elastic Container Service (ECS)**: Cluster de servicios contenerizados en el cual se alojan los dos micro-servicios de la solución: `synchronizer` y `customers-mngr`.
- **RDS Serverless v2**: Cluster de RDS completamente serverless utilizando motor MySQL, en esta se contiene la base de datos de la solución donde se almacena la información de clientes obtenida de la API del proveedor.

Otros servicios importantes que participan en la funcionalidad principal de la solución son:
- **Route53**: Para poder crear el dominio personalizado del balanceador y también realizar validación de certificado SSL por medio de DNS.
- **Certificate Manager**: Donde se crea el certificado SSL a asociar en el balanceador de aplicación.
- **KMS**: Para garantizar integridad de la data en RDS y Secrets Manager, manteniendo encriptados ambos con una CMK.
- **Secrets Manager**: Donde se almacenan las credenciales del usuario admin de la base de datos RDS.
- **ECR**: Para el registro de imágenes de Docker de ambos micro-servicios: `synchronizer` y `customers-mngr`. Adicionalmente en este mismo servicio se analizan las imágenes para detección de vulnerabilidades.
- **EC2**: Para una instancia bastion de pruebas que permita desde el interior de la red privada, probar la visibilidad y funcionalidad correcta de los servicios.

En la parte inferior del diagrama se puede notar cómo se supone otras cuentas AWS de la empresa en incluso el datacenter on-premise alusivos a otras áreas de la empresa, son participes como posibles consumidores de la API interna para consulta de clientes posterior a su procesamiento y almacenamiento en la base de datos RDS.

Por motivos relacionados a costos y tiempo, para esta prueba, los recursos a ser aprovisionados en AWS no cubren estos posibles consumidores.

## Otros Servicios AWS Referenciados en el Diagrama de Arquitectura
En pos de un diseño de arquitectura en el cual la postura de seguridad es fundamental, en el diagrama vemos otros servicios AWS e incluso de proveedores externos propuestos como un extra en la solución (sin abordarlos en la prueba a nivel de código):

- **CloudTrail**: Suponiendo que la cuenta AWS participante de la solución hace parte de una estructura organizacional robusta por parte de la empresa en AWS, esta cuenta debe contar con un baseline mandatorio para registrar todos los eventos que sucedan en la misma. Como opcional se plantea la integración de un SIEM que reciba los eventos de CloudTrail (a nivel organizacional) que pueda analizar y detectar comportamientos anómalos.

- **GuardDuty**: En línea con el punto anterior, GuardDuty es ideal para el análisis de los eventos de CloudTrail, flow logs de VPC, e incluso de DNS en Route53.

- **Backup**: Es importante a nivel de seguridad contar con un buen plan de respaldos, donde se creen puntos de restauración con un RPO aceptable para el negocio y medidas de resguardo adicionales que permitan incluso proteger esos backups. Con esto se puede contraatacar ataques como Ransonware e incluso ante fallas regionales del servicio se pueden portar copias a otra región.

- **Transit Gateway**: Que permite interconectar múltiples VPCs e incluso centralizar conexiones VPN para tráfico hacia on-premise y otros destinos. En este escenario supuesto, otras VPCs de otras áreas de la empresa e incluso mediante conexión VPN con los servidores on-premise, logran consumir la API interna disponibilizada para obtener información de clientes.

- **Checkpoint CloudGuard**: Una herramienta paga de un tercero que permite analizar la postura de seguridad de los recursos ya alojados en una cuenta AWS, con esto se pueden desarrollar planes de mejora continua de la seguridad general de la infraestructura.

## Flujo de Despliegue con GitHub Actions

El flujo consta de dos fases, uno para revisión, y otro para aplicar los cambios de infraestructura por medio de código. A continuación el diagrama:

![Flujo Despliegue IaC GitHub](https://github.com/josdagaro/ml-challenge-iac/blob/main/docs/ml-challenge-gh.drawio.png)
