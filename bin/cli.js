#!/usr/bin/env node
'use strict';
/*
 * Se Liga AI (sl) — Instalador npx (cross-platform: Windows / macOS / Linux)
 *
 *   npx se-liga-ai install      instala GLOBAL (skills/comandos em ~/.<cli> + runtime em ~/.codesl)
 *   npx se-liga-ai update       atualiza com as novidades do repo (poda o antigo do framework + recopia)
 *   npx se-liga-ai init         scaffolda .codesl/ no projeto atual (necessário p/ os comandos rodarem)
 *
 * Flags (install/update):
 *   --project        instala/atualiza na pasta atual (em vez de global)
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

// Remove apenas entradas DO FRAMEWORK (sl, sl-*, sl.*) de um diretório, preservando
// skills/comandos próprios do usuário. Usado no `update` p/ refletir renomeações/remoções.
function pruneSl(dir) {
  if (!fs.existsSync(dir)) return;
  for (const name of fs.readdirSync(dir)) {
    if (name === 'sl' || name.startsWith('sl-') || name.startsWith('sl.')) {
      fs.rmSync(path.join(dir, name), { recursive: true, force: true });
    }
  }
}

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
if (cmd && cmd !== 'install' && cmd !== 'update') {
  console.log(`Se Liga AI — uso:
  npx se-liga-ai install [--project] [--cli claude,codex,grok,antigravity]
  npx se-liga-ai update  [--project] [--cli ...]   (puxa novidades do repo e atualiza)
  npx se-liga-ai init        (dentro de um projeto: cria .codesl/)
`);
  process.exit(cmd === 'help' || cmd === '--help' ? 0 : 2);
}

// =====================  install / update (cmd 'install', 'update' ou sem subcomando)  =====================
const isUpdate = cmd === 'update';
let pkgVersion = '';
try { pkgVersion = require(path.join(PKG, 'package.json')).version; } catch (_) {}
say(`Se Liga AI — ${isUpdate ? 'atualizando' : 'instalando'}${pkgVersion ? ' v' + pkgVersion : ''} | escopo: ${scope} | CLIs: ${CLIS.join(',')}`);
const base = scope === 'project' ? CWD : HOME;
let installed = 0;

if (has('claude')) {
  const b = path.join(base, '.claude');
  if (isUpdate) { pruneSl(path.join(b, 'skills')); pruneSl(path.join(b, 'commands')); }
  copy(path.join(PKG, '.claude/skills'),   path.join(b, 'skills'));
  copy(path.join(PKG, '.claude/commands'), path.join(b, 'commands'));
  copy(path.join(PKG, '.claude/agents'),   path.join(b, 'agents'));
  ok(`Claude Code → ${b} (skills/commands/agents)`); installed++;
}
if (has('codex')) {
  const b = path.join(base, '.codex');
  if (isUpdate) { pruneSl(path.join(b, 'skills')); pruneSl(path.join(b, 'prompts')); }
  copy(path.join(PKG, '.codex/skills'),  path.join(b, 'skills'));
  copy(path.join(PKG, '.codex/prompts'), path.join(b, 'prompts'));
  fs.mkdirSync(b, { recursive: true });
  try { fs.copyFileSync(path.join(PKG, 'AGENTS.md'), path.join(b, 'AGENTS.md')); } catch (_) {}
  ok(`Codex → ${b} (skills/prompts + AGENTS.md)`); installed++;
}
if (has('grok')) {
  const b = path.join(base, '.grok');
  if (isUpdate) pruneSl(path.join(b, 'skills'));
  copy(path.join(PKG, '.grok/skills'), path.join(b, 'skills'));
  if (scope === 'project') { try { fs.copyFileSync(path.join(PKG, 'AGENTS.md'), path.join(base, 'AGENTS.md')); } catch (_) {} }
  ok(`Grok → ${b} (skills)`); installed++;
}
if (has('antigravity')) {
  if (scope === 'project') {
    if (isUpdate) { pruneSl(path.join(base, '.agent', 'skills')); pruneSl(path.join(base, '.agents', 'skills')); }
    copy(path.join(PKG, '.agent/skills'),  path.join(base, '.agent', 'skills'));
    copy(path.join(PKG, '.agents/skills'), path.join(base, '.agents', 'skills'));
    try { fs.copyFileSync(path.join(PKG, 'AGENTS.md'), path.join(base, 'AGENTS.md')); } catch (_) {}
    ok(`Antigravity → ${base}/.agent + .agents (skills)`);
  } else {
    if (isUpdate) { pruneSl(path.join(HOME, '.gemini', 'config', 'skills')); pruneSl(path.join(HOME, '.agents', 'skills')); }
    copy(path.join(PKG, '.agent/skills'),  path.join(HOME, '.gemini', 'config', 'skills'));
    copy(path.join(PKG, '.agents/skills'), path.join(HOME, '.agents', 'skills'));
    ok('Antigravity → ~/.gemini/config/skills + ~/.agents/skills');
  }
  installed++;
}
if (!installed) die('Nenhum CLI selecionado (verifique --cli).');

// runtime (totalmente do framework — no update, recria do zero p/ remover scripts obsoletos)
const rt = path.join(base, '.codesl');
if (isUpdate) fs.rmSync(rt, { recursive: true, force: true });
copy(path.join(PKG, '.codesl'), rt);
ok(`Runtime → ${rt}`);

console.log('');
ok(isUpdate ? `Atualização concluída!${pkgVersion ? ' Agora na v' + pkgVersion + '.' : ''}` : 'Instalação concluída!');
if (scope === 'global') {
  warn(`Para um projeto usar os comandos, rode dentro dele:  npx se-liga-ai ${isUpdate ? 'init' : 'init'}`);
  say('(os comandos referenciam .codesl/scripts/ por caminho relativo ao projeto)');
  if (isUpdate) say('Num projeto que já usa o sl, rode `npx se-liga-ai init` pra atualizar o .codesl/ local também.');
}
say("Comece pelo gateway:  /sl  (Claude/Codex)  ·  skill 'sl'  (Grok/Antigravity)");
