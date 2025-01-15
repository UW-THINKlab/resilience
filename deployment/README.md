# Deployment Configurations

This directory contains the configurations for deploying the application to a Kubernetes cluster.

## Prerequisites

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)
- Clone the GitHub [repo](https://github.com/UW-THINKlab/resilience/) using the following command:
```bash
git clone --recurse-submodules https://github.com/UW-THINKlab/resilience
```

## Development

To deploy the supabase backend to a local minikube cluster, run the following commands from within the `deployment` directory inside the cloned Github repo:

1. Start minikube cluster

    ```bash
    minikube start
    ```

2. Enable minikube ingress add-on

    ```bash
    minikube addons enable ingress
    ```

3. Deploy the application with helm

    ```bash
    helm install supabase -f values.dev.yaml ../vendors/supabase-kubernetes/charts/supabase
    ```

    *Note: Once the deployment is complete, you can run `kubectl get pods` and see the following:

    ```console
    NAME                                           READY   STATUS    RESTARTS   AGE
    supabase-supabase-analytics-749769b6c5-9fwrx   1/1     Running   0          30s
    supabase-supabase-auth-58c84557cf-57vv7        1/1     Running   0          30s
    supabase-supabase-db-5f485f8477-njfbv          1/1     Running   0          30s
    supabase-supabase-functions-85bf447d8f-lj2mk   1/1     Running   0          30s
    supabase-supabase-imgproxy-86d846cdc4-krplc    1/1     Running   0          30s
    supabase-supabase-kong-7f9f5d7c8c-tlcz2        1/1     Running   0          30s
    supabase-supabase-meta-7667c48649-dlsxm        1/1     Running   0          30s
    supabase-supabase-realtime-5bf9b784f6-4vxm7    1/1     Running   0          30s
    supabase-supabase-rest-7f5d6d786-6vc5w         1/1     Running   0          30s
    supabase-supabase-storage-5dfc87696c-hrmpw     1/1     Running   0          30s
    supabase-supabase-studio-7fb5c6954-g9qcx       1/1     Running   0          30s
    supabase-supabase-vector-57cfc87f9d-pk2vh      1/1     Running   0          30s
    ```

4. Tunnel the minikube ingress controller, see [docs](https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access)
    for more information. In simple terms, this will allow us to access the services running in the
    minikube cluster from our local machine at `127.0.0.1`, a.k.a `localhost`.

    **Note: This command will ask for password and block the terminal, so open a new terminal to run other commands.**

    ```bash
    minikube tunnel
    ```

5. Everything is set up, now you can access the Supabase Dashboard by going to [http://localhost](http://localhost).
    A login form will appear, use the following credentials as shown in the [values.dev.yaml](values.dev.yaml) file:

    ```yaml
    dashboard:
        username: supabase
        password: this_password_is_insecure_and_should_be_updated
    ```

## Production

There are some infrastructure tools that are needed to run supabase in the server.

1. Docker: Docker will be the underlying platform for running the container applications for the backend.
    To install docker in ubuntu, follow the instructions in the [official documentation](https://docs.docker.com/engine/install/ubuntu/).

    **Note: To allow docker to run as non-root user, do `sudo usermod -aG docker ubuntu`**

2. k3d: k3d is a lightweight wrapper to run k3s (A certified lightweight Kubernetes distribution) in docker. It is used to run the kubernetes cluster for the backend. To install k3d, follow the instructions in the [official documentation](https://k3d.io/v5.6.3/#installation).

3. kubectl: kubectl is the command line tool for interacting with the kubernetes cluster. To install kubectl, follow the instructions in the [official documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux).

4. Helm: Helm is the package manager for kubernetes. To install helm, follow the instructions in the [official documentation](https://helm.sh/docs/intro/install/).

5. Stern: Stern is a tool for tailing multiple pods on kubernetes. To install stern, follow the instructions in the [official documentation](https://github.com/stern/stern?tab=readme-ov-file#installation).

**Note: Deployment instructions for production will be available in the future.**
