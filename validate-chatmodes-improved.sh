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

# Função para verificar perfis obrigatórios
check_required_profiles() {
    print_info "Verificando perfis obrigatórios..."
    
    local required_profiles=(
        "architect.chatmode.md"
        "dev-angular.chatmode.md"
        "dev-react.chatmode.md"
        "dev-java.chatmode.md"
        "dev-node.chatmode.md"
        "dev-csharp.chatmode.md"
        "infra.chatmode.md"
        "qa-specialist.chatmode.md"
    )
    
    for profile in "${required_profiles[@]}"; do
        if [ -f ~/.vscode/chatmodes/"$profile" ]; then
            print_success "✓ $profile"
        else
            print_error "✗ $profile não encontrado"
            ((total_errors++))
        fi
    done
}

# Função para verificar links
check_links() {
    print_info "Verificando links entre chatmodes e instruções..."
    
    for chatmode in ~/.vscode/chatmodes/*.md; do
        if [ -f "$chatmode" ]; then
            filename=$(basename "$chatmode")
            echo "🔗 Verificando $filename..."
            
            # Verificar se o chatmode tem pelo menos um link para instruções
            has_instruction_link=false
            
            # Extrair links para arquivos de instruções
            if grep -q '\[.*\](../instructions/.*\.md)' "$chatmode"; then
                has_instruction_link=true
                
                # Buscar por links específicos
                grep -o '\[.*\](../instructions/[^)]*\.md)' "$chatmode" | while read -r link; do
                    instruction_file=$(echo "$link" | sed 's/.*(\.\.\///g' | sed 's/).*//g' | sed 's/instructions\///g')
                    
                    if [ -f ~/.vscode/instructions/"$instruction_file" ]; then
                        echo "  ✅ Link válido: $instruction_file"
                    else
                        echo "  ❌ Link quebrado: $instruction_file"
                        ((broken_links++))
                        ((total_errors++))
                    fi
                done
            fi
            
            if [ "$has_instruction_link" = false ]; then
                print_warning "  Nenhum link para instruções encontrado em $filename"
                ((total_warnings++))
            fi
        fi
    done
}

# Função para mostrar estatísticas
show_statistics() {
    echo
    print_info "📊 Estatísticas dos arquivos:"
    
    local total_lines=0
    
    echo "📄 Perfis de ChatMode:"
    for file in ~/.vscode/chatmodes/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            lines=$(wc -l < "$file")
            total_lines=$((total_lines + lines))
            printf "   %-35s %5d linhas\n" "$filename" "$lines"
        fi
    done
    
    echo
    echo "📚 Arquivos de Instruções:"
    for file in ~/.vscode/instructions/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            lines=$(wc -l < "$file")
            total_lines=$((total_lines + lines))
            printf "   %-35s %5d linhas\n" "$filename" "$lines"
        fi
    done
    
    echo
    print_info "📈 Resumo:"
    echo "   Total de linhas de documentação: $total_lines"
    echo "   Perfis de chatmode: $(ls ~/.vscode/chatmodes/*.md 2>/dev/null | wc -l)"
    echo "   Arquivos de instruções: $(ls ~/.vscode/instructions/*.md 2>/dev/null | wc -l)"
    
    if [ -d ~/.vscode/scripts ]; then
        echo "   Scripts utilitários: $(ls ~/.vscode/scripts/*.sh 2>/dev/null | wc -l)"
    fi
}

# Função para mostrar relatório final
show_final_report() {
    echo
    print_header
    
    if [ $total_errors -eq 0 ] && [ $total_warnings -eq 0 ]; then
        print_success "🎯 Sistema ChatModes funcionando perfeitamente!"
        echo "   ✅ Todos os arquivos presentes"
        echo "   ✅ Todos os links funcionais"
        echo "   ✅ Estrutura correta"
    elif [ $total_errors -eq 0 ]; then
        print_warning "⚠️  Sistema ChatModes funcionando com avisos"
        echo "   ✅ Todos os arquivos essenciais presentes"
        echo "   ⚠️  $total_warnings aviso(s) encontrado(s)"
    else
        print_error "❌ Sistema ChatModes com problemas"
        echo "   ❌ $total_errors erro(s) encontrado(s)"
        echo "   ⚠️  $total_warnings aviso(s) encontrado(s)"
        echo
        print_info "Recomendação: Execute o instalador para corrigir problemas"
        return 1
    fi
    
    echo
    print_info "💡 Próximos passos:"
    echo "   1. Teste um perfil: code ~/.vscode/chatmodes/dev-angular.chatmode.md"
    echo "   2. Leia o guia: code ~/.vscode/INSTALL-GUIDE.md"
    echo "   3. Configure VS Code com as configurações recomendadas"
    
    return 0
}

# Função principal
main() {
    print_header
    
    check_directories || exit 1
    check_required_profiles
    check_links
    show_statistics
    
    show_final_report
}

# Verificar se está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
