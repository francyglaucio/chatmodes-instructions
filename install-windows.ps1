# ChatModes System - Windows PowerShell Installer
# ===============================================

param(
    [switch]$Force,
    [switch]$Verbose
)

# Configurações
$ErrorActionPreference = "Stop"
$VerbosePreference = if ($Verbose) { "Continue" } else { "SilentlyContinue" }

# Cores para output
function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    
    $colors = @{
        "Red" = "Red"
        "Green" = "Green" 
        "Yellow" = "Yellow"
        "Blue" = "Cyan"
        "White" = "White"
    }
    
    Write-Host $Text -ForegroundColor $colors[$Color]
}

function Print-Status {
    param([string]$Message)
    Write-ColorText "✅ $Message" "Green"
}

function Print-Error {
    param([string]$Message)
    Write-ColorText "❌ $Message" "Red"
}

function Print-Warning {
    param([string]$Message)
    Write-ColorText "⚠️ $Message" "Yellow"
}

function Print-Info {
    param([string]$Message)
    Write-ColorText "ℹ️ $Message" "Blue"
}

function Print-Header {
    Write-ColorText "`n  ╔═══════════════════════════════════════╗" "Blue"
    Write-ColorText "  ║    ChatModes System Installer        ║" "Blue"
    Write-ColorText "  ║         Windows PowerShell            ║" "Blue"
    Write-ColorText "  ╚═══════════════════════════════════════╝`n" "Blue"
}

# Verificar pré-requisitos
function Test-Prerequisites {
    Print-Info "Verificando pré-requisitos..."
    
    # Verificar PowerShell versão
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Print-Error "PowerShell 5.0 ou superior é necessário"
        return $false
    }
    Print-Status "PowerShell $($PSVersionTable.PSVersion) encontrado"
    
    # Verificar VS Code
    $codeCmd = Get-Command "code" -ErrorAction SilentlyContinue
    if (-not $codeCmd) {
        Print-Error "VS Code não encontrado. Instale o VS Code primeiro."
        Print-Info "Download: https://code.visualstudio.com/"
        return $false
    }
    Print-Status "VS Code encontrado"
    
    # Verificar conectividade
    try {
        $response = Invoke-WebRequest -Uri "https://github.com" -Method Head -TimeoutSec 5 -UseBasicParsing
        Print-Status "Conectividade verificada"
    }
    catch {
        Print-Error "Problema de conectividade: $_"
        return $false
    }
    
    return $true
}

# Criar diretórios
function New-DirectoryStructure {
    Print-Info "Criando estrutura de diretórios..."
    
    $global:VSCodeDir = Join-Path $env:USERPROFILE ".vscode"
    
    $directories = @(
        (Join-Path $VSCodeDir "chatmodes"),
        (Join-Path $VSCodeDir "instructions"), 
        (Join-Path $VSCodeDir "scripts")
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Print-Status "Criado: $dir"
        } else {
            Print-Info "Já existe: $dir"
        }
    }
    
    Print-Status "Estrutura criada em: $VSCodeDir"
}

# Baixar arquivo individual
function Get-FileFromUrl {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )
    
    try {
        Print-Info "Baixando: $Description"
        
        # Criar diretório pai se necessário
        $parentDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        
        # Baixar arquivo
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -TimeoutSec 30 -UseBasicParsing
        
        # Verificar se arquivo foi baixado e não está vazio
        if ((Test-Path $OutputPath) -and ((Get-Item $OutputPath).Length -gt 0)) {
            Print-Status "✓ $Description"
            return $true
        } else {
            Print-Error "Arquivo vazio: $Description"
            Remove-Item $OutputPath -ErrorAction SilentlyContinue
            return $false
        }
    }
    catch {
        Print-Error "Falha ao baixar $Description`: $_"
        Write-Verbose "URL: $Url"
        return $false
    }
}

