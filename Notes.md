# TerraForm - Automating public and private cloud

## Creating a basic Configuration 

### Automating the infrastructure deployments 

    - Provisioning Resources
    - Planning Updates 
    - Using Source Control 
    - Reusing Templates 

### Terraform components

- Terraform is an exectable compiled in GLang that means it doesnt require any additional drivers, plugins or registry entries required 

```
// Variables
variable "aws_access_key" {}
variable "aws_secret_key" {}

// Providers
provider "aws" {
    access_key = "access_key"
    secret_key = "secret_key"
    region = "us-east-1"
}

// Resources 
resource "aws_instance" "ex" {
    ami = "ami-c58c1dd3"
    instance_type = "t2.micro"
}

// Output 
output "aws_public_ip" {
    value = "${aws_instance.ex.public_dns}"
}
```

### Updating the Configuration 

Terraform maintains a state file to keep track of the state of the current deployment, It is a JSON (something which should not be modified-directly).

It has information about resource mappings and metadata, when deploying the state file will be locked.





## Understanding Terraform 
## Integrating multipke providers
## Using abstraction 

