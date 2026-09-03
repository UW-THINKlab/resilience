# Backend Components

## tl;dr

Setting up the backend:
1. Install `git` and clone repo:
    - `git clone https://github.com/UW-THINKlab/resilience`
    - `cd resilience`
2. [Install pixi](https://pixi.prefix.dev/latest/installation/):
    - `curl -fsSL https://pixi.sh/install.sh | sh`
3. Install backend tools:
    - `pixi run -e backend install-tools`
4. Install backend infrastructure:
    - `pixi run -e backend setup-infra`
5. Confirm supabase is running at http://localhost

Now, the choice is to load data, either the Laurelhurst test data or a backup.

To load Laurelhurst test data:

    pixi run -e backend setup-db-data-via-k8s-job

To load from a backup file named `backup-Laurelhurst-2026-02-17-1133.sql.gz`:

    pixi run -e backend db-restore backup-Laurelhurst-2026-02-17-1133.sql.gz

To create a backup from the current instance:

    pixi run -e backend db-backup

Which will create a backup file with the neighborhood name and timestamp: `backup-Laurelhurst-2026-02-17-1133.sql.gz`

Full backup in the cloud:

    pixi run cloud-server-access
    sudo su
    cd /opt/resilience/
    pixi run db-backup

Note: `/opt/resilience/` is created by `root` in the automated instance create process. It's a git repo, and should be managed as the creating user.


## supabase tl;dr
To checkout and run a dev supabase server, from scratch:
```
curl -fsSL https://pixi.sh/install.sh | sh
git clone https://github.com/UW-THINKlab/resilience
cd resilience

pixi run -e supabase load <backup>.sql.gz
```

To run the frontend:
```
pixi run -e supabase status | grep -e "API_URL" -e "PUBLISHABLE_KEY"
vi .env
--
SUPABASE_URL='<API_URL>'
SUPABASE_PUBLISHABLE_KEY='<PUBLISHABLE_KEY>'
---

pixi run -e frontend run
```

### 0. Prerequisites: Install pixi and clone project
To get started, clone the GitHub project:
```
curl -fsSL https://pixi.sh/install.sh | sh
git clone https://github.com/UW-THINKlab/resilience
cd resilience
```

### 1. Start supabase and load data
Given a backup file from the project, named by default `data.sql.gz`, a new development server
can be started and loaded directly from a pixi command.
```
pixi run -e supabase load

pixi run -e supabase load backup-Laurelhurst-2026-04-01-1338.sql.gz
```

In the first example, the system looks for a db dump with the name `data.sql.gz` in the same directory as the `pixi.toml`. This will get loaded by default.

The `load` subcommand also accepts a file name, as in the 2nd example.

Assuming a valid backup, this single command will start a supabase cluster (if one is not already running) and load the backup.

This would also be useful for integration testing that required a valid system with pre-configured test data.
```
pixi run -e supabase load test-suite-data.sql.gz
```

### 2. Get auth details from supabase
To do frontend development against the new development server, you need to net environment variables for the URL and supabase publishable key.

To get those values from the running instance:
```
pixi run -e supabase status | grep -e "API_URL" -e "PUBLISHABLE_KEY"
```

These values can be used to update an .env file or your IDE:
```
SUPABASE_URL='<API_URL>'
SUPABASE_PUBLISHABLE_KEY='<PUBLISHABLE_KEY>'
```

### 3. Update your .env and run
```
vi .env
```

Add the following env vars, substituting <API_URL> and <PUBLISHABLE_KEY> with the values from step 3.
```
SUPABASE_URL='<API_URL>'
SUPABASE_PUBLISHABLE_KEY='<PUBLISHABLE_KEY>'
```

Run the frontend:
```
pixi run -e frontend run
```

### 4. Create a backup
To create a backup that can be used in the db-load process:
```
pixi run -e supabase dump

pixi run -e supabase dump <a-backup-filename>.sql
```
Using default options, this will create a DB dump in file named `data.sql.gz`.

### 5. Load a backup
To load a running supabase system from a backup file (created with dump):
```
pixi run -e supabase load

pixi run -e supabase dump <a-backup-filename>.sql.gz
```
Using default options, this will load DB dump in file named `data.sql.gz` into the local supabase instance.

*NOTE*: The `supabase` cluster is run with persisted volumes and will recover from normal shutdowns and hiccups. The `load-supabase` command should only be used for new systems or for catastrophic DB failure. `pixi load-supabase` will **reset** the local database and load a fresh copy from the backup.


## Introduction

For the backend infrastructure, the storage and API interfaces,
we utilize Supabase, an open source Firebase alternative. It is made up of many services on top of a Postgres database.

![supabase architecture](https://supabase.com/docs/_next/image?url=%2Fdocs%2Fimg%2Fsupabase-architecture.svg&w=640&q=75&dpl=dpl_59dEA9dppFNxofYyfzjyLZjscsqB)

For deployment of Supabase, we utilized the community supabase kubernetes helm chart.
The helm chart can be found in [supabase-community/supabase-kubernetes](https://github.com/supabase-community/supabase-kubernetes).
This helm chart allows for a cloud agnostic deployment as long as a Kubernetes cluster is available.
This ensures that the cloud deployment is exactly the same as the local deployment.

See [Official Supabase Documentation](https://supabase.com/docs) for more information about using supabase.

## Pixi

We use a tool called [Pixi](https://pixi.sh/latest/) to manage virtual environments and run tasks.
You can find the various task and environment definitions within the [`pixi.toml`](https://github.com/UW-THINKlab/resilience/blob/main/pixi.toml) file within the root directory of the repository.

Currently all of the backend tasks are defined in the `backend` environment.
The individual tasks are defined in either `backend` and `db` features.
This allows for a fine grained definitions for the feature dependencies.

Note that all dependencies defined in the `pixi.toml` file are retrieved
from the [`conda-forge` channel](https://prefix.dev/channels/conda-forge) in the conda repository.

For anything not installed directly from the channel, you can install it manually with a task. For example,
you see checkout the [`install-k3d` task](https://github.com/UW-THINKlab/resilience/blob/155d99912fdc9bb4b1b1533894153fee51f72c30/pixi.toml#L131-L134)
in the `backend` feature.

For more detailed information, we recommend reading the [Pixi Documentation](https://pixi.sh/latest/).

## Docker Images

The images used for each of the services are as follows:

- supabase/postgres
- supabase/studio
- supabase/gotrue
- postgrest/postgrest
- supabase/realtime
- supabase/postgres-meta
- supabase/storage-api
- darthsim/imgproxy
- kong
- supabase/logflare
- timberio/vector
- supabase/edge-runtime
- minio/minio

We've made a copy of these images within the `UW-ThinkLab`'s
Github Container Registry. This is to ensure that the images are
available in the event that the original images are removed,
or if we need to make changes to the images.

The github actions workflow for building
and pushing the images can be found in
[`.github/workflows/images.yaml`](https://github.com/UW-THINKlab/resilience/blob/main/.github/workflows/images.yaml)
and the images can be found in the [Resilience Container Registry](https://github.com/orgs/UW-THINKlab/packages?repo_name=resilience).

## Helm Chart

A Helm chart is a collection of files that define and package resources for a Kubernetes cluster as an application.
As mentioned earlier, we utilize the community supabase kubernetes helm chart for deployment of Supabase.
Currently we've set up a git submodule to the helm chart repository in the `vendors` directory.
You can simple fetch this submodule by running the following task with pixi:

```console
pixi run -e backend fetch-supabase-chart
```

Once you've fetched the submodule, you should now be able to see the full `supabase-kubernetes` repository in the `vendors` directory.

### Helm Chart Values

The deployment values for the helm chart can be found in
the yaml files found in the `deployment` directory.

The values are separated into two files:

#### `values.dev.yaml`: This is the values file for the development environment.
You can use this file to deploy the backend services to a local kubernetes cluster.
It does contains unencrypted secrets and should not be used in production.

#### `values.cloud.yaml`: This is the values file for the production environment.
You can use this file to deploy the backend services to a production kubernetes cluster,
whether it be on the cloud or on-premises.
It contains encrypted secrets and can be used in production.


##### Editing values.cloud.yaml (Optional)

The `values.cloud.yaml` has been encrypted using a tool called [SOPS: Secrets OPerationS](https://github.com/getsops/sops).
This allows us to fully encrypt the secrets in the file and only decrypt them when we need to edit or use them.

To open the file with VSCode, run the following first

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

## **Running locally**

To run this app locally, follow these steps:

0. Install [Pixi](https://github.com/prefix-dev/pixi?tab=readme-ov-file#installation)
1. In the package's directory, run the following to install `backend` tools

    ```console
    # install backend tools
    pixi run -e backend install-tools
    ```
2. Run the Docker daemon
3. Set up the infrastructure. You should have a Supabase instance running at http://localhost
    ```console
    pixi run -e backend setup-infra
    ```
    After the setup, when prompted to log in, enter your Supabase project credentials (Username and Password) for successful authentication. The credentials can be found in `deployment/values.dev.yaml`.
4. Optional: If you want to add sample entries in your local Supabase Instance.
    Run the following command in a new terminal session.
    ```console
    pixi run -e backend setup-db-data-via-k8s-job
    ```

## Database diagram

Date generated: 11/25/2024

![database diagram](../assets/images/pdc_20241125.png)
