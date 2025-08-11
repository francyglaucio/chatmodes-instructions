# ChatModes System - Guia Completo de Instalação e Uso

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Instalação Global](#instalação-global)
- [Instalação Específica Windows](#instalação-específica-windows)
- [Configuração do VS Code](#configuração-do-vs-code)
- [Estrutura do Sistema](#estrutura-do-sistema)
- [Como Usar](#como-usar)
- [Perfis Disponíveis](#perfis-disponíveis)
- [Personalização](#personalização)
- [Troubleshooting](#troubleshooting)
- [Scripts de Validação](#scripts-de-validação)

## 🌟 Visão Geral

O **ChatModes System** é um conjunto de perfis especializados para desenvolvimento que integra com o VS Code, fornecendo contexto especializado para diferentes tecnologias e funções.

### Características Principais:
- ✅ **9 Perfis Especializados**: Angular, React, Java, Node.js, C#, QA, Arquiteto, Infra, Angular Legacy
- ✅ **11 Arquivos de Instruções**: Documentação detalhada para cada tecnologia
- ✅ **Cross-Reference Completo**: Links entre perfis e instruções
- ✅ **Templates Prontos**: Códigos e comandos para uso imediato
- ✅ **Best Practices**: Práticas recomendadas para cada stack

## 🔧 Pré-requisitos

### Software Necessário:

#### Todos os Sistemas:
```bash
# VS Code (versão 1.70+)
# Terminal com suporte a cores
```

#### Linux/macOS:
```bash
# Git (para versionamento)
# curl (para downloads)
# Node.js 18+ (para projetos JavaScript/TypeScript)
# Terminal: zsh/bash
```

#### Windows:
```powershell
# VS Code (versão 1.70+)
# PowerShell 5.0+ (incluído no Windows 10+)
# Git for Windows (opcional, para Git Bash)
# Node.js 18+ (para projetos JavaScript/TypeScript)
```

**Links de Download Windows:**
- [VS Code](https://code.visualstudio.com/)
- [Git for Windows](https://git-scm.com/download/win) (opcional)
- [Node.js](https://nodejs.org/)

### Extensões VS Code Recomendadas:
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "angular.ng-template",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-python.python",
    "ms-dotnettools.csharp",
    "vscjava.vscode-java-pack",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-playwright.playwright"
  ]
}
```

## 🚀 Instalação Global

### Método 1: Instalação Automática (Recomendado)

#### Linux/macOS:
```bash
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install.sh | bash
```

#### Windows - Opção A (PowerShell - Recomendado):
```powershell
# Execute no PowerShell como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install-windows.ps1" -OutFile "install-windows.ps1"
.\install-windows.ps1
```

#### Windows - Opção B (Git Bash):
```bash
# Execute no Git Bash como Administrador
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install.sh | bash
```

#### Windows - Opção C (Installer Batch):
```cmd
# Baixe e execute o installer batch
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install-windows.bat -o install-windows.bat
install-windows.bat
```

### Método 2: Instalação Manual

#### Passo 1: Criar estrutura de diretórios
```bash
# Linux/macOS
mkdir -p ~/.vscode/chatmodes
mkdir -p ~/.vscode/instructions

# Windows (PowerShell)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.vscode\chatmodes"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.vscode\instructions"
```

#### Passo 2: Clonar o repositório
```bash
git clone https://github.com/francyglaucio/chatmodes-instructions.git
cd chatmodes-instructions
```

#### Passo 3: Copiar arquivos para diretório global
```bash
# Linux/macOS
cp chatmodes/* ~/.vscode/chatmodes/
cp instructions/* ~/.vscode/instructions/

# Windows (PowerShell)
Copy-Item -Path "chatmodes\*" -Destination "$env:USERPROFILE\.vscode\chatmodes\" -Recurse
Copy-Item -Path "instructions\*" -Destination "$env:USERPROFILE\.vscode\instructions\" -Recurse
```

#### Passo 4: Tornar scripts executáveis (Linux/macOS)
```bash
chmod +x ~/.vscode/chatmodes/*.sh
chmod +x test-angular-nestjs.sh
chmod +x validate-chatmodes.sh
```

## 🪟 Instalação Específica Windows

### Problemas Identificados no Windows

O instalador original pode falhar no Windows devido a:
- Diferenças de paths entre Unix e Windows
- Diretório temporário `/tmp` inexistente
- Comandos `curl` com flags incompatíveis
- Permissões do sistema de arquivos

### Soluções Disponíveis

#### 🥇 Método PowerShell (Mais Confiável)
```powershell
# 1. Configurar política de execução
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. Baixar e executar instalador PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install-windows.ps1" -OutFile "install-windows.ps1"
.\install-windows.ps1

# Para forçar instalação sem prompts:
.\install-windows.ps1 -Force
```

#### 🥈 Método Git Bash (Script Corrigido)
```bash
# Requer Git for Windows instalado
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install.sh | bash
```

#### 🥉 Método Batch Interativo
```cmd
# Baixar e executar menu interativo
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install-windows.bat -o install-windows.bat
install-windows.bat
```

#### 🔧 Diagnóstico de Problemas
```bash
# Execute se tiver problemas
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/diagnose-windows.sh | bash
```

### Estrutura no Windows
Após instalação, arquivos estarão em:
```
C:\Users\[SeuUsuario]\.vscode\
├── chatmodes\          # 10 perfis especializados
├── instructions\       # 11 arquivos de instruções  
├── scripts\           # Scripts utilitários
├── INSTALL-GUIDE.md   # Este guia
└── README.md          # Guia rápido
```

### Atalhos Windows
```powershell
# Abrir perfil específico
& "$env:USERPROFILE\.vscode\scripts\open-chatmode.ps1" "dev-angular"

# Listar perfis disponíveis
Get-ChildItem "$env:USERPROFILE\.vscode\chatmodes" -Filter "*.chatmode.md" | ForEach-Object { $_.BaseName.Replace('.chatmode', '') }

# Validar instalação
& "$env:USERPROFILE\.vscode\scripts\validate-chatmodes.sh"
```

### Verificação da Instalação

Execute o script de validação:
```bash
# No diretório do projeto
./validate-chatmodes.sh

# Ou globalmente
~/.vscode/validate-chatmodes.sh
```

Saída esperada:
```
✅ Validação do Sistema ChatModes
================================

✅ Diretório chatmodes encontrado
✅ Diretório instructions encontrado
✅ 9 perfis de chatmode encontrados
✅ 11 arquivos de instruções encontrados
✅ Todos os links estão funcionais

📊 Resumo:
- architect.chatmode.md (1547 linhas)
- dev-angular.chatmode.md (892 linhas)
- qa-specialist.chatmode.md (1203 linhas)
- Total: 15,243 linhas de documentação

🎯 Sistema instalado com sucesso!
```

## ⚙️ Configuração do VS Code

### 1. Configurar Settings.json Global

Abra as configurações globais do VS Code:
- **Windows**: `Ctrl+Shift+P` → "Open User Settings (JSON)"
- **macOS**: `Cmd+Shift+P` → "Open User Settings (JSON)"
- **Linux**: `Ctrl+Shift+P` → "Open User Settings (JSON)"

Adicione as seguintes configurações:

```json
{
  "chatmodes.enabled": true,
  "chatmodes.path": "~/.vscode/chatmodes",
  "chatmodes.instructions": "~/.vscode/instructions",
  "chatmodes.autoLoad": true,
  "chatmodes.defaultProfile": "architect",
  
  // Configurações para melhor experiência
  "editor.quickSuggestions": {
    "strings": true,
    "comments": true,
    "other": true
  },
  "editor.suggest.snippetsPreventQuickSuggestions": false,
  "files.associations": {
    "*.chatmode.md": "markdown"
  },
  
  // Configurações de terminal
  "terminal.integrated.defaultProfile.linux": "zsh",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  
  // Melhorar performance para projetos grandes
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.git": true
  }
}
```

### 2. Configurar Keybindings (Opcional)

Adicione atalhos personalizados no `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+c",
    "command": "workbench.action.quickOpen",
    "args": "~/.vscode/chatmodes/"
  },
  {
    "key": "ctrl+shift+i", 
    "command": "workbench.action.quickOpen",
    "args": "~/.vscode/instructions/"
  },
  {
    "key": "f12",
    "command": "markdown.showPreview",
    "when": "editorLangId == markdown"
  }
]
```

### 3. Criar Workspace Template

Crie um template de workspace em `~/.vscode/workspace-template.code-workspace`:

```json
{
  "folders": [
    {
      "name": "Projeto Principal",
      "path": "."
    },
    {
      "name": "ChatModes",
      "path": "~/.vscode/chatmodes"
    },
    {
      "name": "Instructions",
      "path": "~/.vscode/instructions"
    }
  ],
  "settings": {
    "chatmodes.enabled": true,
    "editor.rulers": [80, 120],
    "files.trimTrailingWhitespace": true,
    "editor.formatOnSave": true
  },
  "extensions": {
    "recommendations": [
      "ms-vscode.vscode-typescript-next",
      "angular.ng-template",
      "ms-playwright.playwright",
      "esbenp.prettier-vscode"
    ]
  }
}
```

## 🏗️ Estrutura do Sistema

```
~/.vscode/
├── chatmodes/                     # Perfis especializados
│   ├── architect.chatmode.md      # Arquiteto de Soluções
│   ├── dev-angular.chatmode.md    # Angular Moderno (15+)
│   ├── dev-angular-legacy.chatmode.md  # Angular Legacy (8-14)
│   ├── dev-react.chatmode.md      # React Specialist
│   ├── dev-java.chatmode.md       # Java/Spring Boot
│   ├── dev-node.chatmode.md       # Node.js/NestJS
│   ├── dev-csharp.chatmode.md     # C#/.NET
│   ├── dev.chatmode.md            # Full-Stack (Angular + NestJS)
│   ├── infra.chatmode.md          # DevOps/Infraestrutura
│   └── qa-specialist.chatmode.md  # Quality Assurance
│
├── instructions/                  # Documentação detalhada
│   ├── architecture-patterns.md  # Padrões arquiteturais
│   ├── angular-best-practices.md # Angular moderno
│   ├── angular-legacy-best-practices.md # Angular legacy
│   ├── angular-nestjs-practices.md # Stack completa
│   ├── react-best-practices.md   # React patterns
│   ├── java-best-practices.md    # Java/Spring Boot
│   ├── nodejs-best-practices.md  # Node.js/NestJS
│   ├── csharp-best-practices.md  # C#/.NET
│   ├── dev-best-practices.md     # Práticas gerais
│   ├── infra-best-practices.md   # DevOps
│   └── qa-best-practices.md      # Quality Assurance
│
└── scripts/                      # Scripts utilitários
    ├── validate-chatmodes.sh     # Validação do sistema
    ├── test-angular-nestjs.sh    # Teste específico
    └── install.sh                # Instalador automático
```

## 🎯 Como Usar

### Método 1: Via Command Palette

1. **Abrir Command Palette**: `Ctrl+Shift+P` (Windows/Linux) ou `Cmd+Shift+P` (macOS)
2. **Digitar**: "Open File"
3. **Navegar**: `~/.vscode/chatmodes/`
4. **Selecionar** o perfil desejado

### Método 2: Via Quick Open

1. **Quick Open**: `Ctrl+P` (Windows/Linux) ou `Cmd+P` (macOS)
2. **Digitar**: `~/.vscode/chatmodes/dev-angular.chatmode.md`
3. **Enter** para abrir

### Método 3: Via Terminal

```bash
# Visualizar perfil específico
code ~/.vscode/chatmodes/dev-angular.chatmode.md

# Abrir instruções relacionadas
code ~/.vscode/instructions/angular-best-practices.md

# Validar sistema
~/.vscode/scripts/validate-chatmodes.sh
```

### Método 4: Integração com IA Assistant

Quando usar um AI Assistant (GitHub Copilot, Claude, etc.):

1. **Abra o perfil** relevante para seu projeto
2. **Copie o conteúdo** do chatmode
3. **Cole no início** da conversa com a IA
4. **Especifique** seu contexto atual

**Exemplo:**
```
Atue como o perfil: [colar conteúdo do dev-angular.chatmode.md]

Contexto atual: Estou desenvolvendo um sistema de e-commerce em Angular 17 com Angular Material.

Pergunta: Como implementar um carrinho de compras reativo com NgRx?
```

## 📚 Perfis Disponíveis

| Perfil | Arquivo | Especialização | Tecnologias |
|--------|---------|----------------|-------------|
| **Arquiteto** | `architect.chatmode.md` | Arquitetura de Soluções | Patterns, Microservices, Clean Architecture |
| **Angular Moderno** | `dev-angular.chatmode.md` | Angular 15+ | Standalone Components, Signals, Material |
| **Angular Legacy** | `dev-angular-legacy.chatmode.md` | Angular 8-14 | NgModules, ViewEngine/Ivy |
| **React** | `dev-react.chatmode.md` | React 18+ | Hooks, Context, Next.js |
| **Java** | `dev-java.chatmode.md` | Java/Spring Boot | Spring Security, JPA, Maven |
| **Node.js** | `dev-node.chatmode.md` | Node.js/NestJS | Express, TypeORM, JWT |
| **C#** | `dev-csharp.chatmode.md` | .NET Core/5+ | ASP.NET, Entity Framework |
| **Full-Stack** | `dev.chatmode.md` | Angular + NestJS | Stack completa |
| **DevOps** | `infra.chatmode.md` | Infraestrutura | Docker, K8s, CI/CD |
| **QA** | `qa-specialist.chatmode.md` | Quality Assurance | Cypress, Playwright, Jest |

### Quando Usar Cada Perfil:

#### 🏗️ **Architect** - Use quando:
- Planejando arquitetura de sistemas
- Definindo padrões e boas práticas
- Projetando microserviços
- Escolhendo tecnologias

#### ⚡ **Angular Moderno** - Use quando:
- Projetos Angular 15+
- Standalone Components
- Angular Signals
- Migrações modernas

#### 🔧 **Angular Legacy** - Use quando:
- Projetos Angular 8-14
- NgModules tradicionais
- Migrações incrementais
- Manutenção de sistemas antigos

#### ⚛️ **React** - Use quando:
- Projetos React 18+
- Next.js
- Microfrontends
- Hooks modernos

#### ☕ **Java** - Use quando:
- Spring Boot
- APIs REST
- Microserviços Java
- Integração com bancos

#### 🟢 **Node.js** - Use quando:
- NestJS
- APIs Node.js
- TypeScript backend
- Integrações

#### 🔷 **C#** - Use quando:
- .NET Core/5+
- ASP.NET Core
- Entity Framework
- Azure

#### 🔄 **Full-Stack** - Use quando:
- Angular + NestJS
- Stack completa
- Projetos integrados
- Autenticação JWT

#### 🛠️ **DevOps** - Use quando:
- Docker/Kubernetes
- CI/CD pipelines
- Cloud deployment
- Monitoramento

#### 🧪 **QA** - Use quando:
- Automação de testes
- Estratégias de testing
- Performance testing
- Qualidade de código

## 🎨 Personalização

### Criando Perfis Customizados

1. **Crie um novo arquivo** em `~/.vscode/chatmodes/`:
```bash
touch ~/.vscode/chatmodes/custom-profile.chatmode.md
```

2. **Use o template base**:
```markdown
# Nome do Perfil - Especialização

Você é um especialista em [TECNOLOGIA] com expertise em [ÁREAS].

## Contexto de Trabalho
- **Foco Principal**: [TECNOLOGIA_PRINCIPAL]
- **Frameworks**: [FRAMEWORKS]
- **Padrões**: [PATTERNS]

## Instruções Detalhadas
Consulte também: [Instruções Específicas](../instructions/custom-instructions.md)

## Templates Rápidos

### Template 1
```[LINGUAGEM]
// Código exemplo
```

## Comandos Essenciais
```bash
# Comandos específicos da tecnologia
```

## Especialização
- Área 1
- Área 2
- Área 3
```

### Adicionando Instruções Customizadas

1. **Crie arquivo de instruções**:
```bash
touch ~/.vscode/instructions/custom-instructions.md
```

2. **Adicione conteúdo detalhado**:
```markdown
# Custom Technology - Best Practices

## Checklist
- [ ] Item 1
- [ ] Item 2

## Patterns
### Pattern 1
```[LINGUAGEM]
// Implementação
```

## Commands
```bash
# Comandos
```
```

### Configuração por Projeto

Crie um `.vscode/settings.json` no projeto:
```json
{
  "chatmodes.defaultProfile": "dev-angular",
  "chatmodes.projectSpecific": {
    "primary": "dev-angular.chatmode.md",
    "secondary": "qa-specialist.chatmode.md"
  }
}
```

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. **Problemas no Windows (NOVO)**

**Script não baixa arquivos:**
```powershell
# Diagnóstico Windows
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/diagnose-windows.sh | bash

# Ou use o PowerShell (método preferido)
.\install-windows.ps1

# Se persistir, instalação manual:
# 1. Crie os diretórios manualmente
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.vscode\chatmodes"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.vscode\instructions"

# 2. Baixe os arquivos um por um
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/chatmodes/dev-angular.chatmode.md" -OutFile "$env:USERPROFILE\.vscode\chatmodes\dev-angular.chatmode.md"
```

**Erro de Execution Policy:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# ou
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

**Git Bash não encontrado:**
- Instale o Git for Windows: https://git-scm.com/download/win
- Ou use o método PowerShell

#### 2. **Arquivos não encontrados**
```bash
# Verificar se os diretórios existem
# Linux/macOS:
ls -la ~/.vscode/chatmodes/
ls -la ~/.vscode/instructions/

# Windows (PowerShell):
Get-ChildItem "$env:USERPROFILE\.vscode\chatmodes"
Get-ChildItem "$env:USERPROFILE\.vscode\instructions"

# Recriar se necessário
# Linux/macOS:
mkdir -p ~/.vscode/{chatmodes,instructions}

# Windows (PowerShell):
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.vscode\chatmodes"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.vscode\instructions"
```

#### 3. **Permissões no Linux/macOS**
```bash
# Corrigir permissões
chmod 755 ~/.vscode/chatmodes/
chmod 644 ~/.vscode/chatmodes/*.md
chmod +x ~/.vscode/scripts/*.sh
```

#### 4. **Links quebrados**
```bash
# Validar links (Linux/macOS)
./validate-chatmodes.sh

# Windows (PowerShell)
& "$env:USERPROFILE\.vscode\scripts\validate-chatmodes.sh"

# Corrigir manualmente se necessário
```

#### 5. **VS Code não reconhece arquivos**
```bash
# Recarregar VS Code
# Ctrl+Shift+P → "Developer: Reload Window"

# Verificar associações de arquivo
# Settings → files.associations
```

### Scripts de Diagnóstico

#### Script de Health Check
```bash
#!/bin/bash
# ~/.vscode/scripts/health-check.sh

echo "🔍 ChatModes Health Check"
echo "========================"

# Verificar estrutura
for dir in chatmodes instructions scripts; do
    if [ -d ~/.vscode/$dir ]; then
        echo "✅ Diretório $dir OK"
        echo "   Arquivos: $(ls ~/.vscode/$dir | wc -l)"
    else
        echo "❌ Diretório $dir não encontrado"
    fi
done

# Verificar links
echo
echo "🔗 Verificando links..."
broken_links=0
for chatmode in ~/.vscode/chatmodes/*.md; do
    if [ -f "$chatmode" ]; then
        while IFS= read -r line; do
            if [[ $line =~ \[.*\]\((.*\.md)\) ]]; then
                link="${BASH_REMATCH[1]}"
                if [[ $link =~ ^\.\./ ]]; then
                    full_path="~/.vscode/${link#../}"
                    if [ ! -f "${full_path/~/$HOME}" ]; then
                        echo "❌ Link quebrado: $link em $(basename $chatmode)"
                        ((broken_links++))
                    fi
                fi
            fi
        done < "$chatmode"
    fi
done

if [ $broken_links -eq 0 ]; then
    echo "✅ Todos os links funcionais"
else
    echo "❌ $broken_links links quebrados encontrados"
fi

echo
echo "📊 Status: $([[ $broken_links -eq 0 ]] && echo "SAUDÁVEL" || echo "REQUER ATENÇÃO")"
```

## 📝 Scripts de Validação

### Validação Completa
Execute para verificar a integridade do sistema:

#### Linux/macOS:
```bash
./validate-chatmodes.sh
# ou
~/.vscode/scripts/validate-chatmodes.sh
```

#### Windows:
```powershell
# PowerShell
& "$env:USERPROFILE\.vscode\scripts\validate-chatmodes.sh"

# Git Bash
~/.vscode/scripts/validate-chatmodes.sh
```

### Teste Angular + NestJS
Execute para testar perfil específico:

#### Linux/macOS:
```bash
./test-angular-nestjs.sh
```

#### Windows:
```powershell
& "$env:USERPROFILE\.vscode\scripts\test-angular-nestjs.sh"
```

### Diagnóstico Windows
Se houver problemas específicos no Windows:
```bash
# Execute no Git Bash
./diagnose-windows.sh
```

### Auto-Update
Configure atualização automática:

#### Linux/macOS:
```bash
#!/bin/bash
# ~/.vscode/scripts/auto-update.sh

cd ~/.vscode/
git pull origin main
echo "✅ ChatModes atualizado"
```

#### Windows (PowerShell):
```powershell
# ~\.vscode\scripts\auto-update.ps1
Set-Location "$env:USERPROFILE\.vscode"
git pull origin main
Write-Host "✅ ChatModes atualizado" -ForegroundColor Green
```

## 🚀 Próximos Passos

1. **Execute a validação** para confirmar instalação
2. **Teste um perfil** com seu projeto atual
3. **Personalize** conforme suas necessidades
4. **Integre** com seu workflow de desenvolvimento
5. **Compartilhe** com sua equipe

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/francyglaucio/chatmodes-instructions/issues)
- **Documentação**: [Wiki](https://github.com/francyglaucio/chatmodes-instructions/wiki)
- **Updates**: Watch no repositório para atualizações

---

**Desenvolvido com ❤️ para maximizar produtividade em desenvolvimento**
