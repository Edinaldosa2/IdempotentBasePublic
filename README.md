<p align="center">
  <img src="img/Banner.png" alt="IdempotentBase — database schema comparison, idempotent migration, synchronization and backup for SQL Server, PostgreSQL, MySQL, MariaDB and Oracle">
</p>

# IdempotentBase

**Safe schema reconciliation, database migration and backup for Windows — built for DBAs and DevOps teams.**

IdempotentBase is a **.NET / WPF** desktop tool for **database schema comparison**, **idempotent SQL script generation**, **DEV ↔ PROD synchronization**, and **native SQL Server backup** — without destructive surprises.

Compare SQL Server, PostgreSQL, MySQL, MariaDB, and Oracle schemas. Generate safe, repeatable migration scripts. Protect production with a built-in safety model designed for real-world DBA workflows.

> **Topics:** `sqlserver` · `database` · `migration` · `idempotent` · `schema` · `backup` · `devops` · `dotnet` · `wpf` · `dba` · `database-tools` · `synchronization` · `ai`

---

## Table of Contents

- [Download and Run](#download-and-run-recommended)
- [Clone from Git](#clone-from-git-alternative)
- [First Connection](#first-connection)
- [Why IdempotentBase](#why-idempotentbase)
- [Workflows](#workflows)
- [Supported Providers](#supported-providers)
- [Key Features](#key-features)
- [Safety Model](#safety-model)
- [Requirements](#requirements)
- [Reconciliation Workflow](#reconciliation-workflow)
- [Backup Workflow](#backup-workflow)
- [Connection Storage](#connection-storage)
- [Repository Layout](#repository-layout)
- [Releases](#releases)
- [Limitations](#limitations)
- [Documentation](#documentation)
- [License](#license)

---

## Download and Run (recommended)

1. Install [.NET Framework 4.8](https://dotnet.microsoft.com/download/dotnet-framework/net48) if it is not already on your machine.
2. Download **IdempotentBase-v1.0.0-win-x64.zip** from [GitHub Releases](https://github.com/Edinaldosa2/IdempotentBasePublic/releases).
3. Extract the ZIP anywhere (for example `C:\Tools\IdempotentBase\`).
4. Run the application:

```powershell
.\app\IdempotentBase.exe
```

The ZIP includes the executable, dependencies, documentation, and connection samples — everything needed to run the app.

---

## Clone from Git (alternative)

If you prefer to clone this repository instead of downloading the release ZIP:

```powershell
git clone https://github.com/Edinaldosa2/IdempotentBasePublic.git
cd IdempotentBasePublic
.\app\IdempotentBase.exe
```

No build step is required. The `app/` folder contains the ready-to-run distribution.

---

## First Connection

You can connect to a database in two ways:

**Option A — Use the UI (recommended)**

1. Launch `app\IdempotentBase.exe`.
2. Choose your database engine on the home screen.
3. Fill in host, port, database, and credentials.
4. Check **Save connection** to persist settings locally.

**Option B — Start from a sample file**

Copy a sample file and edit it with your connection details:

```powershell
Copy-Item database\sqlserver\connections.sample.json database\sqlserver\connections.json
```

Replace placeholder values in `connections.json`. Sample files contain no real credentials.

Saved connections are stored under `database/{provider}/connections.json` (relative to the app folder). These files are local to your machine and must never be committed to git.

---

## Why IdempotentBase

Schema drift between DEV and PROD is one of the most common sources of deployment risk. Manual scripts are error-prone; full synchronization tools are often too aggressive.

IdempotentBase takes a different approach:

- **DEV is always the source of truth**; PROD is the target.
- Differences are classified by safety before any SQL is generated.
- Generated scripts are **idempotent** — safe to run more than once.
- Destructive operations are **blocked by default** at comparison, generation, analysis, and UI layers.

---

## Workflows

The home screen lets you choose what you want to do before selecting a database engine.

| Workflow | Purpose |
|----------|---------|
| **Reconcile** | Compare DEV vs PROD schemas, generate idempotent scripts, export reports, apply safe changes |
| **Backup** | Connect to a single database and run a native backup (SQL Server implemented; other engines planned) |

```
Choose database  →  Reconcile or Backup  →  Connect  →  Compare / Run Backup
```

---

## Supported Providers

| Provider | Connection | Schema scan & compare | Script generate & apply | Backup |
|----------|:----------:|:---------------------:|:-----------------------:|:------:|
| SQL Server | Yes | Yes | Yes | Yes |
| PostgreSQL | Yes | Yes | Yes | Planned |
| MySQL | Yes | Yes | Yes | Planned |
| MariaDB | Yes | Yes | Yes | Planned |
| Oracle | Yes | Yes | Yes | Planned |
| SQLite | Yes | Coming Soon | Coming Soon | Planned |
| MongoDB | Coming Soon | Coming Soon | Coming Soon | N/A |

MariaDB reuses the MySQL provider stack internally. MongoDB is visible in the UI as **Coming Soon** because the relational reconciliation model does not map directly to document stores.

---

## Key Features

### Provider selection

- Home screen with database cards, logos, and **Available** / **Coming Soon** badges
- Active provider shown in the application header
- **Back** navigation to change provider without restarting

### Professional connections

- DBeaver-style panels per engine: host, port, database, authentication, SSL/encrypt options
- SQL Server: Windows/SQL auth, encrypt modes, trust certificate, Advanced settings
- PostgreSQL: SSL mode; MySQL/MariaDB: charset and SSL; Oracle: Service Name, SID, or TNS
- Connection string preview tab with masked passwords
- **Save connection** per environment, stored under `database/{provider}/`
- **Refresh** to load database list from the server

### Schema reconciliation

- Catalog metadata read into normalized `DatabaseSnapshot` objects
- Compare tables, columns, keys, indexes, constraints, views, procedures, functions, triggers, sequences
- SQL Server uses version-aware `sys.*` queries (compatible with SQL Server 2012+)
- Safety classification: `SAFE_AUTO`, `REVIEW_REQUIRED`, `DESTRUCTIVE_BLOCKED`, `INFO_ONLY`
- Idempotent script generation per dialect
- Export Markdown, HTML, and JSON reports
- Save JSON snapshots
- Apply scripts to PROD with confirmation dialog, transaction wrapper, and audit history

### Database backup (SQL Server)

- Single-connection backup workflow (no DEV/PROD split)
- Native `BACKUP DATABASE TO DISK`
- Configurable output folder with **Browse** picker
- Optional compression (auto-fallback when edition does not support it)
- Default path: `%LOCALAPPDATA%\IdempotentBase\backups\{provider}\`
- Output file pattern: `{Database}_{yyyyMMdd_HHmmss}.bak`

---

## Safety Model

IdempotentBase is **not** a destructive synchronization tool.

| Rule | Behavior |
|------|----------|
| No silent drops | `DROP TABLE`, `DROP COLUMN`, and similar patterns are blocked |
| No shrink operations | Column size reductions are never auto-applied |
| Classification first | Every difference receives a safety label before scripting |
| Script analysis | Generated SQL is scanned for forbidden patterns |
| Apply gate | PROD apply requires tested connection, backup confirmation, and typed database name |

**Always take a verified backup before applying any script to production.**

See [docs/safety-rules.md](docs/safety-rules.md) for the full rule set.

---

## Requirements

| Component | Version |
|-----------|---------|
| OS | Windows 10 or later |
| Runtime | [.NET Framework 4.8](https://dotnet.microsoft.com/download/dotnet-framework/net48) |
| Databases | SQL Server, PostgreSQL, MySQL, or Oracle instance for testing |

All database drivers are bundled with the application. No separate driver installation is required.

---

## Reconciliation Workflow

1. Open the app → **Choose your database** → select an engine (e.g. PostgreSQL).
2. Ensure **Reconcile** is selected in the workflow switcher.
3. Configure **DEV (Source)** and **PROD (Target)** connections.
4. Click **Connect DEV** and **Connect PROD**.
5. Review connection info (server, database, version, user, permission).
6. Click **Compare Databases**.
7. Wait for the scan to finish → **Show Result**.
8. Filter differences, **Generate Idempotent Script**, review preview.
9. **Save Script .sql** or **Apply to Target Database** (after backup confirmation).

Use **← Back** to return to provider selection.

---

## Backup Workflow

1. Open the app → **Choose your database** → select **SQL Server**.
2. Select **Backup** in the workflow switcher.
3. Configure the database connection (server, auth, database name).
4. Set **Backup folder** (type a path or click **Browse...**).
5. Optionally enable **Use compression (SQL Server)**.
6. Click **Connect**.
7. Click **Run Backup**.
8. Confirm the `.bak` file path and size in the success dialog.

Backups are written to the folder you chose. The default folder is created automatically under `%LOCALAPPDATA%\IdempotentBase\backups\sqlserver\`.

---

## Connection Storage

Saved connections are stored per provider when **Save connection** is checked:

```
database/
  sqlserver/connections.json
  postgresql/connections.json
  mysql/connections.json
  mariadb/connections.json
  oracle/connections.json
  sqlite/connections.json
```

Sample files (no secrets):

| Provider | Sample |
|----------|--------|
| SQL Server | [database/sqlserver/connections.sample.json](database/sqlserver/connections.sample.json) |
| PostgreSQL | [database/postgresql/connections.sample.json](database/postgresql/connections.sample.json) |
| MySQL | [database/mysql/connections.sample.json](database/mysql/connections.sample.json) |
| MariaDB | [database/mariadb/connections.sample.json](database/mariadb/connections.sample.json) |
| Oracle | [database/oracle/connections.sample.json](database/oracle/connections.sample.json) |
| SQLite | [database/sqlite/connections.sample.json](database/sqlite/connections.sample.json) |
| MongoDB | [database/mongodb/connections.sample.json](database/mongodb/connections.sample.json) |

`connections.json` files contain credentials and are never included in this repository.

---

## Repository Layout

This repository is a **ready-to-run distribution package**, not a development workspace.

```
IdempotentBasePublic/
├── app/          Executable, DLLs, assets, and embedded connection samples
├── database/     Connection samples (copy to connections.json locally)
├── docs/         Architecture, safety rules, metadata, roadmap
├── util/         Maintainer build scripts (not needed to run the app)
└── releases/     Local ZIP output for GitHub Releases (not tracked in git)
```

Architecture details: [docs/architecture.md](docs/architecture.md)

---

## Releases

Official downloads are published on [GitHub Releases](https://github.com/Edinaldosa2/IdempotentBasePublic/releases).

| Version | Package |
|---------|---------|
| v1.0.0 | `IdempotentBase-v1.0.0-win-x64.zip` |

The ZIP is built locally into `releases/` by maintainers and uploaded to GitHub Releases manually. It is not stored in git.

To rebuild or publish a new version, see [util/README.md](util/README.md).

---

## Limitations

- Backup is implemented for **SQL Server** only; other providers show a not-supported message
- SQLite: connection works; schema scan/compare is Coming Soon
- MongoDB: UI placeholder only; document-store reconciliation is not designed yet
- No automatic data migration or seed synchronization
- FK/PK creation may fail when existing data violates constraints
- Cross-edition and cross-dialect feature gaps may require manual review
- Module comparison uses normalized definition hashes (whitespace/comments ignored)
- Extended properties and permissions are informational or review-only

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Multi-provider design, data flow, extension points |
| [docs/safety-rules.md](docs/safety-rules.md) | Classification rules and blocked operations |
| [docs/sqlserver-metadata.md](docs/sqlserver-metadata.md) | SQL Server catalog coverage |
| [docs/roadmap.md](docs/roadmap.md) | Planned features |

---

## License

MIT License. See [LICENSE](LICENSE).

---

## Author

[Edinaldosa2](https://github.com/Edinaldosa2)

IdempotentBase is a **safe schema reconciliation assistant**. It helps you understand drift, generate conservative SQL, and protect production — not replace your DBA judgment.
