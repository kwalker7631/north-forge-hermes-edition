KB image intake - staging area only.

One folder per KB number (e.g. KB0012660/) holding the actual image files
a tech provides or generates while working that KB. Images provided before
a KB number exists go in _pending/<date>_<short-slug>/ and get renamed to
the real KB number once assigned.

This does NOT auto-generate or substitute any HTML image link. Attaching
images in ServiceNow and replacing the KB body's image placeholders stays
a manual step, by design. Filenames are sequence-prefixed and descriptive
(01_tray2-baffle-location.png) and never contain customer, technician,
dealer, or ticket-number text.
