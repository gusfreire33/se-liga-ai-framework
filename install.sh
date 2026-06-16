#!/usr/bin/env bash
# =============================================================================
#  Se Liga AI (sl) — Instalador (macOS Intel/Apple Silicon + Linux)
#  Uso típico (uma linha):
#    curl -fsSL https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.sh | bash
#
#  Flags / env:
#    --project        instala na pasta atual (recomendado p/ um repo)
#    --global         instala nos diretórios home dos CLIs (padrão)
#    --cli "a,b"      limita aos CLIs (claude,codex,grok,antigravity). Padrão: todos.
#    SL_SOURCE=/path  usa uma cópia local do framework (não baixa nada)
#    SL_REPO=owner/repo  repositório de origem (padrão: gusfreire33/se-liga-ai-framework)
#    SL_BRANCH=main
# =============================================================================
set -euo pipefail

SL_REPO="${SL_REPO:-gusfreire33/se-liga-ai-framework}"
SL_BRANCH="${SL_BRANCH:-main}"
SCOPE="global"
CLIS="claude,codex,grok,antigravity"

# ---- parse args ----
while [ $# -gt 0 ]; do
  case "$1" in
    --project) SCOPE="project" ;;
    --global)  SCOPE="global" ;;
    --cli)     CLIS="${2:-}"; shift ;;
    *) echo "Flag desconhecida: $1" >&2; exit 2 ;;
  esac
  shift
done

c_grn='\033[0;32m'; c_blu='\033[0;34m'; c_yel='\033[1;33m'; c_red='\033[0;31m'; c_off='\033[0m'
# todas as mensagens vão para stderr — assim não contaminam $(resolve_source)
say()  { printf "${c_blu}»${c_off} %s\n" "$1" >&2; }
ok()   { printf "${c_grn}✓${c_off} %s\n" "$1" >&2; }
warn() { printf "${c_yel}!${c_off} %s\n" "$1" >&2; }
die()  { printf "${c_red}✗ %s${c_off}\n" "$1" >&2; exit 1; }

# ---- detectar OS/arch (informativo) ----
OS="$(uname -s)"; ARCH="$(uname -m)"
case "$OS" in
  Darwin) [ "$ARCH" = "arm64" ] && PLAT="macOS (Apple Silicon)" || PLAT="macOS (Intel)" ;;
  Linux)  PLAT="Linux ($ARCH)" ;;
  *)      PLAT="$OS ($ARCH)" ;;
esac
say "Plataforma: $PLAT  |  escopo: $SCOPE  |  CLIs: $CLIS"

# ---- obter a fonte do framework ----
TMP=""
cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; }
trap cleanup EXIT

resolve_source() {
  # 1) SL_SOURCE explícito
  if [ -n "${SL_SOURCE:-}" ] && [ -d "$SL_SOURCE/.codesl" ]; then echo "$SL_SOURCE"; return; fi
  # 2) rodando de dentro do próprio repo (script ao lado dos arquivos)
  local here; here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [ -n "$here" ] && [ -d "$here/.codesl" ]; then echo "$here"; return; fi
  if [ -d "./.codesl" ]; then echo "$(pwd)"; return; fi
  # 3) baixar tarball do GitHub
  command -v curl >/dev/null || die "curl não encontrado."
  command -v tar  >/dev/null || die "tar não encontrado."
  TMP="$(mktemp -d)"
  say "Baixando $SL_REPO@$SL_BRANCH ..."
  curl -fsSL "https://github.com/$SL_REPO/archive/refs/heads/$SL_BRANCH.tar.gz" \
    | tar -xz -C "$TMP" || die "Falha ao baixar/extrair. Configure SL_REPO ou use SL_SOURCE."
  local d; d="$(find "$TMP" -maxdepth 1 -type d -name '*-'"$SL_BRANCH" | head -1)"
  [ -d "$d/.codesl" ] || die "Tarball sem .codesl/ — repo de origem incompleto."
  echo "$d"
}
SRC="$(resolve_source)"
ok "Fonte: $SRC"

