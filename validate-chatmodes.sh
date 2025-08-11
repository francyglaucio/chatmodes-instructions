#!/bin/bash

echo "🔍 Validando Chat Modes Globais..."
echo

# Verificar estrutura de diretórios
echo "📁 Estrutura de diretórios:"
if [ -d ~/.vscode/chatmodes ]; then
    echo "  ✅ ~/.vscode/chatmodes/ existe"
else
    echo "  ❌ ~/.vscode/chatmodes/ não encontrado"
    exit 1
fi

if [ -d ~/.vscode/instructions ]; then
    echo "  ✅ ~/.vscode/instructions/ existe"
else
    echo "  ❌ ~/.vscode/instructions/ não encontrado"
    exit 1
fi

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
