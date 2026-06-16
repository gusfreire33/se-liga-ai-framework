<#
=============================================================================
 Se Liga AI (sl) — Instalador (Windows / PowerShell)
 Uso típico (uma linha):
   irm https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.ps1 | iex

 Parâmetros:
   -Project        instala na pasta atual (recomendado p/ um repo)
   -Global         instala nos diretórios home dos CLIs (padrão)
   -Cli "a,b"      limita aos CLIs (claude,codex,grok,antigravity). Padrão: todos.
   -Source <path>  usa uma cópia local do framework (não baixa nada)
   -Repo owner/repo  repositório de origem (padrão: gusfreire33/se-liga-ai-framework)
   -Branch main
=============================================================================
#>
[CmdletBinding()]
param(
  [switch]$Project,
  [switch]$Global,
  [string]$Cli    = "claude,codex,grok,antigravity",
  [string]$Source = "",
  [string]$Repo   = "gusfreire33/se-liga-ai-framework",
  [string]$Branch = "main"
)
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host "» $m" -ForegroundColor Blue }
function Ok($m){ Write-Host "+ $m" -ForegroundColor Green }
function Warn($m){ Write-Host "! $m" -ForegroundColor Yellow }
function Die($m){ Write-Host "x $m" -ForegroundColor Red; exit 1 }

$scope = if ($Project) { "project" } else { "global" }
$clis  = ($Cli -split ',' | ForEach-Object { $_.Trim() })
Say "Plataforma: Windows ($env:PROCESSOR_ARCHITECTURE)  |  escopo: $scope  |  CLIs: $Cli"

# ---- obter a fonte do framework ----
$tmp = $null
function Resolve-Source {
  if ($Source -and (Test-Path -LiteralPath (Join-Path $Source ".codesl"))) { return (Resolve-Path -LiteralPath $Source).Path }
  $here = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
  if (Test-Path -LiteralPath (Join-Path $here ".codesl")) { return $here }
  if (Test-Path -LiteralPath (Join-Path (Get-Location).Path ".codesl")) { return (Get-Location).Path }
  # baixar zip do GitHub
  $script:tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("sl-" + [guid]::NewGuid().ToString('N')))
  $zip = Join-Path $tmp.FullName "src.zip"
  Say "Baixando $Repo@$Branch ..."
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $tmp.FullName -Force
  } catch { Die "Falha ao baixar/extrair. Configure -Repo ou use -Source. ($_)" }
  $d = Get-ChildItem $tmp.FullName -Directory | Where-Object { Test-Path (Join-Path $_.FullName ".codesl") } | Select-Object -First 1
  if (-not $d) { Die "Zip sem .codesl/ — repo de origem incompleto." }
  return $d.FullName
}
$src = Resolve-Source
Ok "Fonte: $src"

$dest = if ($scope -eq "project") { (Get-Location).Path } else { $HOME }
function CopyDir($from,$to){
  if (-not (Test-Path -LiteralPath $from)) { return }
  New-Item -ItemType Directory -Force -Path $to | Out-Null
  Get-ChildItem -LiteralPath $from -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $to -Recurse -Force
  }
}
function Has($name){ $clis -contains $name }

$installed = $false

if (Has 'claude') {
  $base = if ($scope -eq 'project') { Join-Path $dest '.claude' } else { Join-Path $HOME '.claude' }
  CopyDir "$src\.claude\skills"   "$base\skills"
  CopyDir "$src\.claude\commands" "$base\commands"
  CopyDir "$src\.claude\agents"   "$base\agents"
  Ok "Claude Code -> $base (skills/commands/agents)"; $installed = $true
}
if (Has 'codex') {
  $base = if ($scope -eq 'project') { Join-Path $dest '.codex' } else { Join-Path $HOME '.codex' }
  CopyDir "$src\.codex\skills"  "$base\skills"
  CopyDir "$src\.codex\prompts" "$base\prompts"
  Copy-Item -LiteralPath "$src\AGENTS.md" -Destination "$base\AGENTS.md" -Force -ErrorAction SilentlyContinue
  Ok "Codex -> $base (skills/prompts + AGENTS.md)"; $installed = $true
}
if (Has 'grok') {
  $base = if ($scope -eq 'project') { Join-Path $dest '.grok' } else { Join-Path $HOME '.grok' }
  CopyDir "$src\.grok\skills" "$base\skills"
  if ($scope -eq 'project') { Copy-Item -LiteralPath "$src\AGENTS.md" -Destination "$dest\AGENTS.md" -Force -ErrorAction SilentlyContinue }
  Ok "Grok -> $base (skills)"; $installed = $true
}
if (Has 'antigravity') {
  if ($scope -eq 'project') {
    CopyDir "$src\.agent\skills"  "$dest\.agent\skills"
    CopyDir "$src\.agents\skills" "$dest\.agents\skills"
    Copy-Item -LiteralPath "$src\AGENTS.md" -Destination "$dest\AGENTS.md" -Force -ErrorAction SilentlyContinue
    Ok "Antigravity -> $dest\.agent + .agents (skills)"
  } else {
    CopyDir "$src\.agent\skills"  (Join-Path $HOME '.gemini\config\skills')
    CopyDir "$src\.agents\skills" (Join-Path $HOME '.agents\skills')
    Ok "Antigravity -> ~\.gemini\config\skills + ~\.agents\skills"
  }
  $installed = $true
}
if (-not $installed) { Die "Nenhum CLI instalado (verifique -Cli)." }

# ---- runtime .codesl ----
$rt = if ($scope -eq 'project') { Join-Path $dest '.codesl' } else { Join-Path $HOME '.codesl' }
CopyDir "$src\.codesl" $rt
Ok "Runtime -> $rt (scripts + fragments + templates)"

Write-Host ""
Ok "Instalacao concluida!"
if ($scope -eq 'global') {
  Warn "Runtime em ~\.codesl. Para um projeto usar os comandos, rode dentro dele:"
  Write-Host "    Copy-Item -Recurse `$HOME\.codesl .\.codesl"
}
Write-Host "Comece pelo gateway:  /sl  (Claude/Codex)  ·  skill 'sl'  (Grok/Antigravity)"
