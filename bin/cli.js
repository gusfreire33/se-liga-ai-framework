#!/usr/bin/env node
'use strict';
/*
 * Se Liga AI (sl) — Instalador npx (cross-platform: Windows / macOS / Linux)
 *
 *   npx se-liga-ai install      instala GLOBAL (skills/comandos em ~/.<cli> + runtime em ~/.codesl)
 *   npx se-liga-ai init         scaffolda .codesl/ no projeto atual (necessário p/ os comandos rodarem)
 *
 * Flags (no install):
 *   --project        instala TUDO na pasta atual (em vez de global)
 *   --cli a,b        limita aos CLIs: claude,codex,grok,antigravity (padrão: todos)
 */
const fs = require('fs');
const path = require('path');
const os = require('os');

const PKG = path.join(__dirname, '..');     // raiz do pacote (onde vivem .claude, .codesl, ...)
const HOME = os.homedir();
const CWD = process.cwd();

const argv = process.argv.slice(2);
const cmd = argv.find(a => !a.startsWith('-'));               // 'init' ou undefined
const scope = argv.includes('--project') ? 'project' : 'global';
const cliIdx = argv.indexOf('--cli');
const CLIS = (cliIdx >= 0 && argv[cliIdx + 1] ? argv[cliIdx + 1] : 'claude,codex,grok,antigravity')
  .split(',').map(s => s.trim()).filter(Boolean);

// ---- saída ----
const C = process.stdout.isTTY
  ? { b: '\x1b[34m', g: '\x1b[32m', y: '\x1b[33m', r: '\x1b[31m', o: '\x1b[0m' }
  : { b: '', g: '', y: '', r: '', o: '' };
const say = m => console.log(`${C.b}»${C.o} ${m}`);
const ok  = m => console.log(`${C.g}✓${C.o} ${m}`);
const warn = m => console.log(`${C.y}!${C.o} ${m}`);
const die = m => { console.error(`${C.r}✗ ${m}${C.o}`); process.exit(1); };

function copy(src, dst) {
  if (!fs.existsSync(src)) return false;
  fs.mkdirSync(dst, { recursive: true });
  fs.cpSync(src, dst, { recursive: true });
  return true;
}
const has = name => CLIS.includes(name);

// valida que estamos rodando de um pacote íntegro
if (!fs.existsSync(path.join(PKG, '.codesl'))) {
  die('Pacote incompleto: .codesl/ não encontrado. Reinstale o se-liga-ai-framework.');
}

// =====================  init: scaffolda runtime no projeto  =====================
if (cmd === 'init') {
  const dst = path.join(CWD, '.codesl');
  copy(path.join(PKG, '.codesl'), dst);
  ok(`Runtime instalado em ${dst}`);
  say('Agora os comandos (/sl.plan, /sl.build, ...) encontram .codesl/scripts neste projeto.');
  process.exit(0);
}

// comando desconhecido -> ajuda (não instala nada por engano)
if (cmd && cmd !== 'install') {
  console.log(`Se Liga AI — uso:
  npx se-liga-ai install [--project] [--cli claude,codex,grok,antigravity]
  npx se-liga-ai init        (dentro de um projeto: cria .codesl/)
`);
  process.exit(cmd === 'help' || cmd === '--help' ? 0 : 2);
}

// =====================  install (cmd === 'install' ou sem subcomando)  =====================
say(`Se Liga AI — instalando | escopo: ${scope} | CLIs: ${CLIS.join(',')}`);
const base = scope === 'project' ? CWD : HOME;
let installed = 0;

if (has('claude')) {
  const b = path.join(base, '.claude');
  copy(path.join(PKG, '.claude/skills'),   path.join(b, 'skills'));
  copy(path.join(PKG, '.claude/commands'), path.join(b, 'commands'));
  copy(path.join(PKG, '.claude/agents'),   path.join(b, 'agents'));
  ok(`Claude Code → ${b} (skills/commands/agents)`); installed++;
}
if (has('codex')) {
  const b = path.join(base, '.codex');
  copy(path.join(PKG, '.codex/skills'),  path.join(b, 'skills'));
  copy(path.join(PKG, '.codex/prompts'), path.join(b, 'prompts'));
  fs.mkdirSync(b, { recursive: true });
  try { fs.copyFileSync(path.join(PKG, 'AGENTS.md'), path.join(b, 'AGENTS.md')); } catch (_) {}
  ok(`Codex → ${b} (skills/prompts + AGENTS.md)`); installed++;
}
if (has('grok')) {
  const b = path.join(base, '.grok');
  copy(path.join(PKG, '.grok/skills'), path.join(b, 'skills'));
  if (scope === 'project') { try { fs.copyFileSync(path.join(PKG, 'AGENTS.md'), path.join(base, 'AGENTS.md')); } catch (_) {} }
  ok(`Grok → ${b} (skills)`); installed++;
}
if (has('antigravity')) {
  if (scope === 'project') {
    copy(path.join(PKG, '.agent/skills'),  path.join(base, '.agent', 'skills'));
    copy(path.join(PKG, '.agents/skills'), path.join(base, '.agents', 'skills'));
    try { fs.copyFileSync(path.join(PKG, 'AGENTS.md'), path.join(base, 'AGENTS.md')); } catch (_) {}
    ok(`Antigravity → ${base}/.agent + .agents (skills)`);
  } else {
    copy(path.join(PKG, '.agent/skills'),  path.join(HOME, '.gemini', 'config', 'skills'));
    copy(path.join(PKG, '.agents/skills'), path.join(HOME, '.agents', 'skills'));
    ok('Antigravity → ~/.gemini/config/skills + ~/.agents/skills');
  }
  installed++;
}
if (!installed) die('Nenhum CLI selecionado (verifique --cli).');

// runtime
const rt = path.join(base, '.codesl');
copy(path.join(PKG, '.codesl'), rt);
ok(`Runtime → ${rt}`);

console.log('');
ok('Instalação concluída!');
if (scope === 'global') {
  warn('Para um projeto usar os comandos, rode dentro dele:  npx se-liga-ai init');
  say('(os comandos referenciam .codesl/scripts/ por caminho relativo ao projeto)');
}
say("Comece pelo gateway:  /sl  (Claude/Codex)  ·  skill 'sl'  (Grok/Antigravity)");
