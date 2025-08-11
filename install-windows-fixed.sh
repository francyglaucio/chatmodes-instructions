#!/bin/bash

# ChatModes System - Instalador Automático v1.1
# ==============================================
# Versão corrigida para Windows

set -e  # Exit on any error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para output colorido
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

print_header() {
    echo -e "${BLUE}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║    ChatModes System Installer v1.1    ║"
    echo "  ║         (Windows Fixed)               ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Detectar sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_info "Sistema detectado: Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Sistema detectado: macOS"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
        print_info "Sistema detectado: Windows"
    else
        OS="unknown"
        print_warning "Sistema não identificado: $OSTYPE"
    fi
}

# Verificar pré-requisitos
check_prerequisites() {
    print_info "Verificando pré-requisitos..."
    
    # Verificar se VS Code está instalado
    if command -v code &> /dev/null; then
        print_status "VS Code encontrado"
        code_version=$(code --version 2>/dev/null | head -n1 || echo "Versão não detectada")
        print_info "Versão: $code_version"
    else
        print_error "VS Code não encontrado. Por favor, instale o VS Code primeiro."
        print_info "Download: https://code.visualstudio.com/"
        exit 1
    fi
    
    # Verificar se curl está instalado
    if command -v curl &> /dev/null; then
        print_status "curl encontrado"
        curl_version=$(curl --version 2>/dev/null | head -n1 || echo "curl disponível")
        print_info "$curl_version"
    else
        print_error "curl não encontrado. Por favor, instale curl."
        if [[ "$OS" == "windows" ]]; then
            print_info "No Windows, instale o Git Bash ou WSL que incluem curl"
        fi
        exit 1
    fi
    
    # Verificar se git está instalado (opcional)
    if command -v git &> /dev/null; then
        print_status "Git encontrado"
    else
        print_warning "Git não encontrado. Algumas funcionalidades podem não funcionar."
    fi
}

# Criar estrutura de diretórios
create_directories() {
    print_info "Criando estrutura de diretórios..."
    
    # Determinar diretório base do VS Code baseado no OS
    if [[ "$OS" == "windows" ]]; then
        # No Windows, usar USERPROFILE se MSYS/Cygwin
        if [[ -n "$USERPROFILE" ]]; then
            VSCODE_DIR="$USERPROFILE/.vscode"
        else
            # Fallback para HOME se disponível
            VSCODE_DIR="$HOME/.vscode"
        fi
    else
        VSCODE_DIR="$HOME/.vscode"
    fi
    
    print_info "Diretório de destino: $VSCODE_DIR"
    
    # Criar diretórios com verificação
    if mkdir -p "$VSCODE_DIR/chatmodes" 2>/dev/null; then
        print_status "Diretório chatmodes criado"
    else
        print_error "Falha ao criar diretório chatmodes"
        exit 1
    fi
    
    if mkdir -p "$VSCODE_DIR/instructions" 2>/dev/null; then
        print_status "Diretório instructions criado"
    else
        print_error "Falha ao criar diretório instructions"
        exit 1
    fi
    
    if mkdir -p "$VSCODE_DIR/scripts" 2>/dev/null; then
        print_status "Diretório scripts criado"
    else
        print_error "Falha ao criar diretório scripts"
        exit 1
    fi
    
    print_status "Estrutura de diretórios criada em: $VSCODE_DIR"
}

# Baixar um arquivo individual
download_single_file() {
    local url="$1"
    local output_file="$2"
    local description="$3"
    
    print_info "Baixando: $description"
    
    # Criar diretório do arquivo se necessário
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir" 2>/dev/null
    
    # Tentar baixar o arquivo com diferentes opções
    if curl -fsSL --retry 3 --retry-delay 1 --connect-timeout 10 --max-time 30 "$url" -o "$output_file" 2>/dev/null; then
        if [[ -f "$output_file" ]] && [[ -s "$output_file" ]]; then
            print_status "✓ $description"
            return 0
        else
            print_error "Arquivo baixado mas está vazio: $description"
            rm -f "$output_file" 2>/dev/null
            return 1
        fi
    else
        print_error "Falha ao baixar: $description"
        print_info "URL: $url"
        return 1
    fi
}

