# Who gets which tasks

Hermes now ships a large skill catalog (200+). North Forge does not.
If we install the catalog onto every stick, future task work becomes
archaeology: nobody knows what Greg can actually run.

Decide inclusion **at build time** by drive class. The admin console
may *author* tasks. Only BLACK-NORTH receives the authoring set.

## Packs (build these as folders, not vibes)

| Pack | What it is |
|---|---|
| `tsc-core` | Kyocera desk: hotline, KB, check, humanizer, logs, firmware vs logs doctrine |
| `penny` | Pocket Penny — conversation budget only. No tax/report until those exist. |
| `pbf` | Pine Barron Farms — persona + canon. No image pipeline until it exists. |
| `nf-three` | The three tools that ride on a plain North Forge + Hermes face |
| `lab` | Pinokio, playground models, extra generators |
| `author` | Task-builder, locksmith extras, research cron, 52 curated of the 200+ |
| `hermes-extra` | Upstream skills we have not chosen. Default **off**. |

Do not copy `hermes-extra` onto a person stick "in case." Add a skill
to a pack when you have used it twice.

## Class → packs

| Volume | Packs |
|---|---|
| `BLACK-NORTH` (admin / elevated) | tsc-core + penny + pbf + nf-three + lab + author. May browse the 200+. Ships the chosen **52**, not all 200. |
| `FIRSTL-NOREX` (Excalibur, e.g. GREGW-NOREX) | tsc-core + humanizer + nf-three. No lab. No author. No penny/pbf unless that person owns those businesses. Mirrors admin *desk*, not admin *workshop*. |
| `FIRSTL-NORTH` (standard private) | nf-three + only the one line of work they were handed (usually tsc-core). |
| `BASIC-NORTH` | tsc-core minus anything that can change the pack. Humanizer stays. |
| Public North Forge | nf-three + branding. No Kyocera well. No author. |

Penny and Pine Barron are add-on faces. They do not inherit the diverse
admin catalog. A Penny stick that can spawn drives or run Pinokio is a
mistake.

## Humanizer

Required on every TSC-facing stick (BASIC, standard TSC, Excalibur).
That is how the desk stays a coworker instead of a model. Do not strip
it to "save space."

## Early measures (do these before the 53rd task)

1. **One allowlist file per class** (even a text list). Build scripts
   include only names on the list. Today Zero-Touch only drops `pinokio`
   on basic. That is not enough.
2. **Name the 52.** A file `author-pack.txt` with one skill per line.
   If it is not on the list it does not ride BLACK-NORTH either until
   you add it on purpose.
3. **New Hermes skills land in `hermes-extra`.** Promotion to a pack is
   a Blacksmith decision, not an upstream pull.
4. **Task-builder stays on BLACK-NORTH.** Excalibur may *run* finished
   tasks. It may not ship the workshop.
5. **Honest stubs stay.** Penny tax/report and PBF image pipeline say
   "not built." Do not fill those packs with look-alike Hermes skills.
6. **KB / research well is tsc-core**, shared by cloning the pack, not
   by giving every stick author cron.

## Why this is cheaper than cleaning later

Greg's stick should be boring: codes, humanizer, `/hl` `/chk`. If he
has 200 skills, every demo becomes a menu. The facade (Kyocera now,
other makers later) only works if the face is thin and the well is
deep. Depth is content. Width is admin.
