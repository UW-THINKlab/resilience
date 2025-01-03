# Migration

This doc deals with various migrations that one may need to do when productionalizing this software.

## Repository Migrations

When changing where in GitHub this package is located, the following locations in the code also need to be updated:

* [pixi.toml](https://github.com/UW-THINKlab/resilience/blob/main/pixi.toml#L212-L213)
* GitHub Actions configurations
 * [web preview main branch](https://github.com/UW-THINKlab/resilience/blob/main/.github/workflows/web-main.yaml#L18)
 * [web preview for PRs](https://github.com/UW-THINKlab/resilience/blob/main/.github/workflows/webpreview.yaml#L10)
* deployment configurations (if changing GitHub organization ONLY)
 * Run the workflow for publishing new repository images, found in [`.github/workflows/images.yaml`](https://github.com/UW-THINKlab/resilience/blob/main/.github/workflows/images.yaml)
 * all instances of `ghcr.io/<organization name>/...` and the associated tags, based on the previously-ran workflow
   * values.dev.yaml ([example](https://github.com/UW-THINKlab/resilience/blob/74480c2c24eefd3f51e7687cdd94e7053b312d4c/deployment/values.dev.yaml#L23-L25))
   * values.cloud.yaml  ([example](https://github.com/UW-THINKlab/resilience/blob/main/deployment/values.cloud.yaml#L22-L24))
       * note: need to decrypt this file to edit it ([documentation](https://resilience.readthedocs.io/en/latest/deployment/3_cloud_deployment/#editing-deploymentvaluescloudyaml))
* mkdocs.yml
  * [change 1](https://github.com/UW-THINKlab/resilience/blob/e1e0972c9ab0f7a9b889f3c81e2c259441af0437/mkdocs.yml#L5-L6)
  * [change 2](https://github.com/UW-THINKlab/resilience/blob/e1e0972c9ab0f7a9b889f3c81e2c259441af0437/mkdocs.yml#L47-L50)


## Database URL migration

When changing the URL location of the deployment database (at https://laurelhurst.supportsphere.nikiofti.me as of January 2025), the following changes need to be made.

* Assuming the AWS backend will still be in place, the ACM certificate will need to be reissued
 * Change the domain name [here](https://github.com/UW-THINKlab/resilience/blob/74480c2c24eefd3f51e7687cdd94e7053b312d4c/deployment/cloud/aws/infrastructure/modules/server/main.tf#L252)
 * Update the DNS record where your new domain is located following this documentation: https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html 
   * NOTE: we have run into problems trying to do this with an Azure-hosted DNS provider
* Update deployment/values.cloud.yaml in the following places
    * note: need to decrypt this file to edit it ([documentation](https://resilience.readthedocs.io/en/latest/deployment/3_cloud_deployment/#editing-deploymentvaluescloudyaml))
    * [studio.environment.SUPABASE_PUBLIC_URL](https://github.com/UW-THINKlab/resilience/blob/74480c2c24eefd3f51e7687cdd94e7053b312d4c/deployment/values.cloud.yaml#L46)
    * [auth.environment.API_EXTERNAL_URL and GOTRUE_SITE_URL](https://github.com/UW-THINKlab/resilience/blob/74480c2c24eefd3f51e7687cdd94e7053b312d4c/deployment/values.cloud.yaml#L60-L61)


## AWS Account Migration

These steps are as-yet untested. Niki Burggraf (nikib@uw.edu) is more than happy to help with any issues that may crop up along the way when these are run.

### Starting Configuration

Make sure you have admin access to the new AWS account as well as the previous one.

Also, make sure you have the backup PGP key available, since we'll be deleting the old account's KMS keys and recreating them later in the new account. The PGP key file can be retrieved from Niki Burggraf (nikib@uw.edu), and can be imported in order to be used with the following command:

```
gpg --import <key file location>
```

### Steps

#### 1) Destroy old infrastructure

With credentials from the old AWS account, run

```
pixi run cloud-destroy
```

#### 2) Destroy old account infrastructure

With credentials from the old AWS account, run 

```
pixi run cloud-account-destroy
```

#### ALTERNATIVE TO STEPS 1 AND 2 if you want to keep the old infrastructure around

Change the name of the S3 OpenTofu state bucket in 3 places 

In order to destroy the old infrastructure, you'll need to keep the existing information somewhere, maybe in its own branch, so that OpenTofu knows what infrastructure to delete when you get around to that step later

1. Cloud account setup script: https://github.com/UW-THINKlab/resilience/blob/e1e0972c9ab0f7a9b889f3c81e2c259441af0437/scripts/cloud-account-setup.py#L18
2. Cloud account infrastructure: https://github.com/UW-THINKlab/resilience/blob/e1e0972c9ab0f7a9b889f3c81e2c259441af0437/deployment/cloud/aws/account/main.tf#L10
3. Cloud infrastructure: https://github.com/UW-THINKlab/resilience/blob/e1e0972c9ab0f7a9b889f3c81e2c259441af0437/deployment/cloud/aws/infrastructure/main.tf#L10 

#### 3) Update all mentions of the previous account ID
These can be found through a code search here: https://github.com/search?q=repo%3AUW-THINKlab%2Fresilience%20871683513797&type=code
#### 5) Rebuild account infrastructure

With credentials from the new AWS account, run

```
pixi run cloud-account-init
pixi run cloud-account-deploy
```

#### 6) Rebuild infrastructure

With credentials from the new AWS account, run

```
pixi run cloud-init
pixi run cloud-deploy
```

#### 7) Validate ACM certificate

Follow this documentation: https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html 

If the database url is still laurelhurst.supportsphere.nikiofti.me, contact Niki Burggraf (nikib@uw.edu) for assistance, since she own and administers that domain.

#### 8) Update SOPS

In [the .sops.yaml file](https://github.com/UW-THINKlab/resilience/blob/main/.sops.yaml), edit the KMS keys to be the ones that have been newly created.

Run the following command to edit the deployment/values.cloud.yaml file, and verify that the new KMS keys are located [at the bottom of the file](https://github.com/UW-THINKlab/resilience/blob/main/deployment/values.cloud.yaml#L188-L196) after saving

```
pixi run edit-cloud-values
```