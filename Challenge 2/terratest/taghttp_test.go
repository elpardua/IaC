package test

import (
  "testing"
  "time"
  "github.com/gruntwork-io/terratest/modules/aws"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/gruntwork-io/terratest/modules/http-helper"
  "github.com/stretchr/testify/assert"
)

//Lets' create the function and define some variables.
func TestTags(t *testing.T) {
  awsRegion := "us-east-2"
  tagName := "Flugel-test"
  tagOwner := "InfraTeam-test"

  terraformOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    TerraformDir: "../",

        //Now i must map the tags.
        Vars: map[string]interface{}{
          "tag_name": tagName,
          "tag_owner": tagOwner,
        },

        //Then set the region to make the deploy in.
        EnvVars: map[string]string{
        "AWS_DEFAULT_REGION": awsRegion,
        },
     },
    )

  //After all the testing, the infra must be destroyed.
  defer terraform.Destroy(t, terraformOpts)

  //Now, let's run the deploy with all the parameters set.
  terraform.InitAndApply(t, terraformOpts)

  //I get the instance and bucket id's, and make first verifications.
  instanceID1 := terraform.Output(t, terraformOpts, "instance_name_web1")
  instanceTags1 := aws.GetTagsForEc2Instance(t, awsRegion, instanceID1)
  testTag1, containsTag := instanceTags1["Name"]
  assert.True(t, containsTag, "True")
  assert.Equal(t, tagName, testTag1)
  testTag2, containsTag := instanceTags1["Owner"]
  assert.True(t, containsTag, "True")
  assert.Equal(t, tagOwner, testTag2)

  instanceID2 := terraform.Output(t, terraformOpts, "instance_name_web2")
  instanceTags2 := aws.GetTagsForEc2Instance(t, awsRegion, instanceID2)
  testTag3, containsTag := instanceTags2["Name"]
  assert.True(t, containsTag, "True")
  assert.Equal(t, tagName, testTag3)
  testTag4, containsTag := instanceTags2["Owner"]
  assert.True(t, containsTag, "True")
  assert.Equal(t, tagOwner, testTag4)

  //It would be easier to simply parse plain text, but as i put myself into this let's ride with it.

  lburl := "http://" + terraform.Output(t, terraformOpts, "load_balancer_url") + "/index.html"
  maxRetries := 3
  timeBetweenRetries := 5 * time.Second

  http_helper.HttpGetWithRetryWithCustomValidation(t, lburl, nil, maxRetries, timeBetweenRetries, validate)

  // There's no module with "get X bucket tags", so i get the bucket id from TF, and separately i seek the bucket that contains
  // tags "Name" and "Owner" with the desired content, and make sure the id returned matches the previously deployed bucket. 
  bucketID := terraform.Output(t, terraformOpts, "bucket_id")
  bucketwithTagN := aws.FindS3BucketWithTag (t, awsRegion, "Name", tagName)
  bucketwithTagO := aws.FindS3BucketWithTag (t, awsRegion, "Owner", tagOwner)
  assert.Equal(t, bucketwithTagN, bucketID)
  assert.Equal(t, bucketwithTagO, bucketID)

}

//This function validates the file is reachable through the ALB
func validate(status int, _ string) bool {
	return status == 200
}
