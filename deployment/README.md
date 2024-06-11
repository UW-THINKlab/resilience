# Deployment Configurations

This directory contains the configurations for deploying the application to a Kubernetes cluster.

## Prerequisites

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)

## Development

To deploy the supabase backend to a local minikube cluster, run the following commands:

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

Coming soon.
