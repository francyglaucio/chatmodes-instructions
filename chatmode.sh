#!/bin/bash

# ChatMode Helper - Utilitário para facilitar o uso dos ChatModes
# Abre arquivos, lista opções e copia conteúdo para a área de transferência

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

CHATMODES_DIR="$HOME/.vscode/.github/chatmodes"
INSTRUCTIONS_DIR="$HOME/.vscode/.github/instructions"

# Função para listar chatmodes
list_chatmodes() {
    print_colored $CYAN "📋 ChatModes disponíveis:"
    
    if [ -d "$CHATMODES_DIR" ]; then
        local i=1
        for file in "$CHATMODES_DIR"/*.md; do
            if [ -f "$file" ]; then
                local basename_file=$(basename "$file" .chatmode.md)
                local description=""
                
                case $basename_file in
                    "dev-angular") description="Angular 15+ - Standalone components, Signals" ;;
                    "dev-angular-legacy") description="Angular 8-14 - NgModules, ViewEngine/Ivy" ;;
                    "dev-react") description="React - Hooks, Context, Next.js" ;;
                    "dev-node") description="Node.js - Express, NestJS, APIs" ;;
                    "dev-java") description="Java - Spring Boot, microserviços" ;;
                    "dev-csharp") description="C#/.NET - ASP.NET Core, Entity Framework" ;;
                    "dev") description="Desenvolvedor - Contexto geral" ;;
                    "architect") description="Arquitetura - Design de sistemas, padrões" ;;
                    "infra") description="DevOps - Docker, Kubernetes, CI/CD" ;;
                    "qa-specialist") description="QA - Testes, automação, qualidade" ;;
                    *) description="Especialista" ;;
                esac
                
                printf "%2d. %-25s - %s\n" $i "$basename_file" "$description"
                ((i++))
            fi
        done
    else
        print_colored $RED "❌ Diretório de chatmodes não encontrado!"
        exit 1
    fi
}

# Função para abrir chatmode no VS Code
open_chatmode() {
    local chatmode="$1"
    local file="$CHATMODES_DIR/${chatmode}.chatmode.md"
    
    if [ -f "$file" ]; then
        print_colored $GREEN "📂 Abrindo: $chatmode"
        code "$file"
    else
        print_colored $RED "❌ ChatMode não encontrado: $chatmode"
        print_colored $BLUE "   Use: ./chatmode.sh list para ver opções disponíveis"
        exit 1
    fi
}

# Função para copiar chatmode para clipboard (se disponível)
copy_chatmode() {
    local chatmode="$1"
    local file="$CHATMODES_DIR/${chatmode}.chatmode.md"
    
    if [ -f "$file" ]; then
        if command -v xclip >/dev/null 2>&1; then
            cat "$file" | xclip -selection clipboard
            print_colored $GREEN "📋 Conteúdo copiado para a área de transferência!"
        elif command -v pbcopy >/dev/null 2>&1; then
            cat "$file" | pbcopy
            print_colored $GREEN "📋 Conteúdo copiado para a área de transferência!"
        else
            print_colored $YELLOW "⚠️  Comando de cópia não disponível (xclip/pbcopy)"
            print_colored $BLUE "   Arquivo aberto no VS Code para cópia manual"
            code "$file"
        fi
    else
        print_colored $RED "❌ ChatMode não encontrado: $chatmode"
        exit 1
    fi
}

# Função para mostrar ajuda
show_help() {
    print_colored $CYAN "ChatMode Helper - Utilitário para ChatModes"
    echo
    print_colored $YELLOW "Uso:"
    print_colored $BLUE "  ./chatmode.sh list                    - Lista todos os chatmodes"
    print_colored $BLUE "  ./chatmode.sh open <nome>             - Abre chatmode no VS Code"
    print_colored $BLUE "  ./chatmode.sh copy <nome>             - Copia chatmode para clipboard"
    print_colored $BLUE "  ./chatmode.sh help                    - Mostra esta ajuda"
    echo
    print_colored $YELLOW "Exemplos:"
    print_colored $BLUE "  ./chatmode.sh open dev-angular        - Abre especialista Angular"
    print_colored $BLUE "  ./chatmode.sh copy infra              - Copia especialista DevOps"
    echo
    print_colored $YELLOW "Localização dos arquivos:"
    print_colored $BLUE "  ChatModes: $CHATMODES_DIR"
    print_colored $BLUE "  Instructions: $INSTRUCTIONS_DIR"
}

# Menu principal
case "${1:-help}" in
    "list"|"ls")
        list_chatmodes
        ;;
    "open"|"edit")
        if [ -z "$2" ]; then
            print_colored $RED "❌ Especifique o nome do chatmode"
            print_colored $BLUE "   Exemplo: ./chatmode.sh open dev-angular"
            exit 1
        fi
        open_chatmode "$2"
        ;;
    "copy"|"cp")
        if [ -z "$2" ]; then
            print_colored $RED "❌ Especifique o nome do chatmode"
            print_colored $BLUE "   Exemplo: ./chatmode.sh copy dev-angular"
            exit 1
        fi
        copy_chatmode "$2"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_colored $RED "❌ Comando inválido: $1"
        echo
        show_help
        exit 1
        ;;
esac