# Baixar todos os arquivos
function Get-AllFiles {
    Print-Info "Iniciando download dos arquivos..."
    
    $baseUrl = "https://raw.githubusercontent.com/francyglaucio/chatmodes-instructions/main"
    $successCount = 0
    $totalCount = 0
    
    # Chatmodes
    $chatmodeFiles = @(
        "architect.chatmode.md",
        "dev-angular.chatmode.md",
        "dev-angular-legacy.chatmode.md",
        "dev-react.chatmode.md",
        "dev-java.chatmode.md",
        "dev-node.chatmode.md",
        "dev-csharp.chatmode.md", 
        "dev.chatmode.md",
        "infra.chatmode.md",
        "qa-specialist.chatmode.md"
    )
    
    Print-Info "Baixando perfis de chatmode..."
    foreach ($file in $chatmodeFiles) {
        $totalCount++
        $url = "$baseUrl/chatmodes/$file"
        $path = Join-Path $VSCodeDir "chatmodes\$file"
        
        if (Get-FileFromUrl -Url $url -OutputPath $path -Description $file) {
            $successCount++
        }
    }
    
    # Instructions
    $instructionFiles = @(
        "architecture-patterns.md",
        "angular-best-practices.md",
        "angular-legacy-best-practices.md",
        "angular-nestjs-practices.md",
        "react-best-practices.md",
        "java-best-practices.md",
        "nodejs-best-practices.md",
        "csharp-best-practices.md",
        "dev-best-practices.md",
        "infra-best-practices.md",
        "qa-best-practices.md"
    )
    
    Print-Info "Baixando instruções..."
    foreach ($file in $instructionFiles) {
        $totalCount++
        $url = "$baseUrl/instructions/$file"
        $path = Join-Path $VSCodeDir "instructions\$file"
        
        if (Get-FileFromUrl -Url $url -OutputPath $path -Description $file) {
            $successCount++
        }
    }
    
    # Scripts
    $scriptFiles = @(
        "test-angular-nestjs.sh",
        "validate-chatmodes.sh"
    )
    
    Print-Info "Baixando scripts..."
    foreach ($file in $scriptFiles) {
        $totalCount++
        $url = "$baseUrl/$file"
        $path = Join-Path $VSCodeDir "scripts\$file"
        
        if (Get-FileFromUrl -Url $url -OutputPath $path -Description $file) {
            $successCount++
        }
    }
    
    # Documentação
    $docFiles = @(
        "INSTALL-GUIDE.md",
        "README.md"
    )
    
    Print-Info "Baixando documentação..."
    foreach ($file in $docFiles) {
        $totalCount++
        $url = "$baseUrl/$file"
        $path = Join-Path $VSCodeDir $file
        
        if (Get-FileFromUrl -Url $url -OutputPath $path -Description $file) {
            $successCount++
        }
    }
    
    Print-Info "Download concluído: $successCount/$totalCount arquivos"
    
    if ($successCount -lt 15) {
        Print-Warning "Alguns arquivos não foram baixados"
        return $false
    }
    
    return $true
}

# Configurar VS Code
function Set-VSCodeConfiguration {
    Print-Info "Configurando VS Code..."
    
    $settingsDir = Join-Path $env:APPDATA "Code\User"
    $settingsFile = Join-Path $settingsDir "settings.json"
    
    # Criar diretório se não existir
    if (-not (Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    }
    
    # Backup se existir
    if (Test-Path $settingsFile) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "$settingsFile.backup.$timestamp"
        Copy-Item $settingsFile $backupFile
        Print-Info "Backup criado: $backupFile"
    }
    
    # Configurações recomendadas
    $chatmodeSettings = @{
        "chatmodes.enabled" = $true
        "chatmodes.path" = "~/.vscode/chatmodes"
        "chatmodes.instructions" = "~/.vscode/instructions"
        "chatmodes.autoLoad" = $true
        "files.associations" = @{
            "*.chatmode.md" = "markdown"
        }
        "editor.quickSuggestions" = @{
            "strings" = $true
            "comments" = $true
            "other" = $true
        }
        "markdown.preview.breaks" = $true
        "markdown.preview.linkify" = $true
    } | ConvertTo-Json -Depth 3
    
    # Salvar configurações
    if (-not (Test-Path $settingsFile)) {
        $chatmodeSettings | Out-File $settingsFile -Encoding UTF8
        Print-Status "settings.json criado"
    } else {
        $recommendedFile = Join-Path $VSCodeDir "recommended-settings.json"
        $chatmodeSettings | Out-File $recommendedFile -Encoding UTF8
        Print-Warning "settings.json já existe. Configurações salvas em: $recommendedFile"
    }
}

