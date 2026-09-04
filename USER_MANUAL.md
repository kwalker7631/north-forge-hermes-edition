# North Forge - User Manual (Plain English)

This is the "what do I type" manual for the North Forge drive. It assumes
nothing. If you can read this file, you can use this system.

If you only remember one thing, remember this:

    YOU DO NOT NEED TO MEMORIZE ANY COMMANDS.
    Just type your problem in plain English and press Enter.
    North Forge picks the right tool by itself.

Everything below exists so you can ALSO drive it directly when you want to.

---

## 1. How to start

1. Plug in the drive.
2. Double-click `launch-north-forge.bat` (Windows) or run
   `./launch-north-forge.sh` (Mac/Linux).
3. Wait for the prompt. You are now talking to North Forge.
4. Type what you need. Press Enter.

Lost? Type this and press Enter:

    /menu

That shows every command available on THIS drive, with one line each about
what it does. If you ever don't know what to do next, type /menu.

---

## 2. What a "/" command is

A word starting with a slash, like /kb or /assist, is a command. It tells
North Forge exactly which mode to use instead of letting it guess.

Rules that trip people up:

- Each command has ONE slash spelling. /kb works. /ticket does NOT work
  with a slash - but typing the plain word "ticket" (no slash) does.
- Commands are typed at the start of your message. You can put your
  request right after it, on the same line:

      /kb make this scan-to-email fix into an article

- You never NEED a command. Describing the problem works. Commands are
  shortcuts, not requirements.

---

## 3. The commands, one by one

Each entry: what you type, what it is, and WHAT TO DO AFTER, so you are
never left staring at the screen.

/menu
  Shows the full command list for this drive.
  After: pick a command from the list, or just type your problem.

/assist   (or type "a")
  THE DEFAULT. Live support-call help. Give it the machine model, the
  exact symptom, and any error code, and it gives you repair steps and
  tells you what evidence to collect.
  After: follow the steps. If they don't fix it, say so - it gives you
  the next step. This is where almost every session should start.

/kb   (or "k")
  Turns a solved issue into a formatted knowledge-base article using the
  locked HTML template. Use AFTER an issue is resolved.
  After: run /audit on the draft before it goes anywhere near publish.

/draft   (or "d")
  Writes an email, customer update, internal message, or ServiceNow note
  about the current issue. Tell it who the audience is.
  After: read it, fix anything you don't like, copy it out.

/hl   (or type "ticket" - no slash)
  Produces a clipboard-ready hotline ticket note from the current issue.
  After: paste it into the ticket. Then type /flush before starting the
  next ticket.

/esc
  Builds a structured escalation packet - everything engineering needs to
  take the issue off your hands, in their format.
  After: send the packet through your normal escalation channel.

/audit   (or "chk")
  Reviews a KB, draft, or answer for errors, drift, and made-up facts.
  Paste in the thing you want checked, or run it right after /kb.
  After: fix what it flags, or approve and move on.

/train   (or "t")
  Slow, step-by-step teaching mode. Use when you're new to a device or
  procedure and want explanation, not just terse steps.
  After: say "next" to keep going, or ask questions freely.

/log   (or "fault", "report" - no slash)
  Reports a bug in NORTH FORGE ITSELF - wrong answers, template failures,
  old ticket info leaking into a new one. Not for machine problems.
  After: copy the FORGE FAULT REPORT block it produces and get it to
  Kenneth. It is NOT stored automatically.

/sales
  Pre-sales product and spec questions (compatibility, options, paper
  handling). Not for repair questions.
  After: verify anything spec-critical against the official spec sheet.

/web   (or "links")
  Gives you direct links into kyoceradocumentsolutions.us - downloads,
  support pages, dealer locator, etc. Or just ask "where do I find X on
  the site."
  After: click the link.

/manual
  Answers "how do I use this system" questions from this very manual -
  what a command does, how to add a skill, what /flush is for.
  After: ask your next question, or just get back to work.

/flush
  WIPES the current issue from North Forge's working memory but keeps you
  in the same mode. Use BETWEEN TICKETS so ticket A's details never bleed
  into ticket B.
  After: start describing the next issue fresh.

/switch
  Wipes the current issue AND resets to the default mode, then shows the
  menu. Use when changing to a different KIND of task entirely.
  After: pick from the menu it shows you.

---

## 4. DANGER: /clear and /reset are NOT North Forge commands

/clear and /reset belong to the underlying Hermes program. They throw away
your ENTIRE session with no warning - everything, not just the current
ticket.

    To reset a ticket:      /flush
    To change task type:    /switch
    NEVER type /clear or /reset for either of those.

There is also no /initialize command. If someone tells you to type any of
these three, don't.

---

## 5. FULL drives vs SALES drives

