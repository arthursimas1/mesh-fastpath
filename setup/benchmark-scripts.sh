cargo run --bin xtask build-ebpf --release
cargo build --release

ssh -J ubuntu@oci-sp-vps-e2micro-01.3wx.ru ubuntu@192.168.2.2
ssh -TNL 9998:localhost:9999 -J ubuntu@ssh.forrestlab.casa ubuntu@192.168.2.2

scp ./target/release/ztunnel-fastpath-userspace ubuntu@ssh.int.forrestlab.casa:~/eztunnel
ssh ubuntu@ssh.int.forrestlab.casa
sudo su
lxc file push eztunnel workload/usr/local/bin/eztunnel

lxc shell workload
RUST_LOG=info eztunnel
eztunnel &


mkdir -p /mnt/logs/client

export SE_LABEL_cni=calico
export SE_LABEL_service_mesh=none
export SE_LABEL_optimization=disabled

export SE_INSTANCE=ping-echo
#sed -i 's/#istio-injection: enabled/istio-injection: enabled/' eztunnel/workloads/ping-echo/manifest.yml
kubectl apply -f eztunnel/workloads/ping-echo/manifest.yml
statexec -f "statexec_metrics_${SE_INSTANCE}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}_$(date -u -Iseconds).prom" -dac 2 -- kubectl wait --for=condition=completed --timeout=30m -n workload-ping-echo job.batch/ping
kubectl delete -f eztunnel/workloads/ping-echo/manifest.yml

export SE_INSTANCE=file-transfer
#sed -i 's/#istio-injection: enabled/istio-injection: enabled/' eztunnel/workloads/file-transfer/manifest.yml
kubectl apply -f eztunnel/workloads/file-transfer/manifest.yml
statexec -f "statexec_metrics_${SE_INSTANCE}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}_$(date -u -Iseconds).prom" -dac 2 -- kubectl wait --for=condition=completed --timeout=30m -n workload-file-transfer job.batch/client
kubectl logs -n workload-file-transfer job.batch/client > /mnt/logs/client/log.txt
kubectl delete -f eztunnel/workloads/file-transfer/manifest.yml

export SE_INSTANCE=redis
#sed -i 's/#istio-injection: enabled/istio-injection: enabled/' eztunnel/workloads/redis/manifest.yml
kubectl apply -f eztunnel/workloads/redis/manifest.yml
statexec -f "statexec_metrics_${SE_INSTANCE}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}_$(date -u -Iseconds).prom" -dac 2 -- kubectl wait --for=condition=completed --timeout=30m -n workload-redis job.batch/memtier
kubectl logs -n workload-redis job.batch/memtier > /mnt/logs/memtier/log.txt
kubectl delete -f eztunnel/workloads/redis/manifest.yml

kill -SIGINT 15924

mv statexec_metrics* /mnt/logs/
zip -r /mnt/logs_${SE_LABEL_cni}_${SE_LABEL_service_mesh}_${SE_LABEL_optimization}.zip /mnt/logs

lxc file pull workload-cilium-0/mnt/logs-* .

rm -rf /mnt/*

