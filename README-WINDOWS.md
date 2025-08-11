# ChatModes System - Instalação para Windows

## Problema Identificado

O script de instalação original não estava funcionando corretamente no Windows devido a:

1. **Problemas de paths**: Diferenças entre caminhos Unix e Windows
2. **Diretórios temporários**: Uso de `/tmp` que não existe no Windows
3. **Comandos curl**: Flags e opções incompatíveis
4. **Permissões**: Diferenças de sistema de arquivos

## Soluções Disponíveis

### 🥇 Método 1: PowerShell (RECOMENDADO)

Mais confiável para Windows, usa APIs nativas:

```powershell
# Execute no PowerShell como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install-windows.ps1
```

### 🥈 Método 2: Git Bash (Script corrigido)

Use o script bash corrigido:

```bash
# Execute no Git Bash
./install.sh
```

### 🥉 Método 3: Instalador Batch

Execute o arquivo `.bat` que oferece menu de opções:

```cmd
install-windows.bat
```

### 🔧 Método 4: Diagnóstico

Se estiver com problemas, execute o diagnóstico:

```bash
# No Git Bash
./diagnose-windows.sh
```

## Pré-requisitos

### Essenciais
- ✅ **VS Code** instalado ([Download](https://code.visualstudio.com/))
- ✅ **PowerShell 5.0+** (incluído no Windows 10+)

### Para Git Bash (Método 2)
- ✅ **Git for Windows** ([Download](https://git-scm.com/download/win))

## Processo de Instalação Detalhado

### PowerShell (Método Recomendado)

1. **Abra o PowerShell como Administrador**
   - Tecle `Win + X`
   - Escolha "Windows PowerShell (Admin)"

2. **Configure a política de execução**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Navegue até o diretório dos scripts**
   ```powershell
   cd "C:\caminho\para\os\scripts"
   ```

4. **Execute o instalador**
   ```powershell
   .\install-windows.ps1
   ```

### Git Bash (Método Alternativo)

1. **Instale o Git for Windows**
   - Download: https://git-scm.com/download/win
   - Instale com as opções padrão

2. **Abra o Git Bash como Administrador**
   - Clique direito no Git Bash
   - "Executar como administrador"

3. **Execute o script corrigido**
   ```bash
   ./install.sh
   ```

## Estrutura de Arquivos no Windows

Após a instalação, os arquivos estarão em:

```
C:\Users\[SeuUsuario]\.vscode\
├── chatmodes\
│   ├── architect.chatmode.md
│   ├── dev-angular.chatmode.md
│   ├── dev-angular-legacy.chatmode.md
│   ├── dev-react.chatmode.md
│   ├── dev-java.chatmode.md
│   ├── dev-node.chatmode.md
│   ├── dev-csharp.chatmode.md
│   ├── infra.chatmode.md
│   └── qa-specialist.chatmode.md
├── instructions\
│   ├── architecture-patterns.md
│   ├── angular-best-practices.md
│   ├── angular-legacy-best-practices.md
│   ├── angular-nestjs-practices.md
│   ├── react-best-practices.md
│   ├── java-best-practices.md
│   ├── nodejs-best-practices.md
│   ├── csharp-best-practices.md
│   ├── dev-best-practices.md
│   ├── infra-best-practices.md
│   └── qa-best-practices.md
├── scripts\
│   ├── open-chatmode.sh
│   ├── open-chatmode.ps1
│   ├── test-angular-nestjs.sh
│   └── validate-chatmodes.sh
├── INSTALL-GUIDE.md
└── README.md
```

## Configuração do VS Code

O instalador configurará automaticamente:

```json
{
  "chatmodes.enabled": true,
  "chatmodes.path": "~/.vscode/chatmodes",
  "chatmodes.instructions": "~/.vscode/instructions",
  "chatmodes.autoLoad": true,
  "files.associations": {
    "*.chatmode.md": "markdown"
  },
  "editor.quickSuggestions": {
    "strings": true,
    "comments": true,
    "other": true
  },
  "markdown.preview.breaks": true,
  "markdown.preview.linkify": true
}
```

## Como Usar Após Instalação

### 1. Abrir um Perfil

**Via VS Code:**
```cmd
code "%USERPROFILE%\.vscode\chatmodes\dev-angular.chatmode.md"
```

**Via PowerShell:**
```powershell
& "$env:USERPROFILE\.vscode\scripts\open-chatmode.ps1" "dev-angular"
```

### 2. Listar Perfis Disponíveis

**PowerShell:**
```powershell
Get-ChildItem "$env:USERPROFILE\.vscode\chatmodes" -Filter "*.chatmode.md" | ForEach-Object { $_.BaseName.Replace('.chatmode', '') }
```

**Git Bash:**
```bash
ls ~/.vscode/chatmodes/*.chatmode.md | xargs -n 1 basename | sed 's/.chatmode.md//'
```

## Solução de Problemas

### Erro: "Execution Policy"

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Erro: "curl not found"

- Instale o Git for Windows
- Ou use o método PowerShell

### Erro: "Permission denied"

- Execute como Administrador
- Verifique permissões da pasta do usuário

### Arquivos não baixam

1. Execute o diagnóstico:
   ```bash
   ./diagnose-windows.sh
   ```

2. Verifique conectividade:
   ```cmd
   ping github.com
   ```

3. Tente download manual:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/README.md" -OutFile "test.md"
   ```

### Instalação Manual

Se todos os métodos automáticos falharem:

1. **Crie os diretórios:**
   ```cmd
   mkdir "%USERPROFILE%\.vscode\chatmodes"
   mkdir "%USERPROFILE%\.vscode\instructions"
   mkdir "%USERPROFILE%\.vscode\scripts"
   ```

2. **Baixe os arquivos manualmente:**
   - Acesse: https://github.com/francyglaucio/chatmodes-instructions
   - Baixe cada arquivo e coloque na pasta correspondente

3. **Configure o VS Code manualmente:**
   - Abra VS Code
   - Vá em Settings (JSON)
   - Adicione as configurações acima

## Validação da Instalação

Execute um dos comandos para validar:

**PowerShell:**
```powershell
Get-ChildItem "$env:USERPROFILE\.vscode" -Recurse -Filter "*.md" | Measure-Object | Select-Object Count
```

**Git Bash:**
```bash
find ~/.vscode -name "*.md" | wc -l
```

Devem ser encontrados **20+ arquivos .md**.

## Suporte

Se continuar com problemas:

1. Execute o diagnóstico completo
2. Verifique os logs de erro
3. Tente a instalação manual
4. Reporte o problema com os detalhes do diagnóstico

## Links Úteis

- 📥 [VS Code Download](https://code.visualstudio.com/)
- 📥 [Git for Windows](https://git-scm.com/download/win)
- 📚 [Repositório GitHub](https://github.com/francyglaucio/chatmodes-instructions)
- 📖 [Documentação Completa](INSTALL-GUIDE.md)
