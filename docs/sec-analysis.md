# Análisis y Recomendaciones de Seguridad

A continuación una serie de apuntes referentes a la seguridad sobre las partes que involucran la solución:

1. La API del provider (https://62433a7fd126926d0c5d296b.mockapi.io/api/v1/usuarios): Se entiende que para este ejercicio es una servicio mock, el cual responde información elaborada con un faker, no se dejó de lado contemplar el análisis de seguridad bajo la suposición de un escenario productivo real. Es importante que una API expuesta por un proveedor a Internet, tenga controles de seguridad adicionales al cifrado en tránsito, por ejemplo, involucrar un API key o un token único por consumidor, para poder protegerse con una cuota de uso de ser necesario. Si bien es responsabilidad total del proveedor, no descarta señalar las consideraciones necesarias de seguridad que deban hacerse.

2. La visibilidad de los servicios de la solución en la red interna: Es importante que los servicios se encuentren alojados en la red interna, ninguno (en mi escenario) será consumido a través de Internet. En ese caso el tráfico saliente de los servicios ECS, es limitado hacia los recursos que necesiten, por otro lado, el tráfico que llega debe ser limitado a los segmentos de red de las áreas de la empresa que requieran consumir el servicio. Como uno de estos servicios internos en ECS exponen una API de uso interno a través de un balanceador, también se deben limitar el protocolo a usar, en cuyo caso debe ser HTTPS.

3. La conectividad a la instancia bastion EC2 para realización de pruebas: La instancia debe estar alojada en la subredes privadas, sin acceso público desde Internet, ni protocolo SSH, u otro, el acceso únicamente debe darse por medio de AWS Sessions Manager, por lo cuál lo recomendable es usar una instancia Amazon Linux II, que trae el agente SSM pre instalado y listo para garantizar una conexión segura desde la consola AWS o vía AWS CLI hacia la máquina EC2.

4. La base de datos RDS: Solo debe ser alcanzada por los servicios ECS, con un plan de backup robusto, garantizando un RTO aceptable por el negocio y con su respectiva encriptación en reposo y en tránsito.

5. Registro privado en ECR: Debe tener activo el escaneo de imágenes Docker para analizar y detectar vulnerabilidades, clasificadas por criticidad con el poder solventarlas por prioridad y garantizar un funcionamiento seguro de las aplicaciones contenerizadas.
