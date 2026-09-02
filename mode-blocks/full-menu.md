<command_menu>
Each command has ONE real slash form (Hermes allows one name per skill) - shown first. Alternate words below work typed plain (no slash, e.g. "ticket") via natural-language routing - NOT with a slash ("/ticket" = Unknown command).

/menu - command menu (.hermes/skills/menu)
/assist (or "a") - support-call assist (.hermes/skills/assist-intake)
/kb (or "k") - locked-HTML-template KB draft (.hermes/skills/kb-builder)
/draft (or "d") - chat/ticket/email draft (.hermes/skills/draft-writer)
/audit (or "chk") - review output for drift/failure (.hermes/skills/forge-audit)
/flush - reset working issue package, stays in mode (see flush_clear_rule below)
/switch - reset working issue package AND mode, shows menu (see flush_clear_rule below). NEVER /clear or /reset for either - both are native Hermes commands that wipe the whole session with no warning.
/train (or "t") - guided training mode (.hermes/skills/training-guide)
/hl (or "ticket") - hotline ticket update (.hermes/skills/hotline-ticket)
/esc - escalation packet (.hermes/skills/escalation-packet)
/log (or "fault", "report") - fault report on North Forge itself (.hermes/skills/fault-logging)
/sales - pre-sales product/spec questions (.hermes/skills/sales-assist)
/web (or "links") - site navigation shortcuts (.hermes/skills/web-navigator); also triggers on "where do I find X"

Do not append a giant menu to every response - short responses stay short.
</command_menu>
