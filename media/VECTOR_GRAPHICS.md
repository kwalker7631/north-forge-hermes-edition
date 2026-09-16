# Vector graphics on the stick

Use SVG when the picture must stay sharp at any size: architecture,
flow, wiring *style* diagrams, booklet pages, GitHub README figures.
Use PNG/JPEG when it is evidence: a panel, a cracked frame, a log crop.

Hermes already treats `.svg` as an image it can attach in gateway chat.
Drag an SVG into Files the same way as a PNG.

## Where it lives

| File | Folder |
|---|---|
| Shop-wall diagram you drew (paper path, block flow) | `Docs\` or `IMG\diagrams\` |
| Panel photo, error screen | `IMG\` raster |
| Pack architecture (Mermaid in ARCHITECTURE.md) | Git — renders on GitHub |
| Community-safe diagram (no customer, no site) | Knight push |

## Why SVG

- Scales for 8.5×11 booklet and a phone preview.
- Diffable-ish in Git if it is pack-owned (keep it small, no 4 MB inkscape soup).
- Print: Kyocera booklet imposition wants clean line art more than a noisy photo.
- The model can be told "see Docs/paper-path.svg" the same as a PDF page.

## Why not everything SVG

A vector tracing of a TASKalfa panel is a pretty lie. The fault is in the
pixels. Keep the photo. Do not let an image-gen app invent a wiring diagram
and call it factory.

## How we draw them

1. Mermaid in markdown for pack architecture (already in ARCHITECTURE.md).
2. Hand SVG or Inkscape for a stable shop diagram you will reuse.
3. Hermes `execute_code` / a diagram skill if a knight needs a one-off chart.
4. Pinokio node graphs stay in the lab — export a PNG/SVG *into Docs* only
   if it is a training aid you sanitized.

## Query rule (same as FIELD_LIBRARY)

Code with no public page → Docs PDF first, then SVG/diagram if present.
If the file is SVG, describe the labels you can read. Do not invent a
connector that is not in the file.
