package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/aws"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

//Lets' create the function and define some variables.
func TestTags(t *testing.T) {
  awsRegion := "us-east-2"
  tagName := "Flugel"
  tagOwner:= "InfraTeam"

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
  instanceID := terraform.Output(t, terraformOpts, "instance_name")
  instanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceID)
  testTag1, containsTag := instanceTags["Name"]
  assert.True(t, containsTag, "True")
  assert.Equal(t, tagName, testTag1)
  testTag2, containsTag := instanceTags["Owner"]
  assert.True(t, containsTag, "True")
  assert.Equal(t, tagOwner, testTag2)

  // There's no module with "get X bucket tags, so i get the bucket id from TF, and separately i seek the bucket that contains
  // tags "Name" and "Owner" with the desired content, and make sure the id returned matches the previously deployed bucket. 
  bucketID := terraform.Output(t, terraformOpts, "bucket_id")
  bucketwithTagN := aws.FindS3BucketWithTag (t, awsRegion, "Name", tagName)
  bucketwithTagO := aws.FindS3BucketWithTag (t, awsRegion, "Owner", tagOwner)
  assert.Equal(t, bucketwithTagN, bucketID)
  assert.Equal(t, bucketwithTagO, bucketID)

}
 
