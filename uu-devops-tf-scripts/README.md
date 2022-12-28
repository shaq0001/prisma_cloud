# uu-devops-tf-scripts


To add this as a submodule (sub directory) of your repo, navigate to the folder in your repo where you want to have the 'tools' folder and execute:
 
 git submodule add  git@github.com:unite-us/uu-devops-tf-scripts.git tools
 
 I add symbolic links so that the scripts have a link in the same folder as the terraform so no PATH changes need to be made.
 for example the tools folder is a subfolder of the folder your terraform is in, so you would execute:
 
 ln -s tools/plan.sh
 
 ln -s tools/apply.sh
 
 ln -s tools/init.sh
 
 ln -s tools/destroy.sh
 
 
 An example of the folder structure for separating out the account specific variable values can be seen in the repo https://github.com/unite-us/uu-palo-alto-panorama; An example that has more then just the 1 account can be found here: https://github.com/unite-us/uu-devops-aws-account-management-tf
 
 All account/environment variables should be in the variables.tfvars in the folder accounts/*account number*.
 The s3 bucket definition for the s3 backend config for the terrraform state file is also in this folder in a file called 'backend' 
 
 The scripts use the environment variable TF_DATA_DIR to keep the .terraform (working folders) folders seperated by account.
 
 To set up your AWS credentials either set the individual AWS environment variables or set up AWS_PROFILE to point to a preconfigured AWS profile.
 
 workflow
 ./init.sh
 ./plan.sh
 ./apply.sh
