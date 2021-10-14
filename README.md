# infrastructure
Terraform configuration to automate generation, management and destruction of cloud Infrastructure

Steps to start managing Infra:

1)install terraform on your system<br>
2)Configure aws profiles on  aws cli with the following command [aws configure --profile profilename]<br>
3) Create .tfvars file to provide values for the variables used in variables.tf<br>
4) Configure the profile aws_profile var for with the profilename used above<br>
5) cd into the infrastructure repo directory and run following commands<br>
6) terraform init<br>
7) terraform fmt<br>
8) terraform plan -var-file="filename.tfvars"<br>
9) terraform apply -var-file="filename.tfvars"<br>


<h2>Warnings:<h2>
<h3>Do not commit terraform.tfstate file <h3>
<h3>Do not commit *.tfvars file <h3>