# ---- destino por escopo ----
if [ "$SCOPE" = "project" ]; then DEST="$(pwd)"; else DEST="$HOME"; fi

# helper: copia conteúdo de $1 para $2 (cria destino)
copydir() { mkdir -p "$2"; cp -R "$1/." "$2/" 2>/dev/null || true; }

has() { case ",$CLIS," in *",$1,"*) return 0;; *) return 1;; esac; }
present() { [ -d "$1" ]; }   # CLI considerado instalado se o home dir existe

installed=0

install_claude() {
  has claude || return 0
  if [ "$SCOPE" = "global" ] && ! present "$HOME/.claude"; then warn "Claude não detectado (~/.claude). Instalando mesmo assim."; fi
  local base; [ "$SCOPE" = "project" ] && base="$DEST/.claude" || base="$HOME/.claude"
  copydir "$SRC/.claude/skills"   "$base/skills"
  copydir "$SRC/.claude/commands" "$base/commands"
  copydir "$SRC/.claude/agents"   "$base/agents"
  ok "Claude Code → $base (skills/commands/agents)"; installed=1
}
install_codex() {
  has codex || return 0
  local base; [ "$SCOPE" = "project" ] && base="$DEST/.codex" || base="$HOME/.codex"
  copydir "$SRC/.codex/skills"  "$base/skills"
  copydir "$SRC/.codex/prompts" "$base/prompts"
  cp "$SRC/AGENTS.md" "$base/AGENTS.md" 2>/dev/null || true
  ok "Codex → $base (skills/prompts + AGENTS.md)"; installed=1
}
install_grok() {
  has grok || return 0
  local base; [ "$SCOPE" = "project" ] && base="$DEST/.grok" || base="$HOME/.grok"
  copydir "$SRC/.grok/skills" "$base/skills"
  [ "$SCOPE" = "project" ] && cp "$SRC/AGENTS.md" "$DEST/AGENTS.md" 2>/dev/null || true
  ok "Grok → $base (skills)"; installed=1
}
install_antigravity() {
  has antigravity || return 0
  if [ "$SCOPE" = "project" ]; then
    copydir "$SRC/.agent/skills"  "$DEST/.agent/skills"
    copydir "$SRC/.agents/skills" "$DEST/.agents/skills"
    cp "$SRC/AGENTS.md" "$DEST/AGENTS.md" 2>/dev/null || true
    ok "Antigravity → $DEST/.agent + .agents (skills)"
  else
    copydir "$SRC/.agent/skills"  "$HOME/.gemini/config/skills"  # CLI global
    copydir "$SRC/.agents/skills" "$HOME/.agents/skills"          # UI global
    ok "Antigravity → ~/.gemini/config/skills + ~/.agents/skills"
  fi
  installed=1
}

install_claude; install_codex; install_grok; install_antigravity
[ "$installed" = "1" ] || die "Nenhum CLI instalado (verifique --cli)."

# ---- runtime .codesl (sempre) ----
if [ "$SCOPE" = "project" ]; then RT="$DEST/.codesl"; else RT="$HOME/.codesl"; fi
copydir "$SRC/.codesl" "$RT"
find "$RT/scripts" -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
ok "Runtime → $RT (scripts + fragments + templates)"

echo
ok "Instalação concluída!"
if [ "$SCOPE" = "global" ]; then
  warn "Runtime em ~/.codesl. Para um projeto usar os comandos, rode dentro dele:"
  echo "    cp -R ~/.codesl ./.codesl"
  echo "  (os comandos referenciam .codesl/scripts/ por caminho relativo)"
fi
echo "Comece pelo gateway:  /sl   (Claude/Codex)   ·   skill 'sl'   (Grok/Antigravity)"
