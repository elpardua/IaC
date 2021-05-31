# IaC Challenge - Pablo Arduino

This repo contains all the code necessary to complain with the following.

**1. Create Terraform code to create an S3 bucket and an EC2 instance. Both resources must be tagged with Name=Flugel, Owner=InfraTeam.**  
**2. Using Terratest, create the test automation for the Terraform code, validating that both resources are tagged properly.**  
**3. Setup Github Actions to run a pipeline to validate this code.**  
**4. Publish your code in a public GitHub repository, and share a Pull Request with your code. Do not merge into master until the PR is approved.**
  
In order to run the tests, you must meet the following requirements:

Have an active AWS account. Anything with free tier access will do.  
aws-cli with all your credentials configured, terraform, terratest and golang installed too.  
If you want to test the configured github actions, you'll also need a Github account, in order to make a fork, modify it, and make a pull request against this repo. Besides the terraform code validation, there's also a job which automatically creates a PR against main, so it could be just merged with a human authorization via review.  

## How to Test

### 1- From your terminal, clone this repo locally.

```
git clone https://github.com/elpardua/IaC.git
cd IaC

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


