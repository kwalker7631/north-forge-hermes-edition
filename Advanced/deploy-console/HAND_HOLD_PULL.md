# Hand-hold — update the pack on an existing stick

You are not writing code. You are refreshing two Git folders on a USB.
If Kenneth is not here, do not improvise. If a step fails, stop and write
down the exact red text.

Windows. Admin PC. Stick plugged in. Note the letter (D: or F: or E:).
Below, that letter is written as `X:`. Replace it every time.

## Where things must live

The private pack is **inside** the public engine. Not next to it.

```
X:\north-forge-agent\                          public engine (north-forge-agent)
X:\north-forge-agent\private-editions\kyocera\   THIS is north-forge-hermes-edition
X:\north-forge-agent-venv\
X:\north-forge-agent-data\
```

If you see `X:\north-forge-hermes-edition\` at the **root** of the stick,
that is the old sibling layout. Do not pull there unless Kenneth said
this stick is still sibling. Prefer the nested path above.

## Once on this PC (skip if already done)

1. Git for Windows installed.
2. GitHub CLI installed.
3. Open PowerShell and run:

```
gh auth login
```

GitHub.com → HTTPS → Yes → login in the browser. Use the account that
can see **kwalker7631/north-forge-hermes-edition** (private).

Check:

```
gh repo view kwalker7631/north-forge-hermes-edition
```

If that 404s, you are on the wrong GitHub user. Stop.

## Pull — copy and paste, then change X:

Open PowerShell.

```
$X = 'X:'   # change to the real letter

# 1) Public engine
cd $X\north-forge-agent
git status
git pull origin main

# 2) Private pack MUST be this folder
cd $X\north-forge-agent\private-editions\kyocera
git remote -v
git status
git pull origin main
```

`git remote -v` on step 2 must show:
`kwalker7631/north-forge-hermes-edition`

If remote says `north-forge-agent` instead, you are in the wrong folder.
`cd` again. Do not pull.

## If private-editions\kyocera does not exist

Do **not** clone to `X:\north-forge-hermes-edition`.

```
$X = 'X:'
cd $X\north-forge-agent
mkdir private-editions -ErrorAction SilentlyContinue
gh repo clone kwalker7631/north-forge-hermes-edition private-editions\kyocera
```

That is the only clone destination.

## After a successful pull

1. Eject is not required yet.
2. Double-click **Start North Forge** on `X:`.
3. First launch may say repair once. Wait until it is ready.
4. Ask one dummy question. If it answers, you are done.
5. Keys are not in Git. If it launches but will not answer, run:

```
$X = 'X:'
cd $X\north-forge-agent\private-editions\kyocera\Advanced\deploy-console
.\Set-Inference.ps1 -Provider anthropic -Key 'PASTE_KEY'
```

Or open **Web Interface** → Env → paste the key (Hermes dashboard).

## Do not

- Type the word `hermes` in a terminal to "test."
- `git pull` from `X:\` (the drive root is not a repo).
- Clone hermes-edition onto the desktop "to be safe."
- Copy `north-forge-agent-venv` from another stick.
- Format the stick just because pull printed a lot of file names.
- Change System Path.

## Labels (when you build a *new* stick)

| Who | Volume label |
|---|---|
| Master | BLACK-NORTH |
| Greg (Excalibur) | GREGW-NOREX |
| Standard person | FIRSTNAME + last initial + NORTH |
| Basic | BASIC-NORTH |

A pull does not rename the volume. Label is set at format time.

## If git status says you have local changes

Stop. Do not `git reset --hard` unless Kenneth said to throw local work
away. Write down `git status` and call him.

## What "done" looks like

```
X:\north-forge-agent                  git log -1   (recent main)
X:\north-forge-agent\private-editions\kyocera
                                      git log -1   (includes HAND_HOLD_PULL.md)
Start North Forge                     window opens, answers one question
```