# Validar instalação
function Test-Installation {
    Print-Info "Validando instalação..."
    
    $chatmodeCount = (Get-ChildItem (Join-Path $VSCodeDir "chatmodes") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $instructionCount = (Get-ChildItem (Join-Path $VSCodeDir "instructions") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    
    Print-Info "Arquivos encontrados:"
    Print-Info "  Chatmodes: $chatmodeCount"
    Print-Info "  Instruções: $instructionCount"
    
    if ($chatmodeCount -ge 8) {
        Print-Status "Perfis de chatmode: $chatmodeCount (✓)"
    } else {
        Print-Error "Poucos perfis: $chatmodeCount (esperado: 8+)"
        return $false
    }
    
    if ($instructionCount -ge 8) {
        Print-Status "Instruções: $instructionCount (✓)"
    } else {
        Print-Error "Poucas instruções: $instructionCount (esperado: 8+)"
        return $false
    }
    
    return $true
}

# Criar atalhos
function New-Shortcuts {
    Print-Info "Criando atalhos..."
    
    $shortcutScript = Join-Path $VSCodeDir "scripts\open-chatmode.ps1"
    
    $scriptContent = @'
param([string]$Profile)

$VSCodeDir = Join-Path $env:USERPROFILE ".vscode"

if (-not $Profile) {
    Write-Host "Uso: .\open-chatmode.ps1 <perfil>"
    Write-Host ""
    Write-Host "Perfis disponíveis:"
    $profiles = Get-ChildItem (Join-Path $VSCodeDir "chatmodes") -Filter "*.chatmode.md" -ErrorAction SilentlyContinue
    foreach ($p in $profiles) {
        Write-Host "  $($p.BaseName.Replace('.chatmode', ''))"
    }
    exit 1
}

$file = Join-Path $VSCodeDir "chatmodes\$Profile.chatmode.md"

if (Test-Path $file) {
    Write-Host "Abrindo perfil: $Profile"
    & code $file
} else {
    Write-Host "Perfil não encontrado: $Profile"
    Write-Host ""
    Write-Host "Perfis disponíveis:"
    $profiles = Get-ChildItem (Join-Path $VSCodeDir "chatmodes") -Filter "*.chatmode.md" -ErrorAction SilentlyContinue
    foreach ($p in $profiles) {
        Write-Host "  $($p.BaseName.Replace('.chatmode', ''))"
    }
}
'@
    
    $scriptContent | Out-File $shortcutScript -Encoding UTF8
    Print-Status "Script de atalho criado: $shortcutScript"
}

# Mostrar informações finais
function Show-CompletionInfo {
    Print-Header
    Print-Status "Instalação concluída com sucesso!"
    
    $chatmodeCount = (Get-ChildItem (Join-Path $VSCodeDir "chatmodes") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $instructionCount = (Get-ChildItem (Join-Path $VSCodeDir "instructions") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    
    Write-Host ""
    Print-Info "📁 Local: $VSCodeDir"
    Print-Info "📚 Perfis: $chatmodeCount"
    Print-Info "📖 Instruções: $instructionCount"
    Write-Host ""
    Print-Info "🚀 Como usar:"
    Write-Host "   1. Abra VS Code"
    Write-Host "   2. Teste um perfil:"
    Write-Host "      code `"$VSCodeDir\chatmodes\dev-angular.chatmode.md`""
    Write-Host "   3. Leia o guia:"
    Write-Host "      code `"$VSCodeDir\INSTALL-GUIDE.md`""
    Write-Host ""
    Print-Info "💡 Dica: Copie o conteúdo de um perfil e cole no seu AI Assistant!"
    Write-Host ""
}

# Função principal
function main {
    Print-Header
    
    Print-Info "Instalador do ChatModes System para Windows"
    Write-Host ""
    
    if (-not $Force) {
        $response = Read-Host "Continuar com a instalação? (y/N)"
        if ($response -notmatch "^[Yy]") {
            Print-Info "Instalação cancelada."
            return
        }
    }
    
    try {
        if (-not (Test-Prerequisites)) {
            throw "Pré-requisitos não atendidos"
        }
        
        New-DirectoryStructure
        
        if (-not (Get-AllFiles)) {
            Print-Warning "Alguns arquivos falharam no download, mas continuando..."
        }
        
        Set-VSCodeConfiguration
        
        if (Test-Installation) {
            New-Shortcuts
            Show-CompletionInfo
        } else {
            throw "Validação da instalação falhou"
        }
    }
    catch {
        Print-Error "Erro durante a instalação: $_"
        exit 1
    }
}

# Executar se chamado diretamente
if ($MyInvocation.InvocationName -ne ".") {
    main
}
