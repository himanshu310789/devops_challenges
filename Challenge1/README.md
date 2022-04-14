### Challenge 1

A 3-tier environment is a common setup. Use a tool of your choosing/familiarity create these resources. Please remember we will not be judged on the outcome but more focusing on the approach, style and reproducibility.

### Pre-requisites: 
1. Terraform CLI need to be installed to run the code

### Commands:
```
terraform login terraform-demo-project.com
terraform init
terraform plan
terraform apply
```

### Solution:

AWS Three Tier Architecture along with Terraform code to deploy all required services.
1. VPC Creation
2. Subnet Creation for ALB, App Servers and DB servers
3. Internet Gateway
4. Nat Gateway
5. Route Table for both IGW & NAT
6. Security Groups for ALB, App Servers and DB servers
7. Launch Template for App Servers
8. AutoScaling Group to scale ec2 instances and listen on ALB
9. Application Load Balancer Creation
10. Listeners and TargetGroups for HTTP/HTTPS port
11. Multi Zone RDS Creation

Note: Two EC2 Instances in different AZ will be launched through Launch Template once code run successfully.
