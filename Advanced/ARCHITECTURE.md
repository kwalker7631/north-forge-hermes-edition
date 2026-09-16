# Architecture (engineer, not a thesis)

Two systems. One desk. One optional lab. They do not share a process.

```mermaid
flowchart TB
  subgraph stick["USB volume (BLACK-NORTH / GREGW-NOREX / BASIC)"]
    LNK[Terminal / Web shortcuts]
    VENV[north-forge-agent-venv\nhermes.exe]
    DATA[north-forge-agent-data\nHERMES_HOME]
    ENG[north-forge-agent\nHermes chassis]
    PACK[private-editions/kyocera\nSOUL skills theme]
  end

  subgraph layers["Agent layers"]
    UI[CLI session + hermes dashboard]
    ROUTER[Desk modes /hl /a /chk /clr /fl]
    SOUL[SOUL.md voice + humanizer]
    SK[Pack skills + allowlist]
    MEM[Hermes memory / FTS5 / optional vector]
    LLM[Provider: Anthropic default\nEnv keys, 30-day burner, free fallback]
  end

  LNK --> VENV --> UI
  VENV --> DATA
  ENG --> UI
  PACK --> SOUL
  PACK --> SK
  UI --> ROUTER --> SOUL
  ROUTER --> SK
  SK --> MEM
  UI --> LLM
```

## Layer table

| Layer | What it is | Who owns it |
|---|---|---|
| Volume | Isolated venv + HERMES_HOME on the stick | Deploy Console |
| Chassis | Hermes Agent loop, tools, dashboard, models list | Nous / north-forge-agent fork |
| Pack | Kyocera well, SOUL, skills, theme, aliases | This private edition |
| Desk router | `/hl` `/a` `/chk` `/clr` `/fl` `/dash` | Pack skills |
| Inference | Anthropic first; dashboard can switch | Keys on the stick |
| Lab (optional) | Pinokio on another disk | User download, not fleet |

## Call path

```mermaid
sequenceDiagram
  participant T as Technician
  participant C as Terminal / Web
  participant H as Hermes loop
  participant P as Pack skills
  participant K as Model API
  T->>C: paste model + code + symptom
  C->>H: session under HERMES_HOME
  H->>P: SOUL + mode + /chk if needed
  P->>H: next step or honest gap
  H->>K: completion (burner or free)
  K-->>T: coworker voice, not a brochure
```

## What is not in-process

Pinokio is a separate Electron app + `pinokio-home`. It does not load SOUL.
It does not write the Kyocera well. Screenshots and download links live in
`PINOKIO.md`. Install it on Windows, macOS, or Linux when you want a node
canvas. Do not copy it onto Greg.

Hermes official manual: https://hermes-agent.nousresearch.com/docs/
