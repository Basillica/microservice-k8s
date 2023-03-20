# !/bin/bash

kubectl apply -fk8s/secrets.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml

# then
kubectl get pods

# then
kubectl cp path/to/db/rates.sql <postgres-pod-name>:/data.sql
kubectl exec -it <postgres-pod-name> -- psql -U postgres -d mydb -f /data.sql
kubectl exec -it <postgres-pod-name> -- psql -U postgres -d mydb -c "SELECT * FROM regions"

# then 
kubectl apply -f k8s/flask-app-deployment.yaml 

# then
kubectl get services
minikube ip

# test from minikube shell
minikube ssh
curl http://192.168.49.2:30000
curl "http://192.168.49.2:30000/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"

# test from outside the container cluster
minikube service flask-app