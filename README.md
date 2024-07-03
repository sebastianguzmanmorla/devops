# DevOps

A example of a automated deployment of Jenkins with dotnet node

Installation
------------

Copy .env.example to .env

```bash
cp ./.env.example ./.env
```

Modify required environment variables in .env file

Use Docker Compose to build and run

```bash
docker compose build
docker compose up -d
```

Run Windows agent in PowerShell

```ps
cd jenkins-agent-windows
./startup.ps1
```
