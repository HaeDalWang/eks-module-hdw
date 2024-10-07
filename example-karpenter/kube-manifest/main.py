from locust import HttpUser, task


class WebsiteUser(HttpUser):
    @task
    def index(self):
        self.client.get("/")

