#!/bin/bash

# ChatModes System - Instalador Automático
# ========================================

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
    echo "  ║        ChatModes System Installer     ║"
    echo "  ║              v1.0.0                   ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Detectar sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    print_info "Sistema detectado: $OS"
}

# Verificar pré-requisitos
check_prerequisites() {
    print_info "Verificando pré-requisitos..."
    
    # Verificar se VS Code está instalado
    if command -v code &> /dev/null; then
        print_status "VS Code encontrado"
        code_version=$(code --version | head -n1)
        print_info "Versão: $code_version"
    else
        print_error "VS Code não encontrado. Por favor, instale o VS Code primeiro."
        exit 1
    fi
    
    # Verificar se git está instalado
    if command -v git &> /dev/null; then
        print_status "Git encontrado"
    else
        print_warning "Git não encontrado. Algumas funcionalidades podem não funcionar."
    fi
    
    # Verificar se curl está instalado
    if command -v curl &> /dev/null; then
        print_status "curl encontrado"
    else
        print_error "curl não encontrado. Por favor, instale curl."
        exit 1
    fi
}

# Criar estrutura de diretórios
create_directories() {
    print_info "Criando estrutura de diretórios..."
    
    # Determinar diretório base do VS Code
    if [[ "$OS" == "windows" ]]; then
        VSCODE_DIR="$USERPROFILE/.vscode"
    else
        VSCODE_DIR="$HOME/.vscode"
    fi
    
    # Criar diretórios
    mkdir -p "$VSCODE_DIR/chatmodes"
    mkdir -p "$VSCODE_DIR/instructions"
    mkdir -p "$VSCODE_DIR/scripts"
    
    print_status "Diretórios criados em: $VSCODE_DIR"
}

# Baixar arquivos do repositório
download_files() {
    print_info "Baixando arquivos do repositório..."
    
    local base_url="https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main"
    local temp_dir="/tmp/chatmodes-install"
    
    # Criar diretório temporário
    mkdir -p "$temp_dir"
    
    # Lista de arquivos para download
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
    
    local script_files=(
        "test-angular-nestjs.sh"
        "validate-chatmodes.sh"
    )
    
    # Baixar chatmodes
    print_info "Baixando perfis de chatmode..."
    for file in "${chatmode_files[@]}"; do
        if curl -sL "$base_url/chatmodes/$file" -o "$temp_dir/$file"; then
            print_status "✓ $file"
        else
            print_error "Falha ao baixar $file"
        fi
    done
    
    # Baixar instruções
    print_info "Baixando arquivos de instruções..."
    for file in "${instruction_files[@]}"; do
        if curl -sL "$base_url/instructions/$file" -o "$temp_dir/$file"; then
            print_status "✓ $file"
        else
            print_error "Falha ao baixar $file"
        fi
    done
    
    # Baixar scripts
    print_info "Baixando scripts utilitários..."
    for file in "${script_files[@]}"; do
        if curl -sL "$base_url/$file" -o "$temp_dir/$file"; then
            print_status "✓ $file"
        else
            print_warning "Falha ao baixar $file (opcional)"
        fi
    done
    
    echo "$temp_dir"
}

