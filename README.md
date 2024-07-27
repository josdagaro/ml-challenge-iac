# ml-challenge-iac

Este archivo `README.md` proporciona una guía paso a paso para configurar y ejecutar Terraform, asegurando que los usuarios comprendan todos los pasos necesarios para gestionar su infraestructura en AWS.

## Terraform AWS Infrastructure Setup

Este proyecto utiliza Terraform para configurar una infraestructura en AWS que incluye un VPC, ECS Cluster, ALB, RDS Aurora Serverless, y más. Asegúrate de tener una cuenta de AWS y un bucket de S3 para almacenar el estado de Terraform.

## Prerrequisitos

1. **Cuenta de AWS:** Debes tener una cuenta de AWS activa.
2. **Bucket S3:** Necesitas un bucket S3 para almacenar el estado de Terraform.
3. **Credenciales de AWS:** Exporta las credenciales de tu cuenta de AWS en tu terminal.

### Instalación de Terraform

1. **Descargar Terraform:**

  Ve al sitio oficial de descargas de Terraform: [Terraform Downloads](https://www.terraform.io/downloads.html)

2. **Instalar Terraform en macOS:**

  ```sh
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```

  **Instalar Terraform en Linux:**

  ```sh
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform
  ```

  **Verificar la instalación:**
  ```sh
  terraform -v
  ```

### Configuración de las Credenciales de AWS

  Configura tus credenciales de AWS exportando las variables de entorno en tu terminal:

  ```sh
  export AWS_ACCESS_KEY_ID="your_access_key_id"
  export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
  export AWS_DEFAULT_REGION="us-east-1"
   ```

### Configuración del Backend de S3**

  Edita el archivo backend.tf para incluir tu bucket de S3 y la clave para el estado de Terraform:

  ```hcl
  terraform {
    backend "s3" {
      bucket = "your-bucket-name"
      key    = "path/to/your/key"
      region = "us-east-1"
    }
  }
  ```

### Inicialización del Proyecto

1. Inicializar Terraform: Esto descargará los plugins necesarios y configurará el backend.
   
  `terraform init`
2. Validar la Configuración: Asegúrate de que la configuración sea válida.
   
  `terraform validate`
3. Planificar la Infraestructura: Genera un plan de ejecución para revisar los cambios que se van a aplicar.
   
  `terraform plan`
4. Aplicar los Cambios: Aplica los cambios planificados para configurar la infraestructura.
   
  `terraform apply`

### Archivos de Configuración

  - kms.tf: Configuración de la clave KMS para cifrado
  - rds.tf: Configuración del RDS Aurora Serverless
  - ecs.tf: Configuración del ECS Cluster y servicios
  - alb.tf: Configuración del Application Load Balancer
  - certificate_manager.tf: Configuración de ACM y certificados
  - route53.tf: Configuración de Route53
  - secrets_manager.tf: Configuración de Secrets Manager
  - eventbridge.tf: Configuración de EventBridge para tareas programadas

### Notas

  • Asegúrate de reemplazar las credenciales y nombres de recursos con los valores apropiados para tu entorno
	• Puedes modificar los archivos .tf según tus necesidades específicas

### Limpieza de Recursos

Para eliminar todos los recursos creados por Terraform:
   
  `terraform destroy`

## Instalación de Checkov

1. Usando `pip`: `pip install checkov` o usando `brew`: `brew install checkov`

2. Verifica la instalación: `checkov --version`

3. Escanea el código Terraform para detectar vulnerabilidades:
  `checkov -d .`