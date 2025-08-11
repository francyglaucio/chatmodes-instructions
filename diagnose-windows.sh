#!/bin/bash

# ChatModes System - Diagnóstico Windows
# =====================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║    ChatModes - Diagnóstico Windows    ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
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

# Detectar ambiente
detect_environment() {
    print_info "=== DETECÇÃO DE AMBIENTE ==="
    
    echo "OSTYPE: $OSTYPE"
    echo "SHELL: $SHELL"
    echo "PWD: $PWD"
    echo "HOME: $HOME"
    echo "USERPROFILE: $USERPROFILE"
    echo "APPDATA: $APPDATA"
    echo "PATH: $PATH"
    echo
}

# Verificar comandos
check_commands() {
    print_info "=== VERIFICAÇÃO DE COMANDOS ==="
    
    local commands=("curl" "code" "git" "bash" "sh")
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            local version=$($cmd --version 2>/dev/null | head -n1 || echo "Disponível")
            print_status "$cmd: $version"
        else
            print_error "$cmd: Não encontrado"
        fi
    done
    echo
}

# Verificar conectividade
check_connectivity() {
    print_info "=== VERIFICAÇÃO DE CONECTIVIDADE ==="
    
    local urls=(
        "https://github.com"
        "https://raw.githubusercontent.com"
        "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/README.md"
    )
    
    for url in "${urls[@]}"; do
        if curl -fsSL --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1; then
            print_status "$url"
        else
            print_error "$url"
        fi
    done
    echo
}

# Verificar diretórios
check_directories() {
    print_info "=== VERIFICAÇÃO DE DIRETÓRIOS ==="
    
    # Determinar diretório VS Code
    local vscode_dirs=()
    
    if [[ -n "$USERPROFILE" ]]; then
        vscode_dirs+=("$USERPROFILE/.vscode")
    fi
    
    if [[ -n "$HOME" ]]; then
        vscode_dirs+=("$HOME/.vscode")
    fi
    
    for dir in "${vscode_dirs[@]}"; do
        print_info "Verificando: $dir"
        
        if [[ -d "$dir" ]]; then
            print_status "Diretório existe"
            
            # Verificar subdiretorios
            local subdirs=("chatmodes" "instructions" "scripts")
            for subdir in "${subdirs[@]}"; do
                local full_path="$dir/$subdir"
                if [[ -d "$full_path" ]]; then
                    local count=$(find "$full_path" -type f 2>/dev/null | wc -l)
                    print_status "  $subdir: $count arquivos"
                else
                    print_warning "  $subdir: Não existe"
                fi
            done
        else
            print_warning "Diretório não existe"
        fi
        echo
    done
}

# Testar download individual
test_download() {
    print_info "=== TESTE DE DOWNLOAD ==="
    
    local test_url="https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main/README.md"
    local temp_file
    
    # Determinar arquivo temporário
    if [[ -n "$USERPROFILE" ]]; then
        temp_file="$USERPROFILE/chatmodes-test-download.tmp"
    else
        temp_file="/tmp/chatmodes-test-download.tmp"
    fi
    
    print_info "URL de teste: $test_url"
    print_info "Arquivo temporário: $temp_file"
    
    # Tentar diferentes métodos de download
    local methods=(
        "curl -fsSL"
        "curl -fsSL --insecure"
        "curl -L"
        "curl -L --insecure"
    )
    
    for method in "${methods[@]}"; do
        print_info "Testando: $method"
        
        if $method "$test_url" -o "$temp_file" 2>/dev/null; then
            if [[ -f "$temp_file" ]] && [[ -s "$temp_file" ]]; then
                local size=$(wc -c < "$temp_file" 2>/dev/null || echo "0")
                print_status "Sucesso - $size bytes baixados"
                rm -f "$temp_file" 2>/dev/null
                return 0
            else
                print_warning "Arquivo vazio ou não criado"
            fi
        else
            print_error "Falha no download"
        fi
        
        rm -f "$temp_file" 2>/dev/null
    done
    
    print_error "Todos os métodos de download falharam"
    return 1
}

# Verificar permissões
check_permissions() {
    print_info "=== VERIFICAÇÃO DE PERMISSÕES ==="
    
    local test_dirs=()
    
    if [[ -n "$USERPROFILE" ]]; then
        test_dirs+=("$USERPROFILE")
    fi
    
    if [[ -n "$HOME" ]]; then
        test_dirs+=("$HOME")
    fi
    
    test_dirs+=("$PWD")
    
    for dir in "${test_dirs[@]}"; do
        print_info "Testando permissões em: $dir"
        
        local test_file="$dir/chatmodes-permission-test.tmp"
        
        if echo "teste" > "$test_file" 2>/dev/null; then
            print_status "Escrita: OK"
            rm -f "$test_file" 2>/dev/null
        else
            print_error "Escrita: FALHA"
        fi
        
        if mkdir -p "$dir/chatmodes-test-dir" 2>/dev/null; then
            print_status "Criação de diretório: OK"
            rmdir "$dir/chatmodes-test-dir" 2>/dev/null
        else
            print_error "Criação de diretório: FALHA"
        fi
    done
    echo
}

# Sugestões de correção
show_suggestions() {
    print_info "=== SUGESTÕES DE CORREÇÃO ==="
    
    echo "Se houver problemas de download:"
    echo "1. Verifique a conexão com a internet"
    echo "2. Tente executar o script como administrador"
    echo "3. Use o instalador PowerShell: install-windows.ps1"
    echo "4. Instale o Git for Windows para ter curl"
    echo ""
    
    echo "Se houver problemas de permissão:"
    echo "1. Execute o Git Bash como administrador"
    echo "2. Verifique as permissões da pasta do usuário"
    echo "3. Tente instalar em um diretório diferente"
    echo ""
    
    echo "Para instalação manual:"
    echo "1. Crie os diretórios: ~/.vscode/chatmodes, ~/.vscode/instructions, ~/.vscode/scripts"
    echo "2. Baixe os arquivos manualmente do GitHub"
    echo "3. Coloque cada arquivo no diretório correspondente"
    echo ""
    
    echo "Links úteis:"
    echo "- VS Code: https://code.visualstudio.com/"
    echo "- Git for Windows: https://git-scm.com/download/win"
    echo "- Repositório: https://github.com/francyglaucio/chatmodes-instructions"
    echo ""
}

# Função principal
main() {
    print_header
    print_info "Executando diagnóstico do sistema..."
    echo
    
    detect_environment
    check_commands
    check_connectivity
    check_directories
    test_download
    check_permissions
    show_suggestions
    
    print_info "Diagnóstico concluído!"
    echo
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