# Baixar arquivos do repositório
download_files() {
    print_info "Iniciando download dos arquivos..."
    
    local base_url="https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main"
    local success_count=0
    local total_count=0
    
    # Lista de arquivos para download - Chatmodes
    print_info "Baixando perfis de chatmode..."
    local chatmode_files=(
        "architect.chatmode.md"
        "dev-angular.chatmode.md"
        "dev-angular-legacy.chatmode.md"
        "dev-react.chatmode.md"
        "dev-java.chatmode.md"
        "dev-node.chatmode.md"
        "dev-csharp.chatmode.md"
        "dev.chatmode.md"
        "infra.chatmode.md"
        "qa-specialist.chatmode.md"
    )
    
    for file in "${chatmode_files[@]}"; do
        ((total_count++))
        if download_single_file "$base_url/chatmodes/$file" "$VSCODE_DIR/chatmodes/$file" "$file"; then
            ((success_count++))
        fi
    done
    
    # Lista de arquivos para download - Instructions
    print_info "Baixando arquivos de instruções..."
    local instruction_files=(
        "architecture-patterns.md"
        "angular-best-practices.md"
        "angular-legacy-best-practices.md"
        "angular-nestjs-practices.md"
        "react-best-practices.md"
        "java-best-practices.md"
        "nodejs-best-practices.md"
        "csharp-best-practices.md"
        "dev-best-practices.md"
        "infra-best-practices.md"
        "qa-best-practices.md"
    )
    
    for file in "${instruction_files[@]}"; do
        ((total_count++))
        if download_single_file "$base_url/instructions/$file" "$VSCODE_DIR/instructions/$file" "$file"; then
            ((success_count++))
        fi
    done
    
    # Lista de arquivos para download - Scripts (opcionais)
    print_info "Baixando scripts utilitários..."
    local script_files=(
        "test-angular-nestjs.sh"
        "validate-chatmodes.sh"
    )
    
    for file in "${script_files[@]}"; do
        ((total_count++))
        if download_single_file "$base_url/$file" "$VSCODE_DIR/scripts/$file" "$file"; then
            ((success_count++))
            # Tornar script executável (exceto Windows)
            if [[ "$OS" != "windows" ]]; then
                chmod +x "$VSCODE_DIR/scripts/$file" 2>/dev/null
            fi
        fi
    done
    
    # Baixar documentação adicional
    print_info "Baixando documentação..."
    local doc_files=(
        "INSTALL-GUIDE.md"
        "README.md"
    )
    
    for file in "${doc_files[@]}"; do
        ((total_count++))
        if download_single_file "$base_url/$file" "$VSCODE_DIR/$file" "$file"; then
            ((success_count++))
        fi
    done
    
    print_info "Download concluído: $success_count/$total_count arquivos baixados com sucesso"
    
    if [[ $success_count -lt 15 ]]; then
        print_warning "Alguns arquivos não foram baixados. Verificando conectividade..."
        if ! curl -fsSL --connect-timeout 5 "https://github.com" >/dev/null 2>&1; then
            print_error "Problema de conectividade detectado"
            return 1
        fi
    fi
    
    return 0
}

