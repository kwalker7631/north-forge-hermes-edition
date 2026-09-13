---
name: document-search
description: Index-aware lookup in dropped reference documents (service manuals, structured PDFs) - locate the section, don't brute-force the whole file
---

# Document Search Skill

Trigger: /docsearch, or a question comes up that no other installed skill covers
and the answer might be sitting in a document someone has dropped as reference
material - a service manual, spec sheet, or other structured PDF. Not for
Kyocera hotline/KB/escalation workflows - those already have their own skills
(`hotline-ticket`, `kb-builder`, `escalation-packet`, etc.); this skill is the
fallback for "is there a document that already answers this."

Never rewrite this skill file on your own initiative. Flag it to the
Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## Where documents live

`Documents/` at the profile root - `<HERMES_HOME>/Documents/` (on this drive,
`north-forge-agent-data/profiles/kyocera/Documents/`). Anyone can drop a PDF
(or other structured doc) in there directly; no import step or catalog entry
required. If the folder is empty or missing, say so plainly and do not answer
from general knowledge instead - the whole point of this skill is "checkable
against a real source."

## Procedure - index first, not brute force

This mirrors how a person actually searches a manual: find the table of
contents, find the right section, read only that. Full-text extraction of an
entire manual is the fallback, never the default - it burns context on
hundreds of irrelevant pages and it's slower than just looking the section up.

1. **List `Documents/`** and pick the file(s) that plausibly cover the
   question (by filename/topic - there is no catalog to query yet).
2. **Check the document's shape first**, don't dive straight into extraction:
   `python scripts/pdf_read.py <file> --meta` (from the bundled `pdf` skill at
   `skills/productivity/pdf/`, one directory up from this one at the profile
   root's `skills/` level) reports page count and a `likely_scanned_pages`
   list. If the pages you'll need are in that list, there is no text layer -
   see "Scanned documents" below before going any further.
3. **Locate the table of contents.** Manuals print their own TOC, almost
   always in the first ~10-15 pages. Pull just that range instead of the
   whole file:
   ```
   python scripts/pdf_split.py <file> --pages 1-15 -o <tmp>/toc.pdf
   python scripts/pdf_read.py <tmp>/toc.pdf --text
   ```
   Read the result for a "Contents"/"Table of Contents" page that maps
   section names to page numbers. (Some PDFs also carry a bookmark/outline
   tree; `pdf_read.py` doesn't currently expose it, so the printed TOC page
   is the reliable path here regardless.)
4. **Extract just the relevant section** using the page range the TOC gave
   you:
   ```
   python scripts/pdf_split.py <file> --pages <start>-<end> -o <tmp>/section.pdf
   python scripts/pdf_read.py <tmp>/section.pdf --text
   ```
   Answer from that text only.
5. **Fall back to full-text search only if there's no usable TOC** - no
   printed contents page and no obvious section structure in the first
   ~15 pages. In that case, `pdf_read.py <file> --text` on the whole
   document is the fallback, not the default.
6. **Always cite what you read**: document filename, section name (from the
   TOC when there was one), and the page range - so the answer is checkable
   against the source, not just asserted.

## Scanned documents (no text layer)

If step 2's `--meta` reports the pages you need as `likely_scanned_pages`,
there is no extractable text and OCR is required first. Use
`references/ocr-extraction.md` in the bundled `pdf` skill (pymupdf fast path,
marker-pdf quality path - both already available, no new install). Tesseract
(`pytesseract` + the Tesseract OCR engine, free) is a documented fallback if
that path ever doesn't cover a specific case, but is not wired up here - only
reach for it against a real document that actually needs it; don't install
anything new speculatively.

## When nothing in Documents/ answers the question

Say so plainly and stop. Don't fabricate an answer from general knowledge
when the user's framing implies "check the manual" - that's a worse outcome
than "I don't have a document for that."
