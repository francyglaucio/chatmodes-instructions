#!/bin/bash

# ChatModes System - Script de Validação
# ======================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para output colorido
print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "🔍 Validação do Sistema ChatModes"
    echo "================================"
    echo -e "${NC}"
}

# Contadores globais
total_errors=0
total_warnings=0
broken_links=0

# Função para verificar diretórios
check_directories() {
    print_info "Verificando estrutura de diretórios..."
    
    if [ -d ~/.vscode/chatmodes ]; then
        print_success "Diretório chatmodes encontrado"
        chatmode_count=$(ls ~/.vscode/chatmodes/*.md 2>/dev/null | wc -l)
        print_info "📁 $chatmode_count arquivos de chatmode encontrados"
        
        if [ $chatmode_count -lt 9 ]; then
            print_warning "Esperado pelo menos 9 perfis de chatmode"
            ((total_warnings++))
        fi
    else
        print_error "Diretório chatmodes não encontrado"
        ((total_errors++))
        return 1
    fi

    if [ -d ~/.vscode/instructions ]; then
        print_success "Diretório instructions encontrado"
        instruction_count=$(ls ~/.vscode/instructions/*.md 2>/dev/null | wc -l)
        print_info "📁 $instruction_count arquivos de instruções encontrados"
        
        if [ $instruction_count -lt 10 ]; then
            print_warning "Esperado pelo menos 10 arquivos de instruções"
            ((total_warnings++))
        fi
    else
        print_error "Diretório instructions não encontrado"
        ((total_errors++))
        return 1
    fi
    
    # Verificar diretório scripts (opcional)
    if [ -d ~/.vscode/scripts ]; then
        print_success "Diretório scripts encontrado"
        script_count=$(ls ~/.vscode/scripts/*.sh 2>/dev/null | wc -l)
        print_info "📁 $script_count scripts utilitários encontrados"
    else
        print_warning "Diretório scripts não encontrado (opcional)"
    fi
}

echo

# Verificar chat modes
echo "🎯 Chat Modes disponíveis:"
for chatmode in infra dev architect; do
    file="$HOME/.vscode/chatmodes/${chatmode}.chatmode.md"
    if [ -f "$file" ]; then
        echo "  ✅ $chatmode.chatmode.md ($(wc -l < "$file") linhas)"
    else
        echo "  ❌ $chatmode.chatmode.md não encontrado"
    fi
done

echo

# Verificar instruções
echo "📚 Instruções complementares:"
for instruction in infra-best-practices dev-best-practices architecture-patterns; do
    file="$HOME/.vscode/instructions/${instruction}.md"
    if [ -f "$file" ]; then
        echo "  ✅ $instruction.md ($(wc -l < "$file") linhas)"
    else
        echo "  ❌ $instruction.md não encontrado"
    fi
done

echo

# Verificar sintaxe YAML dos front matters
echo "🔧 Validando sintaxe dos chat modes:"
for chatmode in infra dev architect; do
    file="$HOME/.vscode/chatmodes/${chatmode}.chatmode.md"
    if [ -f "$file" ]; then
        # Extrair front matter (entre as linhas ---)
        front_matter=$(sed -n '/^---$/,/^---$/p' "$file" | head -n -1 | tail -n +2)
        if echo "$front_matter" | python3 -c "import sys, yaml; yaml.safe_load(sys.stdin)" 2>/dev/null; then
            echo "  ✅ $chatmode: YAML válido"
        else
            echo "  ❌ $chatmode: YAML inválido"
        fi
    fi
done

echo
echo "🎉 Validação concluída!"
echo
echo "📋 Para usar os chat modes:"
echo "  1. Abra o VS Code"
echo "  2. Abra o Chat (Ctrl+Alt+I)"
echo "  3. Selecione 'infra', 'dev' ou 'architect' no dropdown"
echo
