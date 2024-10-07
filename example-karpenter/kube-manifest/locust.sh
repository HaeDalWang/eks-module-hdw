{
	cat <<EOF | tee main.py
from locust import HttpUser, task


class WebsiteUser(HttpUser):
    @task
    def index(self):
        self.client.get("/")

EOF
	kubectl create ns locust
	kubectl create configmap locustfile --from-file=main.py -n locust
	helm install locust deliveryhero/locust -n locust -f - <<EOF
loadtest:
  locust_locustfile_configmap: locustfile
ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
  hosts:
	- path: /
	  pathType: Prefix
EOF
}