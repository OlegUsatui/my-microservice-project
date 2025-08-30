from django.http import HttpResponse

def home(request):
    return HttpResponse("✅ Hello from Dockerized Django via Nginx + PostgreSQL!")

def healthz(request):
    return HttpResponse("ok")
