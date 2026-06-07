# Safety Rules

## Principle

**Never execute destructive changes automatically.**

## Classifications

| Classification | Meaning |
|----------------|---------|
| SAFE_AUTO | Safe to include in generated idempotent script |
| REVIEW_REQUIRED | Reported and commented in script; not auto-executed |
| DESTRUCTIVE_BLOCKED | Exists only in PROD or would shrink/destroy schema; blocked |
| INFO_ONLY | Informational difference only |

## SAFE_AUTO (examples)

- Create missing schema
- Create missing table
- Add nullable missing column
- Add NOT NULL column with default
- Widen VARCHAR/NVARCHAR/CHAR/NCHAR size
- Create missing index (non-PK)
- Create missing default constraint
- Create or update view/procedure/function/trigger via CREATE OR ALTER

## REVIEW_REQUIRED (examples)

- Add NOT NULL column without default on table that may contain data
- Change column data type
- Change nullability
- Change identity or computed column
- Change collation
- Modify existing PK, FK, index, or constraint
- Create foreign key without data validation

## DESTRUCTIVE_BLOCKED (examples)

- Drop table
- Drop column
- Object exists in PROD but not DEV
- Reduce column size
- Reduce decimal precision
- Drop index, view, procedure, or function automatically

## Script Safety

Generated scripts include:

- `SET XACT_ABORT ON`
- `BEGIN TRY` / `BEGIN CATCH`
- `BEGIN TRANSACTION` / `COMMIT` / `ROLLBACK`
- `dbo.__IdempotentBaseHistory` bootstrap
- SHA-256 script hash deduplication

## Apply Gate

Before applying to PROD:

1. Full script preview
2. Backup confirmation checkbox
3. User must type exact target database name
4. PROD connection must have been tested
5. User must have schema alteration permissions
