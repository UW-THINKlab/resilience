# post-disaster-comms

[![ssec](https://img.shields.io/badge/SSEC-Project-purple?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAQAAABedl5ZAAAACXBIWXMAAAHKAAABygHMtnUxAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAMNJREFUGBltwcEqwwEcAOAfc1F2sNsOTqSlNUopSv5jW1YzHHYY/6YtLa1Jy4mbl3Bz8QIeyKM4fMaUxr4vZnEpjWnmLMSYCysxTcddhF25+EvJia5hhCudULAePyRalvUteXIfBgYxJufRuaKuprKsbDjVUrUj40FNQ11PTzEmrCmrevPhRcVQai8m1PRVvOPZgX2JttWYsGhD3atbHWcyUqX4oqDtJkJiJHUYv+R1JbaNHJmP/+Q1HLu2GbNoSm3Ft0+Y1YMdPSTSwQAAAABJRU5ErkJggg==&style=plastic)](https://ise.washington.edu/news/article/2024-01-14/building-community-resilience-2-million-nsf-grant-will-transform-disaster)
[![BSD License](https://badgen.net/badge/license/BSD-3-Clause/blue)](LICENSE)

This repository is a collection of resources for post-disaster communications. It is a work in progress and will be updated as the project progresses.

## Frontend Technology Stack

Flutter is an open-source UI software development kit created by Google.

This will be used for the mobile application development.

See [Official Documentation](https://flutter.dev/docs)

## Backend Technology Stack

Supabase is an open source Firebase alternative. It is a service that provides a Postgres database with a RESTful API and real-time capabilities. It is used as the backend for the project.

For this project, we will be utilizing the community supabase kubernetes helm chart.
The helm chart can be found in [supabase-community/supabase-kubernetes](https://github.com/supabase-community/supabase-kubernetes).

Deploying supabase via Kubernetes allows for a cloud agnostic deployment as long as a Kubernetes cluster is available.

See [Official Documentation](https://supabase.com/docs)

## Running locally

To run this app locally, follow these steps:

0. Install Pixi: https://github.com/prefix-dev/pixi?tab=readme-ov-file#installation
1. In the package's directory, run the following to install both `frontend` and `backend` tools

   ```console
   # Install frontend tools
   pixi run -e frontend install-tools
   # install backend tools
   pixi run -e backend install-tools
   ```

### Backend

1. Run the Docker daemon

2. Set environment variables with your Docker username and password

   ```console
   export DOCKER_USERNAME=<your docker username>
   export DOCKER_PASSWORD=<your docker password>
   ```

3. Set up the infrastructure. You should have a Supabase instance running at http://localhost

   ```console
   pixi run -e backend setup-infra
   ```

4. Optional: If you want to add sample entries in your local Supabase Instance. 
   Run the following command in a new terminal session.
   
   ```console
   pixi run populate-sample-entries
   ```
   
   At this point your backend is now ready to go! Now off to frontend

### Frontend

1. Install [Android Studio](https://developer.android.com/studio)
2. Run Android Studio, which will help you install the Android toolchain. Be sure to include all required components
   1. Android SDK Platform
   1. Android SDK Command-line tools
   1. Android SDK Build-Tools
   1. Android SDK Platform-Tools
   1. Android Emulator

3. Accept the Android licenses (or check that you have already done so) and get frontend dependencies
   by running the command below. *There may be an issue indicated with XCode -- that is okay and can be ignored*
   
   ```console
   pixi run -e frontend setup-infra
   ```

4. Run Flutter. This will open the Android app in a new Chrome window
   
   ```console
   pixi run -e frontend flutter-run
   ```

   At this point your frontend is now ready to go! You are all set.

## Contributing

You can contribute to this project by creating issues or forking this repository and opening a pull request.

Please review our [Code of Conduct](./CODE_OF_CONDUCT.md) before contributing.

## License

[BSD 3-Clause License](./LICENSE)
