# eSeMeshA: Workloads & Logs

This folder contains various workloads and their respective logs generated during the experiments.

## Workloads

The workloads are composed of Kubernetes manifests that define the applications and services used in the experiments.

- [ping-echo](./ping-echo): A client which sends packets with 24-bytes over TCP to a server, which echoes them back. Both the client and server are written in Python.
- [file-transfer](./file-transfer): A server transferring a large synthetic file (1,000 MiB) to a client over TCP using [ncat](https://nmap.org/ncat/).
- [redis](./redis): A redis instance and a memtier client generating a synthetic workload.

## Logs

Network-related metrics are collected by the client process itself, while resource usage-related metrics are monitored by [statexec](https://github.com/blackswifthosting/statexec).

The logs are stored in zip files, which can be extracted and analyzed using the Jupyter Notebooks in the [Analysis & Graphs](../analysis) folder.
