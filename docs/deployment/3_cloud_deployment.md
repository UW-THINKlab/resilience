# Running in the cloud

## Where's the cloud stuff?

It's in `./deployment/cloud` and we're using [OpenTofu](https://opentofu.org/)

## Overview of AWS account setup, including information on getting credentials

Please see our information [here](./deployment/cloud/aws/README.md)

## Editing deployment/values.cloud.yaml

(Optional) To open the file with VSCode, run the following first

```
export EDITOR="code --wait"
```

Then run the following. Save and close the file when you're done editing for all of your new values to be re-encrypted.

```
pixi run edit-cloud-values
```

If you run into an issue like `gpg: decryption failed: Inappropriate ioctl for device`, run the following command and retry

```
export GPG_TTY=$(tty)
```

## Deploying infrastructure changes

The following commands will allow you to do what you gotta do to update and deploy the infrastructure

### Initialize the infrastructure on your machine

From the `tofu init` docs

> This is the first command that should be run for any new or existing
  OpenTofu configuration per machine. This sets up all the local data
  necessary to run OpenTofu that is typically not committed to version
  control.

```
pixi run cloud-init
```

### Preview the changes to your infrastructure

```
pixi run cloud-plan
```

### Deploy your infrastructure changes

```
pixi run cloud-deploy
```

### Destroy all cloud infra (WARNING: ask if you think you gotta do this)

```
pixi run cloud-destroy
```

## Run the development server

This will start up the development server and populate it with sample data.

```
pixi run cloud-server-run
```

## Stop the development server

The server will stop daily at 01:00 UTC (6PM PDT/5PM PST), but if you wanna be a good citizen and stop it when you're done, run the following

```
pixi run cloud-server-stop
```

## Access the development server when it's running

This command uses [AWS's Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) to access the development server without needing to distribute ssh keys. Assuming you have access to the IAM roles needed for everything else related to the cloud here, this command should just work!

```
pixi run cloud-server-access
```

## Backup

Currently, backups run on system:
```
pixi run cloud-server-access
sudo su
cd /opt/resilience/
git pull

pixi run -e backend db-backup
```

These commands:
1. Access the cloud server shell
2. Become root. NOTE: This is needed because the git repo in /opt/resilience is owned by root
3. Change dir to the resilience project, where the pixi.toml script is
4. Pull from the git origin to make sure everything is up to date
5. Run the backup script, which will create a backup file in the same directory: `backup-Laurelhurst-2026-04-08-1801.sql.gz`

## Restore

Given a backup file, restore a full working system:

```
pixi run cloud-server-access
sudo su
cd /opt/resilience/
git pull

pixi run -e backend db-restore backup-Laurelhurst-2026-04-08-1801.sql.gz
```

To restore to a fresh system, after reinstalling the kupernetes cluster:
```
pixi run cloud-server-access
sudo su
cd /opt/resilience/
git pull

pixi run -e backend setup-infra-cloud
pixi run -e backend db-restore backup-Laurelhurst-2026-04-08-1801.sql.gz
```

Deploying a full cloud system takes a lot of time and changes the DNS address, so there are a lot of situations to rebuild the system without a full redeploy.