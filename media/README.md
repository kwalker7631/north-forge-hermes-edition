# Media on the stick (not in Git)

At deploy, create these folders at the **volume root** (or under
`north-forge-agent-data\library\`). They hold files that must not go to
GitHub (customer PDFs, photos, voice clips).

```
Docs\     PDFs, service notes you are allowed to keep
IMG\      photos, panel shots, dragged evidence
audio\    short clips, dictated notes
```

Hermes `document-search` + FTS5 can index what lives here once a knight
points the skill at this tree. Do not commit the files. Only this README
and the policy ride in the pack.
