#!/bin/bash

# Teste da instalação dos ChatModes
# Verifica se os arquivos foram copiados corretamente

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

clear
print_colored $CYAN "╔══════════════════════════════════════════════════════════════╗"
print_colored $CYAN "║                    ChatModes Tester                          ║"
print_colored $CYAN "║              Verificação da instalação                       ║"
print_colored $CYAN "╚══════════════════════════════════════════════════════════════╝"
echo

TARGET_DIR="$HOME/.vscode/.github"

print_colored $YELLOW "🔍 Verificando instalação em: $TARGET_DIR"

# Verificar chatmodes
if [ -d "$TARGET_DIR/chatmodes" ]; then
    CHATMODE_COUNT=$(ls -1 "$TARGET_DIR/chatmodes/"*.md 2>/dev/null | wc -l)
    print_colored $GREEN "✅ ChatModes encontrados: $CHATMODE_COUNT"
    
    echo
    print_colored $BLUE "📋 ChatModes instalados:"
    for file in "$TARGET_DIR/chatmodes/"*.md; do
        if [ -f "$file" ]; then
            basename "$file" | sed 's/^/   • /'
        fi
    done
else
    print_colored $RED "❌ Diretório chatmodes não encontrado"
fi

echo

# Verificar instructions
if [ -d "$TARGET_DIR/instructions" ]; then
    INSTRUCTION_COUNT=$(ls -1 "$TARGET_DIR/instructions/"*.md 2>/dev/null | wc -l)
    print_colored $GREEN "✅ Instructions encontradas: $INSTRUCTION_COUNT"
    
    echo
    print_colored $BLUE "📚 Instructions instaladas:"
    for file in "$TARGET_DIR/instructions/"*.md; do
        if [ -f "$file" ]; then
            basename "$file" | sed 's/^/   • /'
        fi
    done
else
    print_colored $RED "❌ Diretório instructions não encontrado"
fi

echo
print_colored $GREEN "╔══════════════════════════════════════════════════════════════╗"
print_colored $GREEN "║                      ✅ TESTE CONCLUÍDO!                      ║"
print_colored $GREEN "╚══════════════════════════════════════════════════════════════╝"

echo
print_colored $YELLOW "📋 Para usar:"
print_colored $BLUE "1. Navegue até: $TARGET_DIR/chatmodes/"
print_colored $BLUE "2. Abra o arquivo .chatmode.md desejado"
print_colored $BLUE "3. Copie todo o conteúdo"
print_colored $BLUE "4. Cole no ChatGPT/Copilot e faça sua pergunta"

echo
read -p "Pressione Enter para finalizar..."
