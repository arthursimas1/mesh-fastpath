kubectl logs deployment.apps/ping -n workload-ping-echo > logs-baseline.txt
kubectl logs deployment.apps/ping -n workload-ping-echo > logs-optimization.txt

kubectl scale --replicas=0 deployment.apps/ping -n workload-ping-echo
kubectl scale --replicas=1 deployment.apps/ping -n workload-ping-echo

kubectl delete ns/workload-ping-echo
