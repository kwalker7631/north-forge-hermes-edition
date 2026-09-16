# Library vs community

## On the stick (private)

`Docs`, `IMG`, `audio` are **that volume only**. Customer names, ticket
numbers, site photos stay here. Sync does not upload them. Index and
search locally (PDF text first; images later).

## Community (opt-in, knights write)

A separate Git repo or branch — not the customer tree. Knights **push**
only what you would pin on a shop wall:

- sanitized KB drafts already approved
- generic diagrams
- a skill that passed SKILL_POLICY
- a pointer ("use this HF repo"), never a 30 GB weight

Techs and BASIC: **pull only**. Docked + internet → pull community +
pull pack. No push credentials on those sticks.

## Models and "everyone's learning"

Do not dump Pinokio checkpoints or Docker layers into Git. Community
may list *names* of useful models. Weights stay on the lab disk of
whoever pulled them. User-derived knowledge enters the well the way KB
already does: draft → Blacksmith → pack → next pull.

If a docked stick "contributes an AI model," that is a lab copy onto a
share, not `git push`. Knights decide. Advocate can veto.

## Indexing order

1. Local Docs PDFs (text layer).
2. Pack markdown (skills, KB drafts).
3. Community markdown after pull.
4. IMG / audio: captions first; full vision/STT later.
