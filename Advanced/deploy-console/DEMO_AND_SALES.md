# For the person funding this — demo and sales

You pay. Engineering builds. This page is what *you* need to run a
room without living in Git.

## What you are selling

A portable technical-support agent on a stick. The technician speaks
ordinary English. The stick already knows the shop. It is **North Forge**,
running **in cooperation with Hermes Agent**. Hermes is the engine and
keeps its name. North Forge is the coworker.

You are not selling a chatbot skin. You are selling a desk that travels.

## Two rooms, two sticks

| In the bag | Label | Show this |
|---|---|---|
| Master | `BLACK-NORTH` | You. Full lab later (Pinokio). |
| Greg / first buyer-supervisor | `GREGW-NOREX` | The stick they can hold. |

Until those two answer a live question, do not schedule a tour of
Pinokio, servers, or extra models.

## Demo script (eight minutes)

1. Plug `GREGW-NOREX` in. Point at the letter if it changed. That is
   normal. Say so first so nobody thinks it broke.
2. Double-click **Terminal**. Wait if it says repair once.
3. Paste a real call, not a toy:
   `TASKalfa 3554ci F248 after printing`
   Let it talk like a tech. If it hedges and asks for a log, that is a
   feature. Point at it.
4. Optional: **Web Interface**. Env and Models are Hermes — keys and
   brains. Theme should read forge-gold on dark iron, caption
   "North Forge · in cooperation with Hermes Agent" next to the Hermes
   wordmark. If the caption is missing, the pack did not land; still
   demo Terminal.
5. Do not open Advanced. Do not type `hermes`. Do not explain PATH.
6. Stop talking. Ask them what *their* last bad call was. Type that.

If the window will not answer: key is missing. That is a five-minute
fix (`Set-Inference.ps1` or dashboard Env), not a failed product.

## Sales boundaries (say them)

- Public download = Hermes + North Forge name. No Kyocera private well.
- Private edition = the well + locksmith + your drive class.
- Custom for Sharp / Ricoh / Xerox is a **funded pack**, not a toggle.
- Playground (image/video via Pinokio) is the master lab, one or two
  models on USB, or a GPU box. Not on Greg's stick.
- Monetization comes after Greg uses it for real tickets.

## Visual — done vs later

**Done now**
- Theme `north-forge-kyocera` (gold on iron).
- Header caption names North Forge first, Hermes as partner.
- Hermes wordmark retained (engine requirement).

**Look in a browser once (you)**
- Confirm the gold caption sits *beside or above* the wordmark, not
  buried in a hidden tab.
- If it sits in the wrong slot, screenshot it. Slot is `header-left`.
  Moving it above the wordmark may need a Hermes core change. Do not
  fork `web/src` for vanity.

**Later, if you fund it**
- Custom mark in the sidebar (theme `assets.logo` already exists).
- Cockpit layout (`layoutVariant`) — larger design pass.
- Drive-class picker inside Hermes Config — not required to sell Greg.

## Cleanup I will not do in a sweep

The two repos are large. A "clean the entire codebase" pass is a
separate paid week, not a demo blocker. Dead sibling folders on D:
wait for your delete-yes. Do not mix that into a sales meeting.

## Your checklist before a meeting

- [ ] `GREGW-NOREX` answers one real code in Terminal
- [ ] You can plug it into a second PC without panic
- [ ] Key is on the stick (Env or Set-Inference)
- [ ] HOW_TO_START is the only paper they keep
- [ ] You can say "North Forge, in cooperation with Hermes" in one breath