# Instalar arquivos
install_files() {
    local temp_dir="$1"
    print_info "Instalando arquivos..."
    
    # Copiar chatmodes
    if ls "$temp_dir"/*.chatmode.md 1> /dev/null 2>&1; then
        cp "$temp_dir"/*.chatmode.md "$VSCODE_DIR/chatmodes/"
        print_status "Perfis de chatmode instalados"
    fi
    
    # Copiar instruções (arquivos .md que não são chatmodes)
    for file in "$temp_dir"/*.md; do
        if [[ ! "$file" == *.chatmode.md ]]; then
            cp "$file" "$VSCODE_DIR/instructions/"
        fi
    done
    print_status "Arquivos de instruções instalados"
    
    # Copiar scripts
    if ls "$temp_dir"/*.sh 1> /dev/null 2>&1; then
        cp "$temp_dir"/*.sh "$VSCODE_DIR/scripts/"
        # Tornar scripts executáveis
        if [[ "$OS" != "windows" ]]; then
            chmod +x "$VSCODE_DIR/scripts"/*.sh
        fi
        print_status "Scripts utilitários instalados"
    fi
}

# Configurar VS Code
configure_vscode() {
    print_info "Configurando VS Code..."
    
    # Determinar arquivo de configuração
    if [[ "$OS" == "windows" ]]; then
        settings_dir="$APPDATA/Code/User"
    elif [[ "$OS" == "macos" ]]; then
        settings_dir="$HOME/Library/Application Support/Code/User"
    else
        settings_dir="$HOME/.config/Code/User"
    fi
    
    local settings_file="$settings_dir/settings.json"
    
    # Criar diretório se não existir
    mkdir -p "$settings_dir"
    
    # Backup do arquivo existente
    if [[ -f "$settings_file" ]]; then
        cp "$settings_file" "$settings_file.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backup criado: $settings_file.backup.*"
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
  }
}'
    
    # Se settings.json não existir, criar novo
    if [[ ! -f "$settings_file" ]]; then
        echo "$chatmode_settings" > "$settings_file"
        print_status "Arquivo settings.json criado"
    else
        print_warning "settings.json existente. Configure manualmente as opções do ChatModes."
        print_info "Configurações recomendadas salvas em: $VSCODE_DIR/recommended-settings.json"
        echo "$chatmode_settings" > "$VSCODE_DIR/recommended-settings.json"
    fi
}

# Validar instalação
validate_installation() {
    print_info "Validando instalação..."
    
    local chatmode_count=$(ls "$VSCODE_DIR/chatmodes"/*.md 2>/dev/null | wc -l)
    local instruction_count=$(ls "$VSCODE_DIR/instructions"/*.md 2>/dev/null | wc -l)
    
    if [[ $chatmode_count -ge 9 ]]; then
        print_status "$chatmode_count perfis de chatmode instalados"
    else
        print_error "Apenas $chatmode_count perfis encontrados (esperado: 9+)"
        return 1
    fi
    
    if [[ $instruction_count -ge 10 ]]; then
        print_status "$instruction_count arquivos de instruções instalados"
    else
        print_error "Apenas $instruction_count instruções encontradas (esperado: 10+)"
        return 1
    fi
    
    # Executar script de validação se disponível
    if [[ -f "$VSCODE_DIR/scripts/validate-chatmodes.sh" ]]; then
        print_info "Executando validação completa..."
        if bash "$VSCODE_DIR/scripts/validate-chatmodes.sh"; then
            print_status "Validação completa bem-sucedida"
        else
            print_warning "Validação completa com avisos"
        fi
    fi
    
    return 0
}

# Criar atalhos úteis
create_shortcuts() {
    print_info "Criando atalhos úteis..."
    
    # Script para abrir chatmode
    cat > "$VSCODE_DIR/scripts/open-chatmode.sh" << 'EOF'
#!/bin/bash
# Script para abrir chatmode rapidamente

if [ -z "$1" ]; then
    echo "Uso: $0 <perfil>"
    echo "Perfis disponíveis:"
    ls ~/.vscode/chatmodes/*.chatmode.md | xargs -n 1 basename | sed 's/.chatmode.md//'
    exit 1
fi

profile="$1"
file="$HOME/.vscode/chatmodes/${profile}.chatmode.md"

if [ -f "$file" ]; then
    code "$file"
else
    echo "Perfil não encontrado: $profile"
    echo "Perfis disponíveis:"
    ls ~/.vscode/chatmodes/*.chatmode.md | xargs -n 1 basename | sed 's/.chatmode.md//'
fi
EOF
    
    chmod +x "$VSCODE_DIR/scripts/open-chatmode.sh" 2>/dev/null
    
    # Adicionar ao PATH se possível
    if [[ ":$PATH:" != *":$VSCODE_DIR/scripts:"* ]]; then
        print_info "Para usar o comando 'open-chatmode', adicione ao seu PATH:"
        print_info "export PATH=\"\$PATH:$VSCODE_DIR/scripts\""
    fi
}

# Mostrar informações finais
show_completion_info() {
    print_header
    print_status "Instalação concluída com sucesso!"
    echo
    print_info "📁 Arquivos instalados em: $VSCODE_DIR"
    print_info "📚 Perfis disponíveis: $(ls "$VSCODE_DIR/chatmodes"/*.md 2>/dev/null | wc -l)"
    print_info "📖 Instruções disponíveis: $(ls "$VSCODE_DIR/instructions"/*.md 2>/dev/null | wc -l)"
    echo
    print_info "🚀 Próximos passos:"
    echo "   1. Abra VS Code: code"
    echo "   2. Teste um perfil: code ~/.vscode/chatmodes/dev-angular.chatmode.md"
    echo "   3. Valide o sistema: ~/.vscode/scripts/validate-chatmodes.sh"
    echo "   4. Leia o guia: code ~/.vscode/INSTALL-GUIDE.md"
    echo
    print_info "📘 Documentação completa disponível em INSTALL-GUIDE.md"
    echo
}

# Função principal
main() {
    print_header
    
    print_info "Iniciando instalação do ChatModes System..."
    
    # Verificar se o usuário quer continuar
    read -p "Continuar com a instalação? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Instalação cancelada."
        exit 0
    fi
    
    detect_os
    check_prerequisites
    create_directories
    
    local temp_dir
    temp_dir=$(download_files)
    
    install_files "$temp_dir"
    configure_vscode
    
    if validate_installation; then
        create_shortcuts
        show_completion_info
        
        # Limpeza
        rm -rf "$temp_dir"
        
        exit 0
    else
        print_error "Instalação falhou na validação"
        exit 1
    fi
}

# Verificar se está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
