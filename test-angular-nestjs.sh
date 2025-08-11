#!/bin/bash

echo "🧪 Testando Chat Mode Angular + NestJS"
echo "======================================="
echo

# Verificar se o chat mode existe
if [ -f ~/.vscode/chatmodes/dev.chatmode.md ]; then
    echo "✅ Chat mode 'dev' encontrado"
else
    echo "❌ Chat mode 'dev' não encontrado"
    exit 1
fi

# Verificar se contém Angular + NestJS
if grep -q "Angular + NestJS" ~/.vscode/chatmodes/dev.chatmode.md; then
    echo "✅ Especialização Angular + NestJS confirmada"
else
    echo "❌ Especialização Angular + NestJS não encontrada"
fi

# Verificar instruções específicas
if [ -f ~/.vscode/instructions/angular-nestjs-practices.md ]; then
    echo "✅ Boas práticas Angular + NestJS disponíveis"
else
    echo "❌ Boas práticas Angular + NestJS não encontradas"
fi

echo
echo "📊 Estatísticas dos arquivos:"
echo "Chat mode dev: $(wc -l < ~/.vscode/chatmodes/dev.chatmode.md) linhas"
echo "Boas práticas: $(wc -l < ~/.vscode/instructions/angular-nestjs-practices.md) linhas"

echo
echo "🎯 Tecnologias principais detectadas:"
grep -o "Angular\|NestJS\|TypeScript\|RxJS\|NgRx" ~/.vscode/chatmodes/dev.chatmode.md | sort | uniq -c

echo
echo "💡 Exemplos de perguntas para testar:"
echo "  - 'Crie um component Angular standalone com Material'"
echo "  - 'Implemente um controller NestJS com validação'"
echo "  - 'Configure JWT auth entre Angular e NestJS'"
echo