Not every drive has every command. The mode banner at session start tells
you which one you have.

  FULL drive  - everything in section 3.
  SALES drive - only /menu, /manual, /sales, /web, /flush, /switch (plus
                the two automatic research jobs). Support commands like
                /assist and /kb are intentionally absent, not broken. For
                repair issues, use the normal TSC channel.

To change a drive's mode: exit the session, run `toggle-mode.bat` (or
`.sh`), pick FULL or SALES, then relaunch. (The third option, RESET, wipes
the drive's setup back to first-use - it asks you to type YES first.)

---

## 6. The two automatic jobs (you don't run these)

Two research tasks run on a schedule by themselves:

  nightly-kyocera-research - 6:00 AM daily. Deep pass over public Kyocera
    sources (firmware notes, known issues, tech forums). New findings are
    appended to research-log/kyocera-research-log.md.
  daily-kyocera-brief - 8:00 AM daily. Short industry-news digest,
    appended to research-log/daily-brief-log.md.

You benefit from them automatically: North Forge checks the research log
during /assist before saying "not supported." You can also open those two
files and read them yourself - they're plain text.

To check the schedule is alive, type inside a session:

    hermes cron list

Both jobs should be listed and enabled. If one is missing, just relaunch
the drive - the launcher re-creates missing jobs automatically.

---

## 7. What skills are installed, and how to see for yourself

A "skill" is one folder containing one SKILL.md instruction file. Each
command in section 3 is backed by exactly one skill. On a FULL drive there
are 16:

  Support (FULL drives only - 8):
    assist-intake, kb-builder, draft-writer, hotline-ticket,
    escalation-packet, forge-audit, fault-logging, training-guide
  Shared (every drive - 8):
    sales-assist, web-navigator, menu, manual, flush, switch,
    kyocera-research, daily-brief

To list what YOUR drive actually loaded, type inside a session:

    hermes skills list --source local

Every skill should say enabled. You can also just look in the
`.hermes/skills/` folder - one subfolder per skill.

Where they come from: masters live in `skills-source/` (tsc-only/ and
shared/). At every launch, the launcher copies the right set for your
drive's mode into `.hermes/skills/`. So: edit masters in skills-source/,
never the copies in .hermes/skills/ - those get overwritten at launch.

---

## 8. How to add a new skill

THE RULE FIRST: skill files are locked. North Forge itself is forbidden
from writing or rewriting them. New skills and edits go through Kenneth
(the Blacksmith) for approval. What follows is the mechanical process once
content is approved.

Step 1. Make a folder under `skills-source/`:
        - `skills-source/shared/<name>/` if every drive should have it
        - `skills-source/tsc-only/<name>/` if FULL drives only

Step 2. Inside it, create a file named exactly `SKILL.md` that STARTS with
        this block (the three dashes matter):

            ---
            name: mycommand
            description: One plain sentence saying what this does
            ---

        The `name:` value becomes the slash command (/mycommand). It must
        be unique - check section 3 for taken names. Without this block,
        Hermes registers the folder name instead of your command.

Step 3. Below the block, write the instructions in plain English: when it
        triggers, what to do, what the output looks like. Copy the shape
        of an existing SKILL.md - `skills-source/shared/flush/SKILL.md` is
        the shortest example.

Step 4. Relaunch the drive (`launch-north-forge.bat` / `.sh`). The
        launcher copies it in and trusts it.

Step 5. Verify: type `hermes skills list --source local` - your skill
        should appear, enabled. Then try the command.

If it does NOT appear: make sure the file is named SKILL.md exactly, the
`---` block is at the very top, and the name isn't already taken. One
known trap: if the SKILL.md text contains certain agent-config filenames
as literal words, Hermes's safety scanner hides the skill from the list.

Step 6. If it's a keeper, commit it to git so it survives on every clone.

---

## 9. When something goes wrong

  North Forge gave a wrong answer / old ticket leaked in:  /log
  Screen full of a dead ticket's context:                  /flush
  Totally lost, wrong mode:                                /switch
  A command says "Unknown command":  you used an alternate word with a
    slash. Use the ONE real slash form from section 3, or type the word
    without the slash.
  Session won't start / API errors:  check `.env` has a real API key,
    then run `hermes doctor` from a terminal in this folder.
  Anything else: describe the problem in plain English. That is always
    a valid move.

---

## 10. Cheat sheet (print this bit)

  Start work:        just type the problem
  See commands:      /menu
  Fix a machine:     /assist
  Write it up:       /kb  -> then /audit
  Ticket note:       /hl  -> then /flush
  Email/message:     /draft
  Escalate:          /esc
  Learn slowly:      /train
  Site links:        /web
  Sales specs:       /sales
  New ticket:        /flush
  New kind of task:  /switch
  North Forge bug:   /log
  NEVER:             /clear, /reset, /initialize
