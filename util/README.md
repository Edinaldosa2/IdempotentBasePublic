# IdempotentBase Public — Build Utilities

Scripts in this folder build the **public distribution package** from the development repository without modifying `C:\Projetos\IdempotentBase`.

## Prerequisites

- Windows 10 or later
- [.NET Framework 4.8 Developer Pack](https://dotnet.microsoft.com/download/dotnet-framework/net48)
- .NET SDK (for `dotnet publish`)
- Development repo at `C:\Projetos\IdempotentBase`

## Quick build

```powershell
powershell -ExecutionPolicy Bypass -File C:\Projetos\IdempotentBasePublic\util\build-release.ps1
```

## Build with versioned ZIP

```powershell
powershell -ExecutionPolicy Bypass -File C:\Projetos\IdempotentBasePublic\util\build-release.ps1 -Version "1.0.0"
```

Output ZIP: `C:\Projetos\IdempotentBasePublic\releases\IdempotentBase-v1.0.0-win-x64.zip`

## Test the app

```powershell
& "C:\Projetos\IdempotentBasePublic\app\IdempotentBase.exe"
```

## Clean generated files

```powershell
powershell -ExecutionPolicy Bypass -File C:\Projetos\IdempotentBasePublic\util\clean-release.ps1
```

## Output layout

```
IdempotentBasePublic/
  app/              IdempotentBase.exe + dependencies
  docs/             copied from dev repo
  database/         connection samples only
  README.md
  LICENSE
  releases/         optional ZIP (not in git)
  util/             these scripts
```

---

## Release workflow

Use this sequence for every public release:

1. Develop and test in `C:\Projetos\IdempotentBase`.
2. Build the public package:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Projetos\IdempotentBasePublic\util\build-release.ps1 -Version "X.Y.Z"
```

3. Test the executable:

```powershell
& "C:\Projetos\IdempotentBasePublic\app\IdempotentBase.exe"
```

4. If `app/` or docs changed, commit in `IdempotentBasePublic`.
5. Tag the release (`vX.Y.Z`).
6. Push to GitHub (when ready).
7. Create a GitHub Release and attach `releases\IdempotentBase-vX.Y.Z-win-x64.zip`.

---

## Pre-commit checklist

Before every commit in this repository, confirm:

- [ ] `app\IdempotentBase.exe` exists
- [ ] `app\IdempotentBase.exe.config` exists
- [ ] No `*.pdb` files in `app\`
- [ ] No `connections.json` in `database\` or `app\database\` (only `*.sample.json`)
- [ ] `releases\` is listed in `.gitignore` and not staged
- [ ] `README.md`, `LICENSE`, and `docs\` are present at the repo root
- [ ] `util\` contains `build-release.ps1`, `clean-release.ps1`, and this file

Quick verification:

```powershell
cd C:\Projetos\IdempotentBasePublic
Test-Path app\IdempotentBase.exe
Test-Path app\IdempotentBase.exe.config
Get-ChildItem app -Filter *.pdb -Recurse
Get-ChildItem database,app\database -Filter connections.json -Recurse -ErrorAction SilentlyContinue
git status
```

---

## Git commands

Initialize (first time only):

```powershell
cd C:\Projetos\IdempotentBasePublic
git init
git branch -M main
git remote add origin https://github.com/Edinaldosa2/IdempotentBasePublic.git
```

Stage and commit (use `-c` flags to set author without changing global git config):

```powershell
git add .gitignore README.md LICENSE docs database app util
git status
```

Confirm that `releases/`, `connections.json`, `*.pdb`, and `*.zip` are **not** staged.

```powershell
git -c user.name="Edinaldosa2" -c user.email="63486082+Edinaldosa2@users.noreply.github.com" commit -m "Release: IdempotentBase vX.Y.Z public distribution package"
git log -1 --format=full
git log -1 --format=%B
```

Verify: author is **Edinaldosa2**, and the commit message contains no `Co-authored-by` lines.

Tag a release:

```powershell
git -c user.name="Edinaldosa2" -c user.email="63486082+Edinaldosa2@users.noreply.github.com" tag -a vX.Y.Z -m "IdempotentBase X.Y.Z"
```

Push (only when explicitly requested):

```powershell
git push -u origin main
git push origin vX.Y.Z
```

Then upload the ZIP from `releases\` to the matching GitHub Release.

---

## What goes in git

| Path | In git? | Reason |
|------|---------|--------|
| `app/` | Yes | Ready-to-run product |
| `docs/` | Yes | Documentation |
| `database/*.sample.json` | Yes | Examples without secrets |
| `util/` | Yes | Rebuild scripts |
| `README.md`, `LICENSE` | Yes | Project identity |
| `releases/*.zip` | No | Large binary → GitHub Releases |
| `connections.json` | No | Credentials |
| `*.pdb`, logs, `.env` | No | Debug/runtime local data |

Do **not** commit `database/**/connections.json` or real credentials.

## GitHub SEO (description + topics)

After changing the repository focus or keywords, refresh the GitHub About section:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Projetos\IdempotentBasePublic\util\set-github-seo.ps1
```

This sets the repository description and topics (`sqlserver`, `database`, `migration`, `idempotent`, `schema`, `backup`, `devops`, `dotnet`, `wpf`, `dba`, `database-tools`, `synchronization`, `ai`).
