# 🚀 ChatModes System - Quick Start

Sistema completo de perfis especializados para desenvolvimento com VS Code.

## ⚡ Instalação Rápida

### Linux/macOS:
```bash
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install.sh | bash
```

### Windows (PowerShell - Recomendado):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install-windows.ps1" -OutFile "install-windows.ps1"
.\install-windows.ps1
```

### Windows (Git Bash):
```bash
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install.sh | bash
```

### 🪟 Problemas no Windows?
```bash
# Execute o diagnóstico
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/diagnose-windows.sh | bash

# Ou use o instalador interativo
curl -fsSL https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/install-windows.bat -o install-windows.bat
install-windows.bat
```

## 🎯 Perfis Disponíveis

| Perfil | Linux/macOS | Windows | Especialização |
|--------|-------------|---------|----------------|
| 🏗️ **Arquiteto** | `code ~/.vscode/chatmodes/architect.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\architect.chatmode.md"` | Arquitetura de Soluções |
| ⚡ **Angular** | `code ~/.vscode/chatmodes/dev-angular.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\dev-angular.chatmode.md"` | Angular 15+ |
| 🔧 **Angular Legacy** | `code ~/.vscode/chatmodes/dev-angular-legacy.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\dev-angular-legacy.chatmode.md"` | Angular 8-14 |
| ⚛️ **React** | `code ~/.vscode/chatmodes/dev-react.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\dev-react.chatmode.md"` | React 18+ |
| ☕ **Java** | `code ~/.vscode/chatmodes/dev-java.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\dev-java.chatmode.md"` | Spring Boot |
| 🟢 **Node.js** | `code ~/.vscode/chatmodes/dev-node.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\dev-node.chatmode.md"` | NestJS |
| 🔷 **C#** | `code ~/.vscode/chatmodes/dev-csharp.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\dev-csharp.chatmode.md"` | .NET Core |
| 🛠️ **DevOps** | `code ~/.vscode/chatmodes/infra.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\infra.chatmode.md"` | Docker/K8s |
| 🧪 **QA** | `code ~/.vscode/chatmodes/qa-specialist.chatmode.md` | `code "$env:USERPROFILE\.vscode\chatmodes\qa-specialist.chatmode.md"` | Testing |

## 📚 Como Usar

### 1. Abrir Perfil
```bash
# Via VS Code
code ~/.vscode/chatmodes/dev-angular.chatmode.md

# Via Quick Open (Ctrl+P)
~/.vscode/chatmodes/dev-angular.chatmode.md
```

### 2. Usar com IA Assistant
1. Copie o conteúdo do perfil
2. Cole no início da conversa
3. Especifique seu contexto
4. Faça sua pergunta

### 3. Validar Sistema
```bash
# Validação completa
~/.vscode/validate-chatmodes-improved.sh

# Teste específico
./test-angular-nestjs.sh
```

## 🔧 Configuração VS Code

Adicione no `settings.json`:
```json
{
  "chatmodes.enabled": true,
  "chatmodes.path": "~/.vscode/chatmodes",
  "files.associations": {
    "*.chatmode.md": "markdown"
  }
}
```

## 📖 Documentação Completa

- [**INSTALL-GUIDE.md**](INSTALL-GUIDE.md) - Guia completo de instalação
- [**Instructions/**](instructions/) - Documentação técnica detalhada
- [**ChatModes/**](chatmodes/) - Perfis especializados

## 🎯 Exemplos de Uso

### Angular + Material
```
Atue como: [colar dev-angular.chatmode.md]
Contexto: Sistema de e-commerce em Angular 17
Pergunta: Como criar um carrinho de compras reativo?
```

### NestJS API
```
Atue como: [colar dev-node.chatmode.md]  
Contexto: API REST com autenticação JWT
Pergunta: Como implementar middleware de autorização?
```

### Testing Strategy
```
Atue como: [colar qa-specialist.chatmode.md]
Contexto: Aplicação React com testes E2E
Pergunta: Como estruturar testes com Playwright?
```

## 🔍 Troubleshooting

```bash
# Verificar instalação
ls -la ~/.vscode/chatmodes/
ls -la ~/.vscode/instructions/

# Corrigir permissões (Linux/macOS)
chmod +x ~/.vscode/scripts/*.sh

# Revalidar sistema
~/.vscode/validate-chatmodes-improved.sh
```

## 🚀 Features

- ✅ **9 Perfis Especializados**
- ✅ **11 Arquivos de Instruções** 
- ✅ **Cross-Reference Completo**
- ✅ **Templates Prontos**
- ✅ **Scripts de Validação**
- ✅ **Instalação Automática**
- ✅ **Suporte Multi-OS**

---

**Desenvolvido para maximizar produtividade em desenvolvimento** 💡
