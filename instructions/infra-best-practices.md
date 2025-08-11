# DevOps e Infraestrutura - Boas Práticas e Padrões

## Checklist de DevOps e Infraestrutura

### Containerização e Orquestração
- [ ] Docker images otimizadas (multi-stage builds)
- [ ] Docker Compose para desenvolvimento local
- [ ] Kubernetes manifests configurados
- [ ] Helm charts para deploy
- [ ] Container security scanning
- [ ] Resource limits e requests definidos
- [ ] Health checks implementados

### CI/CD Pipeline
- [ ] Pipeline declarativo (GitLab CI, GitHub Actions, Jenkins)
- [ ] Build automated com testes
- [ ] Security scanning integrado
- [ ] Quality gates configurados
- [ ] Blue-green ou canary deployment
- [ ] Rollback strategy definida
- [ ] Environment promotion process

### Infrastructure as Code
- [ ] Terraform ou CloudFormation
- [ ] Ansible para configuration management
- [ ] Secrets management (Vault, AWS Secrets)
- [ ] Infrastructure versioning
- [ ] State management configurado
- [ ] Drift detection implementado
- [ ] Disaster recovery plan

### Monitoring e Observabilidade
- [ ] Prometheus + Grafana configurado
- [ ] Centralized logging (ELK, Loki)
- [ ] Distributed tracing (Jaeger, Zipkin)
- [ ] Application Performance Monitoring (APM)
- [ ] Alerting rules definidas
- [ ] SLA/SLO metrics tracked
- [ ] Incident response procedures

### Segurança
- [ ] HTTPS/TLS configurado
- [ ] WAF (Web Application Firewall)
- [ ] Network security (VPC, subnets, security groups)
- [ ] RBAC (Role-Based Access Control)
- [ ] Secrets rotation automatizada
- [ ] Vulnerability scanning
- [ ] Compliance requirements met

## Templates de Infraestrutura

### Docker Configuration

#### Dockerfile Multi-stage Otimizado
```dockerfile
# Node.js Application
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npm prune --production

FROM node:18-alpine AS runtime
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy built application
COPY --from=build --chown=nextjs:nodejs /app/dist ./dist
COPY --from=dependencies --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nextjs:nodejs /app/package.json ./package.json

USER nextjs

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main.js"]

# .NET Application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["*.sln", "."]
COPY ["src/Api/*.csproj", "src/Api/"]
COPY ["src/Core/*.csproj", "src/Core/"]
COPY ["src/Infrastructure/*.csproj", "src/Infrastructure/"]
RUN dotnet restore

COPY . .
WORKDIR "/src/src/Api"
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create non-root user
RUN adduser --disabled-password --gecos "" --home "/nonexistent" --shell "/sbin/nologin" --no-create-home --uid 10001 appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

ENTRYPOINT ["dotnet", "Api.dll"]
```

#### Docker Compose Development
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://user:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=your-jwt-secret
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - app-network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    networks:
      - app-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

### Kubernetes Manifests

#### Deployment with ConfigMap and Secrets
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
  labels:
    name: myapp

---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: myapp
data:
  NODE_ENV: "production"
  PORT: "3000"
  LOG_LEVEL: "info"
  API_VERSION: "v1"

---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: myapp
type: Opaque
data:
  DATABASE_URL: cG9zdGdyZXNxbDovL3VzZXI6cGFzc3dvcmRAZGI6NTQzMi9teWFwcA==
  JWT_SECRET: eW91ci1qd3Qtc2VjcmV0
  REDIS_URL: cmVkaXM6Ly9yZWRpczozNjM3OQ==

---
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  namespace: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: app
        image: myapp:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
          name: http
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        securityContext:
          runAsNonRoot: true
          runAsUser: 10001
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
              - ALL
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
      securityContext:
        fsGroup: 10001

---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: myapp
  labels:
    app: myapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
    name: http
  selector:
    app: myapp

---
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: myapp
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - api.myapp.com
    secretName: app-tls
  rules:
  - host: api.myapp.com
    http:
      paths:
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80

