# Instruções de Infraestrutura - Boas Práticas

## Checklist de Revisão de Infraestrutura

### Docker e Containerização
- [ ] Multi-stage builds para otimizar tamanho da imagem
- [ ] Non-root user nos containers
- [ ] Health checks definidos
- [ ] Recursos limitados (CPU/Memory)
- [ ] Secrets não expostos em variáveis de ambiente
- [ ] Imagens base seguras e atualizadas

### Kubernetes
- [ ] Resource limits e requests definidos
- [ ] Liveness e readiness probes configurados
- [ ] ConfigMaps e Secrets para configuração
- [ ] NetworkPolicies para segmentação
- [ ] RBAC apropriado
- [ ] Horizontal Pod Autoscaler quando necessário

### CI/CD
- [ ] Pipelines com stages bem definidos (build, test, deploy)
- [ ] Secrets gerenciados de forma segura
- [ ] Rollback strategy implementada
- [ ] Testes automatizados incluídos
- [ ] Security scanning nos pipelines
- [ ] Deployment strategy (blue-green, canary, rolling)

### Monitoramento
- [ ] Métricas de aplicação coletadas
- [ ] Logs estruturados e centralizados
- [ ] Alertas configurados para cenários críticos
- [ ] Dashboards para visualização
- [ ] SLA/SLI definidos
- [ ] Distributed tracing para microservices

### Proxy Reverso
- [ ] Load balancing configurado adequadamente
- [ ] SSL termination implementada
- [ ] Rate limiting configurado
- [ ] Health checks para backends
- [ ] Logs de acesso e erro habilitados
- [ ] Caching headers configurados
- [ ] Compression (gzip/brotli) habilitada
- [ ] Security headers implementados

### Firewall e Segurança de Rede
- [ ] Regras de firewall documentadas e revisadas
- [ ] Princípio do menor privilégio aplicado
- [ ] Ports desnecessários fechados
- [ ] WAF configurado para aplicações web
- [ ] DDoS protection habilitada
- [ ] Network segmentation implementada
- [ ] VPN configurada para acesso administrativo
- [ ] IDS/IPS monitorando tráfego suspeito

### Segurança
- [ ] Network segmentation implementada
- [ ] SSL/TLS certificates atualizados
- [ ] Vulnerability scanning automatizado
- [ ] Access control e audit logs
- [ ] Backup e disaster recovery testados
- [ ] Data encryption at rest e in transit

### Performance
- [ ] Load testing realizado
- [ ] Database optimization
- [ ] Caching strategy implementada
- [ ] CDN configurado quando necessário
- [ ] Auto-scaling policies
- [ ] Resource utilization monitorada

## Templates de Configuração

### docker-compose.yml básico
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
```

### Kubernetes Deployment básico
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        ports:
        - containerPort: 3000
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
```

### NGINX Proxy Reverso
```nginx
server {
    listen 80;
    server_name example.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
    
    # Proxy Configuration
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Health Check
        proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
    }
    
    # Static Files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Backend Pool
upstream backend {
    least_conn;
    server 10.0.1.10:3000 weight=3 max_fails=3 fail_timeout=30s;
    server 10.0.1.11:3000 weight=3 max_fails=3 fail_timeout=30s;
    server 10.0.1.12:3000 weight=1 backup;
}
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

### Traefik
```bash
# Ver logs
docker logs traefik -f

# Dashboard API
curl http://localhost:8080/api/http/routers

# Certificados
curl http://localhost:8080/api/http/routers | jq '.[] | select(.tls)'
```
