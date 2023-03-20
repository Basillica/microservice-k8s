
## Practical case: Deployable development environment
### Solution (Kubernetes)
To test the application using kubernetes, [minikube](https://minikube.sigs.k8s.io/docs/start/), an image repository (like docker hub or ECR) and [kubectl](https://kubernetes.io/docs/reference/kubectl/) are required.

1. Start minikube
    ```bash
    minikube start
    ```
2. First change directory into the folder web to build, tag and publish an image of the flask app. There is a shell script for doing all that.
    ```bash
    cd web
    sh docker.sh
    ```
    You might have to set the env var `export DOCKER_DEFAULT_PLATFORM=linux/amd64` before building the image if you are on a mac M1 like me. The error message would be something like `SCRAM authentication requires libpq version 10 or above`.
3. Next, go back to the root of the application and run the following commands
    ```bash
    kubectl apply -fk8s/secrets.yaml  # setup the secrets
    kubectl apply -f k8s/postgres-pvc.yaml # configure the persistent volume claim for the postgres server
    kubectl apply -f k8s/postgres-deployment.yaml # deploy the postgres server
    ```
4. Afterwards, retrieve the name of the pod running the postgresql server
    ```bash
     kubectl get pods
    ```
5. Run the following commands using the name of the pod from above. This will copy the sql dump into a persistent volume clain and execute the command to dump the table into the postgres server that was created above.
    ```bash
    kubectl cp path/to/rates.sql <postgres-pod-id>:/data.sql # Copy the sql dump file to the pod(s) running the postgres server
    kubectl exec -it <postgres-pod-id> -- psql -U postgres -d mydb -f /data.sql # Run the command to dump the file
    ```
6. Test that the dump and configuration of the postgres server worked
    ```bash
    kubectl exec -it <postgres-pod-id> -- psql -U postgres -d mydb -c "SELECT * FROM regions" # Make a sample query to the postgres server to check if file was properly dumped
    ```
7. Then deploy the flask app image into the cluster
    ```bash
    kubectl apply -f k8s/flask-app-deployment.yaml # Deploy the flask app
    ```
To test the setup, I used the minikube shell as follows
```bash
minikube ssh
curl http://192.168.49.2:30000
curl "http://192.168.49.2:30000/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"
```

Even though we specified a NodePort in minikube, minikube will still not expose. It will use its own external port to listen to this service. Minikube tunnels the service to expose to the outer world. To find out what port was exposed:
```bash
    minikube service flask-app
```
This will display the message that looks like so
```txt
|-----------|-----------|-------------|---------------------------|
| NAMESPACE |   NAME    | TARGET PORT |            URL            |
|-----------|-----------|-------------|---------------------------|
| default   | flask-app | http/80     | http://192.168.49.2:30000 |
|-----------|-----------|-------------|---------------------------|
🏃  Starting tunnel for service flask-app.
|-----------|-----------|-------------|------------------------|
| NAMESPACE |   NAME    | TARGET PORT |          URL           |
|-----------|-----------|-------------|------------------------|
| default   | flask-app |             | http://127.0.0.1:59829 |
|-----------|-----------|-------------|------------------------|
```
The correct port will be displayed at the bottom. This should also open a browser page where it show the root address.
The app can also be tested with the endpoint. For example, in this case, it will be 
```bash
http://127.0.0.1:59829/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL%22
```

Assumptions/Limitations:
* Postgres DB also has a password for security reasons.
* The shell commands can be written to a shell script and be made part of a CI/CD pipeline runner
* The volume attachement is a very shaby one. It is best to have the RDS outside of the cluster
* Deployment in AWS will require an existing VPC

Choice of Kubernetes
* Kubernetes does a good job in orchestrating containers as is the case with this task
* It is also portable to the AWS cloud, integratable to a CI/CD pipeline
* It also allows storage of secrets, for the database any other sensitive information
* Secrets are encoded using the command `echo -n 'my-sample-secret' | base64` and then added to the secrets config file

### Solution (Docker Compose)
To test the setup with docker-compose, it is assumed that docker is already installed. Docker compose is used to orchestrate the containers, the application is then served behind an Nginx reverse proxy that also serves as a load balancer. The `docker-compose.yml` can be updated to either increase the `number of replicas` for the flask-app etc.
For certain chips, like the M1, you might still need to update the docker platform as an ENV variable
```bash
export DOCKER_DEFAULT_PLATFORM=linux/amd64
````
With the attached Makefile, you can then test the entire application
To serve the application,
```bash
make serve
````
To make calls to the endpoint
```bash
make test
````
To tear everything down after testing,
```bash
make tidy
```
