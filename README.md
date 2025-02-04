# eSeMeshA 🐝

**eSeMeshA** is an **e**BPF-based **Se**rvice **Me**sh **A**cceleration framework designed to mitigate networking overheads in intra-node service mesh  communication. The method employs an in-kernel method to bypass costly data paths, while maintaining full support for modern service mesh architectures, like Istio Ambient Mesh, Cilium, and legacy sidecar-based approaches.

# Organization

This repository houses the scripts, code and guidance needed to replicate the experiments presented in our papers.

- [eSeMeshA Code](./code): Source code for building and running eBPF programs and userspace applications
- [Analysis & Graphs](./graphs): Jupyter Notebooks for data analysis and visualization
- [Workloads & Logs](./workloads): Various workloads and their respective logs generated during the experiments
- [Environment Setup](./setup): Scripts and instructions for setting up the environment for running the experiments

> 📖 Each folder contains a `README.md` file with detailed instructions