---
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
  namespace: myapp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-deployment
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

### Traefik (docker-compose.yml)
```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.dashboard.tls=true"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
    
  app:
    image: myapp:latest
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.example.com`)"
      - "traefik.http.routers.app.tls=true"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
      - "traefik.http.services.app.loadbalancer.server.port=3000"
      # Rate limiting
      - "traefik.http.middlewares.ratelimit.ratelimit.burst=100"
      - "traefik.http.middlewares.ratelimit.ratelimit.average=50"
      - "traefik.http.routers.app.middlewares=ratelimit"
```

### iptables Firewall Rules
```bash
#!/bin/bash
# Basic iptables firewall script

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (change port as needed)
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allow HTTP and HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Rate limiting for SSH
iptables -A INPUT -p tcp --dport 22 -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

# Protection against port scanning
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Allow ping (limited)
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "iptables-dropped: "

# Save rules (Ubuntu/Debian)
iptables-save > /etc/iptables/rules.v4
```

### UFW Firewall (Ubuntu)
```bash
# Reset to defaults
ufw --force reset

# Default policies
ufw default deny incoming
ufw default allow outgoing

# SSH
ufw allow ssh
ufw limit ssh  # Rate limiting

# HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Specific application
ufw allow from 10.0.0.0/8 to any port 3000

# Enable firewall
ufw enable

# Status
ufw status verbose
```

## Comandos Úteis

### Docker
```bash
# Build otimizado
docker build --no-cache -t myapp:latest .

# Análise de segurança
docker scan myapp:latest

# Cleanup
docker system prune -a
```

### Kubernetes
```bash
# Status do cluster
kubectl cluster-info

# Logs de pod específico
kubectl logs -f deployment/app-deployment

# Port forward para debug
kubectl port-forward deployment/app-deployment 8080:3000
```

### Terraform
```bash
# Planejamento
terraform plan -out=tfplan

# Aplicar mudanças
terraform apply tfplan

# Verificar estado
terraform state list
```

### NGINX
```bash
# Testar configuração
nginx -t

# Reload sem downtime
nginx -s reload

# Ver logs em tempo real
tail -f /var/log/nginx/access.log

# Status do servidor
nginx -s status
```

### Firewall (iptables)
```bash
# Listar regras atuais
iptables -L -n -v

# Salvar regras
iptables-save > /etc/iptables/rules.v4

# Restaurar regras
iptables-restore < /etc/iptables/rules.v4

# Monitorar conexões
netstat -tulnp
```

## Comandos Essenciais DevOps

```bash
# Docker
docker build -t myapp:latest .
docker run -d -p 3000:3000 --name myapp myapp:latest
docker logs -f myapp
docker exec -it myapp /bin/sh
docker-compose up -d
docker-compose logs -f

# Kubernetes
kubectl apply -f k8s/
kubectl get pods -n myapp
kubectl logs -f deployment/myapp-deployment -n myapp
kubectl exec -it pod/myapp-pod -- /bin/sh
kubectl port-forward service/myapp-service 3000:80
kubectl scale deployment myapp-deployment --replicas=5

# Helm
helm install myapp ./helm/myapp
helm upgrade myapp ./helm/myapp --values values-prod.yaml
helm rollback myapp 1
helm list
helm status myapp

# Terraform
terraform init
terraform plan
terraform apply
terraform destroy
terraform state list
terraform import aws_instance.example i-1234567890abcdef0

# AWS CLI
aws eks update-kubeconfig --region us-west-2 --name my-cluster
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin
aws s3 sync ./build s3://my-bucket
aws logs tail /aws/lambda/my-function --follow

# Monitoring
kubectl port-forward -n monitoring service/prometheus-server 9090:80
kubectl port-forward -n monitoring service/grafana 3000:80
curl -G 'http://localhost:9090/api/v1/query' --data-urlencode 'query=up'
```
curl http://localhost:8080/api/http/routers

# Certificados
curl http://localhost:8080/api/http/routers | jq '.[] | select(.tls)'
```
