#!/bin/bash

# Instalador de ChatModes Globais
# Copia os chatmodes e instructions para uso global no VS Code

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

# Banner
clear
print_colored $CYAN "╔══════════════════════════════════════════════════════════════╗"
print_colored $CYAN "║                    ChatModes Installer                       ║"
print_colored $CYAN "║              Instalador de contextos globais                 ║"
print_colored $CYAN "╚══════════════════════════════════════════════════════════════╝"
echo

# Detectar sistema operacional
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    TARGET_DIR="$HOME/.vscode"
    print_colored $BLUE "🍎 Sistema detectado: macOS"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows
    TARGET_DIR="$HOME/.vscode"
    print_colored $BLUE "🪟 Sistema detectado: Windows"
elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    # WSL
    TARGET_DIR="$HOME/.vscode"
    print_colored $BLUE "🐧 Sistema detectado: WSL (Windows Subsystem for Linux)"
else
    # Linux
    TARGET_DIR="$HOME/.vscode"
    print_colored $BLUE "🐧 Sistema detectado: Linux"
fi

print_colored $YELLOW "📁 Diretório de instalação: $TARGET_DIR"

# Criar diretórios de destino
mkdir -p "$TARGET_DIR/.github/chatmodes"
mkdir -p "$TARGET_DIR/.github/instructions"

print_colored $YELLOW "📋 Copiando ChatModes..."

# Verificar se os arquivos de origem existem
SOURCE_DIR="/home/glaucio/.vscode/.github"

if [ ! -d "$SOURCE_DIR/chatmodes" ]; then
    print_colored $RED "❌ Diretório de origem não encontrado: $SOURCE_DIR/chatmodes"
    print_colored $BLUE "   Execute este script a partir do diretório do projeto"
    exit 1
fi

# Copiar chatmodes
cp -r "$SOURCE_DIR/chatmodes/"* "$TARGET_DIR/.github/chatmodes/" 2>/dev/null
CHATMODE_COUNT=$(ls -1 "$TARGET_DIR/.github/chatmodes/"*.md 2>/dev/null | wc -l)
print_colored $GREEN "✅ $CHATMODE_COUNT chatmodes copiados"

# Copiar instructions
cp -r "$SOURCE_DIR/instructions/"* "$TARGET_DIR/.github/instructions/" 2>/dev/null
INSTRUCTION_COUNT=$(ls -1 "$TARGET_DIR/.github/instructions/"*.md 2>/dev/null | wc -l)
print_colored $GREEN "✅ $INSTRUCTION_COUNT instructions copiadas"

echo
print_colored $GREEN "╔══════════════════════════════════════════════════════════════╗"
print_colored $GREEN "║                    ✅ INSTALAÇÃO CONCLUÍDA!                   ║"
print_colored $GREEN "╚══════════════════════════════════════════════════════════════╝"

echo
print_colored $CYAN "🎯 ChatModes disponíveis:"
print_colored $BLUE "   • dev-angular.chatmode.md     - Especialista Angular 15+"
print_colored $BLUE "   • dev-angular-legacy.chatmode.md - Especialista Angular 8-14"
print_colored $BLUE "   • dev-react.chatmode.md       - Especialista React"
print_colored $BLUE "   • dev-node.chatmode.md        - Especialista Node.js/NestJS"
print_colored $BLUE "   • dev-java.chatmode.md        - Especialista Java/Spring"
print_colored $BLUE "   • dev-csharp.chatmode.md      - Especialista C#/.NET"
print_colored $BLUE "   • architect.chatmode.md       - Arquiteto de Soluções"
print_colored $BLUE "   • infra.chatmode.md           - Especialista DevOps"
print_colored $BLUE "   • qa-specialist.chatmode.md   - Especialista QA"

echo
print_colored $YELLOW "📋 Como usar:"
print_colored $BLUE "1. Abra um arquivo .chatmode.md em: $TARGET_DIR/.github/chatmodes/"
print_colored $BLUE "2. Copie o conteúdo do arquivo"
print_colored $BLUE "3. Cole no chat do GitHub Copilot ou ChatGPT"
print_colored $BLUE "4. Faça sua pergunta específica"

echo
print_colored $YELLOW "📚 Documentação de apoio em: $TARGET_DIR/.github/instructions/"

echo
read -p "Pressione Enter para finalizar..."
