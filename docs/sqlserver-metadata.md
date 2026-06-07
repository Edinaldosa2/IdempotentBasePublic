# SQL Server Metadata

## Catalog Views

IdempotentBase reads metadata primarily from `sys.*` catalog views:

| Object | Primary Views |
|--------|---------------|
| Server info | `@@VERSION`, `SERVERPROPERTY()` |
| Database info | `sys.databases` |
| Schemas | `sys.schemas` |
| Tables | `sys.tables` |
| Columns | `sys.columns`, `sys.types` |
| Identity | `sys.identity_columns` |
| Primary/Unique keys | `sys.key_constraints`, `sys.indexes`, `sys.index_columns` |
| Foreign keys | `sys.foreign_keys`, `sys.foreign_key_columns` |
| Indexes | `sys.indexes`, `sys.index_columns` |
| Check constraints | `sys.check_constraints` |
| Default constraints | `sys.default_constraints` |
| Modules | `sys.objects`, `sys.sql_modules` |
| Parameters | `sys.parameters` |
| Sequences | `sys.sequences` |
| Synonyms | `sys.synonyms` |
| User-defined types | `sys.types` |
| Extended properties | `sys.extended_properties` |

## Why Not INFORMATION_SCHEMA?

Microsoft documentation notes that `INFORMATION_SCHEMA` exposes only a subset of SQL Server metadata. `sys.*` views provide complete and reliable schema discovery.

## NVARCHAR Length Note

For Unicode types (`nvarchar`, `nchar`), `sys.columns.max_length` is stored in **bytes**.

Example: `NVARCHAR(100)` appears as `max_length = 200`.

IdempotentBase converts byte length to character length in `ColumnTypeComparer` before comparison and script generation.

## Module Comparison

Procedure, view, function, and trigger bodies are normalized before hashing:

- Whitespace and line endings normalized
- Comments stripped for comparison
- String literals preserved (no blind uppercasing)

Comparison uses SHA-256 of normalized definition text.
