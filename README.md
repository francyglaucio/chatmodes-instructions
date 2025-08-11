# ChatModes - Contextos para IA

Sistema de contextos especializados para uso com assistentes de IA (ChatGPT, GitHub Copilot, etc.).

## ✅ Status da Instalação

Os ChatModes já estão instalados e prontos para uso em `~/.vscode/.github/`:
- **10 chatmodes** especializados disponíveis
- **11 instructions** com documentação de apoio

Para verificar a instalação, execute:
```bash
./test.sh
```

## 📋 ChatModes Disponíveis

| Arquivo | Especialização | Descrição |
|---------|---------------|-----------|
| `dev-angular.chatmode.md` | Angular 15+ | Standalone components, Signals, Material |
| `dev-angular-legacy.chatmode.md` | Angular 8-14 | NgModules, ViewEngine/Ivy |
| `dev-react.chatmode.md` | React | Hooks, Context, Next.js |
| `dev-node.chatmode.md` | Node.js | Express, NestJS, APIs |
| `dev-java.chatmode.md` | Java | Spring Boot, microserviços |
| `dev-csharp.chatmode.md` | C#/.NET | ASP.NET Core, Entity Framework |
| `dev.chatmode.md` | Desenvolvedor | Contexto geral de desenvolvimento |
| `architect.chatmode.md` | Arquitetura | Design de sistemas, padrões |
| `infra.chatmode.md` | DevOps | Docker, Kubernetes, CI/CD |
| `qa-specialist.chatmode.md` | QA | Testes, automação, qualidade |

## 💡 Como Usar

### Método 1: Script Helper (Recomendado)
```bash
./chatmode.sh list                    # Lista todos os chatmodes
./chatmode.sh open dev-angular        # Abre no VS Code
./chatmode.sh copy infra              # Copia para clipboard
```

### Método 2: Manual
1. **Abra** o arquivo `.chatmode.md` desejado em `~/.vscode/.github/chatmodes/`
2. **Copie** todo o conteúdo do arquivo
3. **Cole** no início de uma nova conversa com ChatGPT/Copilot
4. **Faça** sua pergunta específica

### Exemplo de Uso:
```
[Cole o conteúdo do dev-angular.chatmode.md]

Como criar um component standalone com Angular Signals?
```

## 📚 Documentação de Apoio

Os arquivos em `~/.vscode/.github/instructions/` contêm:
- Checklists de boas práticas
- Padrões recomendados  
- Exemplos de código
- Configurações otimizadas

## 🔄 Atualização

Para verificar a instalação ou atualizar:
```bash
./install.sh  # Verifica/instala os ChatModes
./test.sh     # Testa a instalação
```

## 🗂️ Estrutura de Arquivos

```
~/.vscode/
├── .github/
│   ├── chatmodes/          # 10 contextos especializados
│   │   ├── dev-angular.chatmode.md
│   │   ├── dev-react.chatmode.md
│   │   ├── infra.chatmode.md
│   │   └── ...
│   └── instructions/       # 11 guias de boas práticas
│       ├── angular-best-practices.md
│       ├── react-best-practices.md
│       └── ...
├── install.sh             # Instalador/verificador
├── test.sh                # Teste da instalação  
├── chatmode.sh            # Script helper para uso fácil
└── README.md              # Esta documentação
```

## ⚡ Comandos Rápidos

```bash
# Listar todos os chatmodes
./chatmode.sh list

# Abrir chatmode Angular no VS Code
./chatmode.sh open dev-angular

# Copiar chatmode DevOps para clipboard
./chatmode.sh copy infra

# Verificar instalação
./test.sh

# Reinstalar/verificar arquivos
./install.sh
```

---
**Aproveite seus contextos especializados! 🎯**
