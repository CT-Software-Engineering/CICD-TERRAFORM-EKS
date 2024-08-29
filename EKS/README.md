# CICD-TERRAFORM-EKS
This Script creates an EKS Cluster with all the necessary permissions for access.
###################################################################################################################################################
Create OIDC federal access to use instead of Access Keys.
Key Differences
Scope: Access keys are specific to AWS and are used for programmatic access, while OIDC is a broader authentication protocol used across various platforms and services.
Functionality: Access keys provide direct access to AWS APIs, whereas OIDC provides a standardized way to authenticate users and obtain tokens for accessing resources.
Security: OIDC offers more secure and flexible authentication mechanisms, reducing the need to manage long-lived credentials like access keys.
###################################################################################################################################################3
To Configure OIDC
Step 1: Create an OIDC Identity Provider in AWS
You need to create an OIDC identity provider for GitHub and Jenkins in AWS IAM.

For GitHub Actions:
Open the IAM Console:

Sign in to the AWS Management Console and navigate to the IAM service.
Create an OIDC Provider:

In the navigation pane, click on Identity providers.
Click Add provider.
Set the following parameters:
Provider Type: Choose OpenID Connect.
Provider URL: Enter https://token.actions.githubusercontent.com.
Audience: Enter sts.amazonaws.com.
Verify the OIDC Provider:

AWS will verify the OIDC provider's URL and import the corresponding certificate.
For Jenkins:
Create an OIDC Provider for Jenkins:
Repeat the steps above but use the Jenkins OIDC endpoint URL instead of GitHub's.
If you're using a custom OIDC solution for Jenkins, enter the corresponding URL.
Step 2: Create an IAM Role for GitHub Actions and Jenkins
For GitHub Actions:
Create a Role in IAM:

Go to Roles in the IAM console and click Create role.
Choose Web Identity as the trusted entity type.
Select the OIDC provider you created for GitHub from the dropdown list.
In the Audience field, enter sts.amazonaws.com.
Click Next: Permissions.
Attach Required Permissions:

Attach the necessary permissions that your GitHub Actions workflow needs (e.g., AmazonS3FullAccess, AWSLambdaFullAccess).
Click Next: Tags, then Next: Review.
Name the Role and Create It:

Name the role something like GitHubActionsRole.
Click Create role.
For Jenkins:
Repeat the Above Steps:
Create another role following the same process but using the OIDC provider for Jenkins.
Assign appropriate permissions for the Jenkins jobs (e.g., EC2, EKS, S3 access).
Name the role something like JenkinsRole.
Step 3: Configure GitHub Actions to Assume the Role
Update Your GitHub Workflow:

In your GitHub Actions workflow, you need to use the aws-actions/configure-aws-credentials action to configure AWS credentials using OIDC.
yaml
Copy code
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::<AWS_ACCOUNT_ID>:role/GitHubActionsRole
          aws-region: us-west-2

      - name: Deploy using AWS CLI
        run: aws s3 cp ./my-file.txt s3://my-bucket/my-file.txt
Set Up GitHub Repository Secrets:

Store any sensitive data such as AWS_ACCOUNT_ID in your GitHub repository secrets.
Step 4: Configure Jenkins to Assume the Role
Install the Jenkins AWS Credentials Plugin:

Ensure the Jenkins instance has the AWS Credentials Plugin installed.
Configure AWS Credentials in Jenkins:

Navigate to Manage Jenkins > Manage Credentials.
Add a new AWS Credentials.
Configure it to use IAM roles based on the OIDC provider you set up.
Update Jenkins Pipeline:

Modify your Jenkins pipeline script to assume the IAM role when executing AWS commands.
groovy
Copy code
withAWS(role: 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/JenkinsRole', region: 'us-west-2') {
    sh 'aws s3 cp ./my-file.txt s3://my-bucket/my-file.txt'
}
Step 5: Verify and Test the Setup
Test GitHub Actions Workflow:

Push changes to your GitHub repository and ensure the workflow runs successfully and assumes the AWS role.
Test Jenkins Pipeline:

Run the Jenkins job to ensure that it correctly assumes the IAM role and interacts with AWS resources as expected.
Step 6: Implement Security Best Practices
Restrict Role Usage:
Use condition keys like aws:PrincipalTag or aws:SourceArn to restrict the IAM roles to specific repositories or jobs.
Rotate Access Tokens Regularly:
Ensure that access tokens and secrets are rotated regularly to maintain security.