# Configurar VS Code
configure_vscode() {
    print_info "Configurando VS Code..."
    
    # Determinar arquivo de configuração baseado no OS
    if [[ "$OS" == "windows" ]]; then
        if [[ -n "$APPDATA" ]]; then
            settings_dir="$APPDATA/Code/User"
        else
            settings_dir="$HOME/AppData/Roaming/Code/User"
        fi
    elif [[ "$OS" == "macos" ]]; then
        settings_dir="$HOME/Library/Application Support/Code/User"
    else
        settings_dir="$HOME/.config/Code/User"
    fi
    
    local settings_file="$settings_dir/settings.json"
    print_info "Arquivo de configuração: $settings_file"
    
    # Criar diretório se não existir
    if mkdir -p "$settings_dir" 2>/dev/null; then
        print_status "Diretório de configuração criado/verificado"
    else
        print_warning "Não foi possível criar diretório de configuração"
        return 1
    fi
    
    # Backup do arquivo existente
    if [[ -f "$settings_file" ]]; then
        local backup_file="$settings_file.backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$settings_file" "$backup_file" 2>/dev/null; then
            print_info "Backup criado: $backup_file"
        fi
    fi
    
    # Configurações para adicionar
    local chatmode_settings='{
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
}'
    
    # Se settings.json não existir, criar novo
    if [[ ! -f "$settings_file" ]]; then
        if echo "$chatmode_settings" > "$settings_file" 2>/dev/null; then
            print_status "Arquivo settings.json criado"
        else
            print_warning "Não foi possível criar settings.json"
        fi
    else
        print_warning "settings.json já existe. Configure manualmente as opções do ChatModes."
        local recommended_file="$VSCODE_DIR/recommended-settings.json"
        if echo "$chatmode_settings" > "$recommended_file" 2>/dev/null; then
            print_info "Configurações recomendadas salvas em: $recommended_file"
        fi
    fi
}

# Validar instalação
validate_installation() {
    print_info "Validando instalação..."
    
    local chatmode_count=0
    local instruction_count=0
    local script_count=0
    
    # Contar chatmodes
    if [[ -d "$VSCODE_DIR/chatmodes" ]]; then
        chatmode_count=$(find "$VSCODE_DIR/chatmodes" -name "*.md" -type f 2>/dev/null | wc -l)
    fi
    
    # Contar instruções
    if [[ -d "$VSCODE_DIR/instructions" ]]; then
        instruction_count=$(find "$VSCODE_DIR/instructions" -name "*.md" -type f 2>/dev/null | wc -l)
    fi
    
    # Contar scripts
    if [[ -d "$VSCODE_DIR/scripts" ]]; then
        script_count=$(find "$VSCODE_DIR/scripts" -name "*.sh" -type f 2>/dev/null | wc -l)
    fi
    
    print_info "Arquivos encontrados:"
    print_info "  Chatmodes: $chatmode_count"
    print_info "  Instruções: $instruction_count"
    print_info "  Scripts: $script_count"
    
    # Verificar se temos o mínimo necessário
    if [[ $chatmode_count -ge 8 ]]; then
        print_status "Perfis de chatmode: $chatmode_count (✓)"
    else
        print_error "Poucos perfis de chatmode: $chatmode_count (esperado: 8+)"
        return 1
    fi
    
    if [[ $instruction_count -ge 8 ]]; then
        print_status "Arquivos de instruções: $instruction_count (✓)"
    else
        print_error "Poucas instruções: $instruction_count (esperado: 8+)"
        return 1
    fi
    
    return 0
}

