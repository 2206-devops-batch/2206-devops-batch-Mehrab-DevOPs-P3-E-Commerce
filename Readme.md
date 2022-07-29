# Mehrab-DevOPs-P3-E-Commerce

## Production / Cloud Dev

<!--
    Please follow the below instructions in order to access the cluster.
    Run "aws configure --profile YOUR_PROFILE_HERE"
    Use "YOUR_ACCESS_KEY_HERE" as the Access Key ID
    Use "YOUR_SECRET_KEY_HERE" as the Secret Access Key (sensitive - do not upload to git or any version control of any form)
    Use "us-east-1" as the region
    Output format does not matter - You may leave blank
    Run "aws eks --region us-east-1 update-kubeconfig --name YOUR_PROFILE_HERE --profile YOUR_PROFILE_HERE"
-->

Create an AWS EKS cluster with [Terrform]()

```zsh
cd terraform

terraform init
terraform apply
Then type yes
you can use terraform plan to see the changes being made before running apply
```

## Local Dev

Create a cluster with [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

```zsh
cd local-dev

kind create cluster --name monitoring --image kindest/node:v1.23.1 --config kind.yaml
```

Test our cluster to see all nodes are healthy and ready:

```zsh
kubectl get nodes
NAME                       STATUS   ROLES                  AGE   VERSION
monitoring-control-plane   Ready    control-plane,master   66s   v1.23.1
monitoring-worker          Ready    <none>                 25s   v1.23.1
monitoring-worker2         Ready    <none>                 38s   v1.23.1
monitoring-worker3         Ready    <none>                 38s   v1.23.1
```

### Kube Prometheus

The best method for monitoring, is to use the community manifests on the `kube-prometheus`
repository [here](https://github.com/prometheus-operator/kube-prometheus)

Now according to the compatibility matrix, we will need `release-0.10` to be compatible with
Kubernetes 1.23. </br>

Let's use docker to grab it!

```zsh
docker run -it -v ${PWD}:/work -w /work alpine sh
apk add git
```

Shallow clone the release branch into a temporary folder:

```zsh
# clone
git clone --depth 1 https://github.com/prometheus-operator/kube-prometheus.git -b release-0.10 /tmp/

# view the files
ls /tmp/ -l

# we are interested in the "manifests" folder
ls /tmp/manifests -l

# let's grab it by coping it out the container
cp -R /tmp/manifests .
```

### Prometheus Operator

To deploy all these manifests, we will need to setup the prometheus operator and custom resource definitions required.

This is all in the `setup` directory:

```zsh
ls /tmp/manifests/setup -l
```

Now that we have the source code manifests, we can exit our temporary container

```zsh
exit
```

### Setup Custom Resource Definition (CRDs)

Let's create the CRD's and prometheus operator

```zsh
kubectl create -f ./manifests/setup/
```

### Setup Manifests

Apply rest of manifests

```zsh
kubectl create -f ./manifests/
```

### Check Monitoring

```zsh
kubectl -n monitoring get pods

NAME                                   READY   STATUS    RESTARTS   AGE
alertmanager-main-0                    2/2     Running   0          26m
alertmanager-main-1                    2/2     Running   0          26m
alertmanager-main-2                    2/2     Running   0          26m
blackbox-exporter-6b79c4588b-rvd2n     3/3     Running   0          27m
grafana-7fd69887fb-vzshr               1/1     Running   0          27m
kube-state-metrics-55f67795cd-gmwlk    3/3     Running   0          27m
node-exporter-77d29                    2/2     Running   0          27m
node-exporter-7ndbl                    2/2     Running   0          27m
node-exporter-pgzq7                    2/2     Running   0          27m
node-exporter-vbxrt                    2/2     Running   0          27m
prometheus-adapter-85664b6b74-nhjw8    1/1     Running   0          27m
prometheus-adapter-85664b6b74-t5zfj    1/1     Running   0          27m
prometheus-k8s-0                       2/2     Running   0          26m
prometheus-k8s-1                       2/2     Running   0          26m
prometheus-operator-6dc9f66cb7-8bg77   2/2     Running   0          27m
```

### Check Prometheus

Similar to checking Grafana, we can also check Prometheus:

```zsh
kubectl -n monitoring port-forward svc/prometheus-operated 9090
```

### View Grafana Dashboards

You can access the dashboards by using `port-forward` to access Grafana.
It does not have a public endpoint for security reasons

```zsh
kubectl -n monitoring port-forward svc/grafana 3000
```

Then access Grafana on [localhost:3000](http://localhost:3000/)

#### Fix Grafana Datasource (If Needed)

Now for some reason, the Prometheus data source in Grafana does not work out the box. \
To fix it, we need to change the service endpoint of the data source.

To do this, edit `manifests/grafana-dashboardDatasources.yaml` and replace the datasource url endpoint with `http://prometheus-operated.monitoring.svc:9090`

We'll need to patch that and restart Grafana

```zsh
kubectl apply -f ./manifests/grafana-dashboardDatasources.yaml
kubectl -n monitoring delete po <grafana-pod>
kubectl -n monitoring port-forward svc/grafana 3000
```

Now our datasource should be healthy.

### Check Service Monitors

To see how Prometheus is configured on what to scrape , we list service monitors

```zsh
kubectl -n monitoring get servicemonitors
NAME                      AGE
alertmanager-main         8m58s
blackbox-exporter         8m57s
coredns                   8m57s
grafana                   8m57s
kube-apiserver            8m57s
kube-controller-manager   8m57s
kube-scheduler            8m57s
kube-state-metrics        8m57s
kubelet                   8m57s
node-exporter             8m57s
prometheus-adapter        8m56s
prometheus-k8s            8m56s
prometheus-operator       8m56s

kubectl -n monitoring describe servicemonitor node-exporter
```

Label selectors are used to map service monitor to kubernetes services. </br>

That is how Prometheus is configured on what to scrape.

[https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/monitoring/prometheus/kubernetes/1.23]

## [Jenkins](https://octopus.com/blog/jenkins-helm-install-guide)

```zsh
kubectl create namespace jenkins

helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins jenkins/jenkins -f jenkins-values.yaml

kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

echo http://127.0.0.1:8080 && kubectl --namespace jenkins port-forward svc/jenkins 8080:8080
```

# Preferend run Localy

> docker-compose up --build

# Backendend

> cd backend
>
> docker build -t backend:latest .
>
> docker run -d -p 5000:5000 -e DB_PLATFORM="org.hibernate.dialect.H2Dialect" -e DB_URL="jdbc:h2:mem:test;MODE=PostgreSQL" -e DB_DRIVER="org.h2.Driver" backend:latest

# Frontend

> cd frontend
>
> docker build -t frontend:latest .
>
> docker run -d -p 3000:80 frontend:latest

Now go to your browser and open: <http://localhost:3000/>

<!-- ## Prepare your enviornment

in the project back end directory, enter the command

> `mvn install`

Then, navagate into the `target` directory, and run the command:

> `mvn spring-boot:run`

which will run the Spring enviornment

The enviornment will be limited to the test data contained in this source code.

---

To run the front end, navigate to its directory and run the command:

> `npm install`

After that, running the command:

> `npm start`

within the directory will open the application in your browser. -->

<!--
```dockerfile
# pull official base image
FROM python:3.8.0-alpine

# set work directory
WORKDIR /usr/src

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/requirements.txt
RUN pip install -r requirements.txt

# copy entrypoint.sh
# COPY ./entrypoint.sh /usr/src/entrypoint.sh

# copy project
COPY . /usr/src/

# run entrypoint.sh
ENTRYPOINT ["/usr/src/entrypoint.sh"]
```

```entrypoint.sh
#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

python manage.py flush --no-input
python manage.py migrate
python manage.py collectstatic --no-input
#  --clear

# For Production:
gunicorn project.wsgi --reload --workers=2 --threads=4 --worker-tmp-dir=/dev/shm --bind=0.0.0.0:8000 --log-file=- --worker-class=gthread

exec "$@"
```
-->
