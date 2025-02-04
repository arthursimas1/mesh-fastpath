# eSeMeshA: Code

This folder contains the source code for building and running eSeMeshA. It is composed by eBPF programs and userspace applications.

## Prerequisites

1. Install the prerequisites for building eBPF programs:
    ```bash
    cargo install bpf-linker
    cargo install bindgen-cli
    ```

## Build

1. eBPF
    ```bash
    cargo run --bin xtask build-ebpf
    ```

2. Userspace
    ```bash
    cargo build
    ```

> To perform a release build you can use the `--release` flag. _e.g._:
> ```bash
> cargo run --bin xtask build-ebpf --release
> cargo build --release
> ```

## Run

```bash
RUST_LOG=info cargo run --bin xtask run
```

## Release

Release builds can be performed by adding the `--release` flag to the build command.

```bash
cargo run --bin xtask build-ebpf --release
cargo build --release
```

The release binary will be available in `target/release/mesh-fastpath-userspace`.

<comment text="TODO: add `--target` flag section" />
