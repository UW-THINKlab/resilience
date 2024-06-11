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

## Contributing

You can contribute to this project by creating issues or forking this repository and opening a pull request.

Please review our [Code of Conduct](./CODE_OF_CONDUCT.md) before contributing.

## License

[BSD 3-Clause License](./LICENSE)