# Criar atalhos úteis
create_shortcuts() {
    print_info "Criando atalhos úteis..."
    
    # Script para abrir chatmode
    local shortcut_script="$VSCODE_DIR/scripts/open-chatmode.sh"
    
    cat > "$shortcut_script" << 'EOF'
#!/bin/bash
# Script para abrir chatmode rapidamente

# Determinar diretório do VS Code
if [[ -n "$USERPROFILE" ]] && [[ -d "$USERPROFILE/.vscode" ]]; then
    VSCODE_DIR="$USERPROFILE/.vscode"
else
    VSCODE_DIR="$HOME/.vscode"
fi

if [ -z "$1" ]; then
    echo "Uso: $0 <perfil>"
    echo ""
    echo "Perfis disponíveis:"
    if [[ -d "$VSCODE_DIR/chatmodes" ]]; then
        find "$VSCODE_DIR/chatmodes" -name "*.chatmode.md" -type f 2>/dev/null | while read -r file; do
            basename "$file" .chatmode.md
        done | sort
    else
        echo "  Nenhum perfil encontrado em $VSCODE_DIR/chatmodes"
    fi
    exit 1
fi

profile="$1"
file="$VSCODE_DIR/chatmodes/${profile}.chatmode.md"

if [ -f "$file" ]; then
    echo "Abrindo perfil: $profile"
    code "$file"
else
    echo "Perfil não encontrado: $profile"
    echo ""
    echo "Perfis disponíveis:"
    find "$VSCODE_DIR/chatmodes" -name "*.chatmode.md" -type f 2>/dev/null | while read -r file; do
        basename "$file" .chatmode.md
    done | sort
fi
EOF
    
    # Tornar executável (exceto Windows)
    if [[ "$OS" != "windows" ]]; then
        chmod +x "$shortcut_script" 2>/dev/null
    fi
    
    print_status "Script de atalho criado: $shortcut_script"
    
    # Instruções para adicionar ao PATH
    print_info "Para usar globalmente:"
    if [[ "$OS" == "windows" ]]; then
        print_info "  No Git Bash: export PATH=\"\$PATH:$VSCODE_DIR/scripts\""
    else
        print_info "  export PATH=\"\$PATH:$VSCODE_DIR/scripts\""
    fi
}

# Mostrar informações finais
show_completion_info() {
    print_header
    print_status "Instalação concluída com sucesso!"
    echo
    print_info "📁 Local de instalação: $VSCODE_DIR"
    
    # Contar arquivos instalados
    local chatmode_count=$(find "$VSCODE_DIR/chatmodes" -name "*.md" -type f 2>/dev/null | wc -l)
    local instruction_count=$(find "$VSCODE_DIR/instructions" -name "*.md" -type f 2>/dev/null | wc -l)
    
    print_info "📚 Perfis instalados: $chatmode_count"
    print_info "📖 Instruções instaladas: $instruction_count"
    echo
    print_info "🚀 Como usar:"
    echo "   1. Abra VS Code"
    echo "   2. Teste um perfil:"
    if [[ "$OS" == "windows" ]]; then
        echo "      code \"$VSCODE_DIR/chatmodes/dev-angular.chatmode.md\""
    else
        echo "      code ~/.vscode/chatmodes/dev-angular.chatmode.md"
    fi
    echo "   3. Leia o guia:"
    if [[ "$OS" == "windows" ]]; then
        echo "      code \"$VSCODE_DIR/INSTALL-GUIDE.md\""
    else
        echo "      code ~/.vscode/INSTALL-GUIDE.md"
    fi
    echo
    print_info "📘 Documentação completa disponível em INSTALL-GUIDE.md"
    echo
    print_info "💡 Dica: Copie o conteúdo de um perfil e cole no seu AI Assistant!"
    echo
}

# Função principal
main() {
    print_header
    
    print_info "Iniciando instalação do ChatModes System..."
    echo
    
    # Verificar se o usuário quer continuar
    read -p "Continuar com a instalação? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Instalação cancelada pelo usuário."
        exit 0
    fi
    
    echo
    detect_os
    check_prerequisites
    create_directories
    
    if download_files; then
        print_status "Download concluído com sucesso"
    else
        print_error "Falha no download de alguns arquivos"
        print_info "Tentando continuar com os arquivos baixados..."
    fi
    
    configure_vscode
    
    if validate_installation; then
        create_shortcuts
        show_completion_info
        exit 0
    else
        print_error "Instalação incompleta - alguns arquivos podem estar faltando"
        print_info "Tente executar o instalador novamente ou instale manualmente"
        exit 1
    fi
}

# Verificar se está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
