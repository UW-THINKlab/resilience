# **AWS Infrastructure Information**

## **Info**

  Infrastructure has been split into two separate stacks, with different considerations and ownership for each:

### **`account` - Account-level configurations accessible by account owners and admistrators**
  * Everything in here is the foundation needed for everything else to work.
  * This is intended to be run extremely rarely by a user with elevated permissions.
  * It configures the S3 bucket that stores the terraform state, as well as the `deploy` IAM role that is assumed to deploy everything in `infrastructure`
  * New resources should only be added here if they would be needed to set up a brand new account.

### **`infrastructure` - AWS resources and configuration to run the Support Sphere project**

  * This is where all the "real" resources needed to run the Support Sphere cloud server configurations -- server setup, IAM roles to run operational scripts, 
    * Every resource created here will be named starting with the "resource prefix", a combination of the project name (`supportsphere`) and the neighborhood for which this infrastructure is created. An example resource prefix is `supportsphere-laurelhurst`.
    * Every resource here will also be tagged with the project name and neighborhood.
* This is probably where you want to add new resources.

## **Create and update account-level infrastructure**

### **Initialize the account-setup infrastructure on your machine**
From the `tofu init` docs
> This is the first command that should be run for any new or existing
  OpenTofu configuration per machine. This sets up all the local data
  necessary to run OpenTofu that is typically not committed to version
  control.
  ```console
  pixi run cloud-account-init
  ```

### **View differences between live and local changes**
  ```console
  pixi run cloud-account-plan
  ```

### **Deploy configurations**
  ```console
  pixi run cloud-account-deploy
  ```

## **AWS user administration**

### **Create users that can interact with ops scripts and deploy resources in `infrastructure`**
```console
pixi run cloud-account-user-controls add -u <name>
```

  * This command creates a new IAM User `<name>-assumer`, attaches them to the `ssec-eng` user group, creates access keys for the user to access the CLI, and prints out commands for someone to configure their AWS CLI with credentials for the new user.
  * This should be run by an account owner or admin on behalf of an engineer who will work to deploy & maintain this infrastructure.
  * The account owner/admin will run this command, and send the output to the engineer.

### **Revoke access to a user**
```console
pixi run cloud-account-user-controls delete -u <name>
```

### **Rotate a user's access keys**

Useful if existing keys have leaked but you don't want to outright delete the associate IAM user
```console
pixi run cloud-account-user-controls rotate -u <name>
```

### **List all existing access users in the `ssec-eng` group and their associated access keys**
```console
pixi run cloud-account-user-controls list
```