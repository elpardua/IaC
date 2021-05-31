# IaC Challenges - Pablo Arduino

This repo contains all the code necessary to complain with the following challenges.

## Challenge 1

**1. Create Terraform code to create an S3 bucket and an EC2 instance. Both resources must be tagged with Name=Flugel, Owner=InfraTeam.**  
**2. Using Terratest, create the test automation for the Terraform code, validating that both resources are tagged properly.**  
**3. Setup Github Actions to run a pipeline to validate this code.**  
**4. Publish your code in a public GitHub repository, and share a Pull Request with your code. Do not merge into master until the PR is approved.**
  
In order to run this test, you must meet the following requirements:

Have an active AWS account. Anything with free tier access will do.  
aws-cli with all your credentials configured, terraform, terratest and golang installed too.  
If you want to test the configured github actions, you'll also need a Github account, in order to make a fork, modify it, and make a pull request against this repo. Besides the terraform code validation, there's also a job which automatically creates a PR against main, so it could be just merged with a human authorization via review.  

## How to Test

### 1- From your terminal, clone this repo locally.

```
git clone https://github.com/elpardua/IaC.git
cd IaC/Challenge\ 1

export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-2"

terraform init
terraform plan
terraform apply

terraform destroy
```   
      
### 2- Go into terratest directory and run the tags test.

```
cd terratest
go mod tidy
go test tag_test.go
```

### 3/4- Github Actions Test

Go back to the IaC directory, and make a change to some of the .tf files from the dev branch doing a git checkout dev. Then send a PR to dev branch so it can be tested. You can do this from your console directly pushing against the repo, but first i have to set access for your user. Or you can forge this repo into your account and fire up a PR from there. If everything is ok, your code should pass the validations, and be automatically proposed to be merged against main.

## Challenge 2

**Merge any pending PR.**
**Create a new PR with code and updated documentation for the new requirement.**
**I want a cluster of 2 EC2 instances behind an ALB running Nginx, serving a static file. This static file must be generated at boot, using a Python script. Put the AWS instance tags in the file.**
**The cluster must be deployed in a new VPC. This VPC must have only one public subnet. Do not use default VPC**
**Update the tests to validate the infrastructure. The test must check that files are reachable in the ALB.**

In order to run this test, you must meet the following requirements:

Have an active AWS account. Anything with free tier access will do.
aws-cli with all your credentials configured, terraform, terratest and golang installed too.
If you want to test the configured github actions, you'll also need a Github account, in order to make a fork, modify it, and make a pull request against this repo. Besides the terraform code validation, there's also a job which automatically creates a PR against main, so it could be just merged with a human authorization via review.

## How to Test

### 1- From your terminal, clone this repo locally.

```
git clone https://github.com/elpardua/IaC.git
cd IaC/Challenge\ 2

export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-2"

#Make sure you have a private and public keys in this directory, just put your ones, and change vars.tf accordingly, or generate new ones to match the default ones with the command ssh-keygen -f flugel-key-pair -N "" 

terraform init
terraform plan -o terraform.out
terraform apply terraform.out

terraform destroy
```

### 2- Go to the terratest directory in order to run the tags, and static file availability through the ALB

```
cd terratest
go mod init github.com/elpardua/IaC
go mod tidy
go test tag_test.go
```

As in the previous challenge, all TF code is validated through github actions, and if everything's ok, a PR against main is created automatically.

