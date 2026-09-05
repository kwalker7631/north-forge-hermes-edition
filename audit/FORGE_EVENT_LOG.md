# North Forge - Forge Event Log

Running, append-only record of `FORGE EVENT LOG` blocks emitted by North
Forge / the primary GPT and relayed to Claude Code for persistence.

Per `.hermes.template.md`'s `fault-logging` skill and
`fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md`'s `<logging_and_fault_report_rule>`
(both Zone B, quoted here, not edited): "North Forge runs as a prompt in a
chat session. It has no persistent storage of its own... It produces
structured, clipboard-ready log entries. A human or an external system
must store them." This file is that external system for event-log blocks
specifically (distinct from `audit/CLAUDE_CODE_LAST_AUDIT.md`, which is
Claude Code's own per-session audit, and `CHANGELOG.md`, which is the
human-readable change history). Newest entries appended at the bottom.
Treated as a Claude-Code-maintained operational record (same footing as
the audit report), not authored field content - not yet in any of
CLAUDE.md's explicit zone lists; flagged for the primary GPT/Blacksmith to
formally place in Zone A alongside the audit report if this becomes a
recurring pattern.

---

```
FORGE EVENT LOG
Timestamp: 2026-09-05 01:53:12 EDT (relayed to Claude Code without an
  authoritative time; this is the time Claude Code recorded the entry)
Package: North Forge - Kyocera Edition - v21.8
Event: Live rule-consistency regression pass (cold start, vague symptom,
  /a, KB Mermaid-mandatory, contact block lock, template filename match,
  flush/clear hard-reset, /hl /esc /log format)
Detail: All 8 checked areas PASS against current live rule text. Literal
  R-001-R-017 checkoff not possible - REGRESSION_TEST_MATRIX.md not in
  project knowledge. No faults found this pass.
Linked report: None
```
