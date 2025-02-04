# eSeMeshA: Environment Setup

This folder contains scripts and instructions for setting up the environment for running the experiments.

## Experimentation Protocol

Considering a fresh Ubuntu install with image `ubuntu:24.04`, connect to the machine (_e.g._ using SSH or `lxc shell <VM id>`) and run the following procedure:

1. Create a logs folder:
    ```bash
    mkdir -p /mnt/logs/client
    ```

2. Set the environment variables that describe the current environment setup, _e.g._:
    ```bash
    export SE_LABEL_cni=calico
    export SE_LABEL_service_mesh=none
    export SE_LABEL_optimization=disabled
    ```

3. (Optional if _Baseline_) Run eSeMeshA in another shell terminal:
    ```bash
    mesh-fastpath
    ```

4. Run the workload
    - `ping-echo`
        ```bash
        export SE_INSTANCE=ping-echo
        #sed -i 's/#istio-injection: enabled/istio-injection: enabled/' eztunnel/workloads/ping-echo/manifest.yml
        kubectl apply -f eztunnel/workloads/ping-echo/manifest.yml
        statexec -f "statexec_metrics_${SE_INSTANCE}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}_$(date -u -Iseconds).prom" -dac 2 -- kubectl wait --for=condition=completed --timeout=30m -n workload-ping-echo job.batch/ping
        kubectl delete -f eztunnel/workloads/ping-echo/manifest.yml
        ```

    - `file-transfer`
        ```bash
        export SE_INSTANCE=file-transfer
        #sed -i 's/#istio-injection: enabled/istio-injection: enabled/' eztunnel/workloads/file-transfer/manifest.yml
        kubectl apply -f eztunnel/workloads/file-transfer/manifest.yml
        statexec -f "statexec_metrics_${SE_INSTANCE}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}_$(date -u -Iseconds).prom" -dac 2 -- kubectl wait --for=condition=completed --timeout=30m -n workload-file-transfer job.batch/client
        kubectl logs -n workload-file-transfer job.batch/client > /mnt/logs/client/log.txt
        kubectl delete -f eztunnel/workloads/file-transfer/manifest.yml
        ```

    - `redis`
        ```bash
        export SE_INSTANCE=redis
        #sed -i 's/#istio-injection: enabled/istio-injection: enabled/' eztunnel/workloads/redis/manifest.yml
        kubectl apply -f eztunnel/workloads/redis/manifest.yml
        statexec -f "statexec_metrics_${SE_INSTANCE}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}_$(date -u -Iseconds).prom" -dac 2 -- kubectl wait --for=condition=completed --timeout=30m -n workload-redis job.batch/memtier
        kubectl logs -n workload-redis job.batch/memtier > /mnt/logs/memtier/log.txt
        kubectl delete -f eztunnel/workloads/redis/manifest.yml
        ```

5. Collect the logs:
    ```bash
    mv statexec_metrics* /mnt/logs/
    zip -r /mnt/logs_${SE_LABEL_cni}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}.zip /mnt/logs
    ```
    Exit the machine and copy the logs to the host machine:
    ```bash
    lxc file pull <VM id>/mnt/logs_${SE_LABEL_cni}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}.zip .
    ```

6. Teardown the VM and repeat the process for the next environment setup

