# Chat Modes Profissionais - Configuração Global

Esta configuração global do VS Code contém **3 chat modes especializados** disponíveis em todos os seus projetos.

## 🎯 **Chat Modes Disponíveis**

### 🏗️ **Infraestrutura** (`infra`)
**Especialista em**: DevOps, proxy reverso, firewall, containerização, CI/CD, monitoramento

**Use para:**
- Configurar NGINX, Traefik, HAProxy
- Implementar firewalls (iptables, UFW, pfSense)
- Setup Docker, Kubernetes, Helm
- CI/CD com GitHub Actions, GitLab CI
- Monitoramento com Prometheus, Grafana
- Cloud (AWS, Azure, GCP) e Terraform

**Exemplo:**
```
Configure um proxy reverso NGINX com SSL termination e rate limiting para uma aplicação Node.js
```

### 👨‍💻 **Desenvolvedor** (`dev`)
**Especialista em**: Programação, clean code, testes, performance, debugging

**Use para:**
- Desenvolvimento frontend/backend
- Code reviews e refatoração
- Implementação de testes (unitários, integração, E2E)
- Debugging e otimização de performance
- Boas práticas de programação
- Múltiplas linguagens (JS, TS, Python, Java, Go, etc.)

**Exemplo:**
```
Revise este componente React e sugira melhorias de performance e acessibilidade
```

### 🏛️ **Arquiteto de Software** (`architect`)
**Especialista em**: Design de sistemas, padrões arquiteturais, escalabilidade, decisões técnicas

**Use para:**
- Arquitetura de microservices
- Padrões (DDD, CQRS, Event Sourcing)
- Integração de sistemas (APIs, Message Queues)
- Escalabilidade e performance
- Architecture Decision Records (ADRs)
- System design e trade-offs

**Exemplo:**
```
Projete uma arquitetura de microservices para um e-commerce com alta disponibilidade e escalabilidade
```

## 🚀 **Como Usar**

1. **Abra qualquer projeto** no VS Code
2. **Abra o Chat** (`Ctrl+Alt+I`)
3. **Selecione o perfil** no dropdown de chat modes:
   - `infra` - Infraestrutura e DevOps
   - `dev` - Desenvolvimento de Software  
   - `architect` - Arquitetura de Software
4. **Faça sua pergunta** especializada!

## 🛠️ **Ferramentas Disponíveis**

Todos os chat modes têm acesso a:
- `codebase` - Análise do código do projeto atual
- `fetch` - Busca informações na web
- `search` - Pesquisa no workspace
- `usages` - Análise de uso de código
- `findTestFiles` - Localiza arquivos de teste (dev/architect)
- `githubRepo` - Pesquisa em repositórios GitHub (dev/architect)

## 📚 **Recursos Complementares**

### Instruções Detalhadas:
- `infra-best-practices.md` - Templates e checklists de infraestrutura
- `dev-best-practices.md` - Padrões de código e exemplos
- `architecture-patterns.md` - Padrões arquiteturais e ADRs

### Links Úteis:
- [VS Code Chat Modes Documentation](https://code.visualstudio.com/docs/copilot/chat/chat-modes)
- [Clean Code Principles](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
- [Microservices Patterns](https://microservices.io/patterns/)
- [Infrastructure Best Practices](https://12factor.net/)

## 🔧 **Personalização**

Para customizar os chat modes, edite os arquivos em:
```
~/.vscode/
├── chatmodes/
│   ├── infra.chatmode.md
│   ├── dev.chatmode.md
│   └── architect.chatmode.md
└── instructions/
    ├── infra-best-practices.md
    ├── dev-best-practices.md
    └── architecture-patterns.md
```

## �� **Dicas de Uso**

### Para Infraestrutura:
- "Como configurar load balancer com health checks?"
- "Setup de monitoring stack completo"
- "Implementar WAF com ModSecurity"

### Para Desenvolvimento:
- "Refatore este código seguindo SOLID"
- "Implemente testes unitários para essa função"
- "Otimize performance desta query"

### Para Arquitetura:
- "Compare microservices vs monolith para este caso"
- "Design event-driven architecture"
- "Estratégias de cache distribuído"

---

**Status**: ✅ Configuração global ativa  
**Localização**: `~/.vscode/chatmodes/`  
**Disponibilidade**: Todos os projetos VS Code  
**Última atualização**: $(date)

---

## 🎨 **Personalização Atual**

### Chat Mode Desenvolvedor - Stack Angular + NestJS
O chat mode `dev` foi personalizado para sua stack favorita:

**Frontend:**
- ✅ Angular 17+ com Standalone Components
- ✅ Angular Material + PrimeNG
- ✅ NgRx para state management
- ✅ RxJS para programação reativa
- ✅ TypeScript avançado

**Backend:**
- ✅ NestJS com TypeScript
- ✅ TypeORM + PostgreSQL
- ✅ JWT Authentication
- ✅ Swagger documentation
- ✅ Guards, Interceptors e Pipes

**Recursos Adicionais:**
- 📚 Templates prontos para componentes Angular
- 🧪 Exemplos de testes (Jasmine/Jest)
- ��️ Patterns de arquitetura NestJS
- 🔄 Types compartilhados entre frontend/backend
- 🐳 Dockerfiles otimizados para ambos

### Exemplos de Perguntas Otimizadas:

**Angular:**
```
Crie um standalone component Angular com Angular Material que consuma uma API NestJS
```

**NestJS:**
```
Implemente um CRUD completo com NestJS, TypeORM e validação de DTOs
```

**Full-Stack:**
```
Configure autenticação JWT entre Angular e NestJS com guards e interceptors
```

**Testes:**
```
Mostre como testar um service Angular que consome uma API NestJS
```
