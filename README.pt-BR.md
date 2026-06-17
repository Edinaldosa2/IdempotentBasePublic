<p align="center">
  <img src="img/Banner.png" alt="IdempotentBase — comparação de schema, migração idempotente, sincronização e backup de banco de dados" width="100%">
</p>

<p align="center">
  <strong>US</strong> <a href="README.md">English</a> |
  <strong>BR</strong> <a href="README.pt-BR.md">Português</a>
</p>

<p align="center">
  <a href="https://github.com/Edinaldosa2/IdempotentBasePublic/releases"><img src="https://img.shields.io/github/v/release/Edinaldosa2/IdempotentBasePublic?label=release&color=0066cc" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="Licença"></a>
  <a href="https://dotnet.microsoft.com/download/dotnet-framework/net48"><img src="https://img.shields.io/badge/.NET%20Framework-4.8-512BD4" alt=".NET Framework 4.8"></a>
  <img src="https://img.shields.io/badge/platform-Windows-0078D6" alt="Windows">
  <img src="https://img.shields.io/badge/sqlserver-database%20tools-orange" alt="Ferramentas de Banco">
  <a href="https://github.com/Edinaldosa2"><img src="https://img.shields.io/badge/author-Edinaldosa2-blue" alt="Autor"></a>
</p>

# IdempotentBase

**Reconciliação segura de schema, migração cross-provider e backup de banco de dados para Windows — feito para DBAs e equipes DevOps.**

IdempotentBase é uma ferramenta desktop **.NET / WPF** para **comparação de schema**, **geração de scripts SQL idempotentes**, **sincronização DEV ↔ PROD**, **migração entre providers** e **backup nativo do SQL Server** — sem surpresas destrutivas.

Compare schemas de SQL Server, PostgreSQL, MySQL, MariaDB e Oracle. Gere scripts de migração seguros e repetíveis. Exporte DDL cross-provider e scripts INSERT em lotes. Proteja produção com um modelo de segurança pensado para o dia a dia do DBA.

---

## Índice

- [Download e execução](#download-e-execução)
- [Clonar do Git](#clonar-do-git)
- [Primeira conexão](#primeira-conexão)
- [Workflows](#workflows)
- [Providers suportados](#providers-suportados)
- [Recursos principais](#recursos-principais)
- [Modelo de segurança](#modelo-de-segurança)
- [Requisitos](#requisitos)
- [Workflow de reconciliação](#workflow-de-reconciliação)
- [Workflow de migração](#workflow-de-migração)
- [Workflow de backup](#workflow-de-backup)
- [Armazenamento de conexões](#armazenamento-de-conexões)
- [Layout do repositório](#layout-do-repositório)
- [Releases](#releases)
- [Documentação](#documentação)
- [Licença](#licença)

---

## Download e execução

1. Instale o [.NET Framework 4.8](https://dotnet.microsoft.com/download/dotnet-framework/net48), se ainda não tiver.
2. Baixe **IdempotentBase-v1.0.2-win-x64.zip** em [GitHub Releases](https://github.com/Edinaldosa2/IdempotentBasePublic/releases).
3. Extraia em qualquer pasta (ex.: `C:\Tools\IdempotentBase\`).
4. Execute:

```powershell
.\app\IdempotentBase.exe
```

O ZIP inclui executável, dependências, documentação e samples de conexão.

---

## Clonar do Git

```powershell
git clone https://github.com/Edinaldosa2/IdempotentBasePublic.git
cd IdempotentBasePublic
.\app\IdempotentBase.exe
```

Não é necessário compilar. A pasta `app/` já contém a distribuição pronta.

---

## Primeira conexão

**Opção A — Pela interface (recomendado)**

1. Abra `app\IdempotentBase.exe`.
2. Escolha o engine de banco na tela inicial.
3. Preencha host, porta, banco e credenciais.
4. Marque **Save connection** para salvar localmente.

**Opção B — A partir de um sample**

```powershell
Copy-Item database\sqlserver\connections.sample.json database\sqlserver\connections.json
```

Substitua os valores de exemplo. Os arquivos sample não contêm credenciais reais.

---

## Workflows

| Workflow | Propósito |
|----------|-----------|
| **Reconcile** | Comparar schemas DEV vs PROD, gerar scripts idempotentes, exportar relatórios |
| **Migrate** | Exportação cross-provider de schema e dados — DDL alvo e INSERTs em lotes |
| **Backup** | Backup nativo em banco único (SQL Server implementado) |

```
Escolher banco  →  Reconcile, Migrate ou Backup  →  Conectar  →  Comparar / Exportar / Backup
```

---

## Providers suportados

| Provider | Conexão | Scan & compare | Script generate & apply | Migrate cross-provider | Backup |
|----------|:-------:|:--------------:|:-----------------------:|:----------------------:|:------:|
| SQL Server | Sim | Sim | Sim | Sim | Sim |
| PostgreSQL | Sim | Sim | Sim | Sim | Planejado |
| MySQL | Sim | Sim | Sim | Sim | Planejado |
| MariaDB | Sim | Sim | Sim | Sim | Planejado |
| Oracle | Sim | Sim | Sim | Sim | Planejado |
| SQLite | Sim | Em breve | Em breve | Planejado | Planejado |
| MongoDB | Em breve | Em breve | Em breve | N/A | N/A |

MariaDB reutiliza internamente a stack MySQL.

---

## Recursos principais

### Reconciliação de schema

- Comparação de tabelas, colunas, chaves, índices, constraints, views, procedures, functions, triggers e sequences
- Classificação de segurança: `SAFE_AUTO`, `REVIEW_REQUIRED`, `DESTRUCTIVE_BLOCKED`, `INFO_ONLY`
- Geração de scripts idempotentes por dialeto
- Exportação Markdown, HTML e JSON
- Avisos de leitura de metadata exibidos durante o scan

### Migração cross-provider (v1.0.1)

- Workflow **Migrate** na tela inicial
- Mapeamento de tipos e geração de DDL para o banco alvo
- Exportação de dados em lotes com scripts INSERT
- Modo de exportação somente SQL para revisão manual

### Backup (SQL Server)

- `BACKUP DATABASE TO DISK` nativo
- Pasta de saída configurável com **Browse**
- Compressão opcional com fallback automático

---

## Modelo de segurança

IdempotentBase **não** é uma ferramenta de sincronização destrutiva.

| Regra | Comportamento |
|-------|---------------|
| Sem drops silenciosos | `DROP TABLE`, `DROP COLUMN` e similares são bloqueados |
| Sem shrink | Redução de tamanho de coluna nunca é aplicada automaticamente |
| Classificação primeiro | Toda diferença recebe label de segurança antes do script |
| Análise de script | SQL gerado é verificado contra padrões proibidos |
| Gate de apply | Apply em PROD exige conexão testada, confirmação de backup e nome do banco digitado |

**Sempre faça backup verificado antes de aplicar qualquer script em produção.**

Veja [docs/safety-rules.md](docs/safety-rules.md).

---

## Requisitos

| Componente | Versão |
|------------|--------|
| SO | Windows 10 ou superior |
| Runtime | [.NET Framework 4.8](https://dotnet.microsoft.com/download/dotnet-framework/net48) |
| Bancos | SQL Server, PostgreSQL, MySQL ou Oracle para testes |

Todos os drivers vêm incluídos no aplicativo.

---

## Workflow de reconciliação

1. Abra o app → escolha o engine.
2. Selecione **Reconcile**.
3. Configure conexões **DEV (Source)** e **PROD (Target)**.
4. **Compare Databases** → revise resultados.
5. **Generate Idempotent Script** → salve ou aplique (após confirmação de backup).

---

## Workflow de migração

1. Escolha engines de origem e destino.
2. Selecione **Migrate**.
3. Configure as conexões.
4. Execute análise de schema e revise o DDL gerado.
5. Exporte INSERTs em lotes ou use o modo somente SQL.

Revise todo o output antes de executar em produção.

---

## Workflow de backup

1. Escolha **SQL Server** → **Backup**.
2. Configure conexão e pasta de backup.
3. **Connect** → **Run Backup**.
4. Confirme o caminho do `.bak` no diálogo de sucesso.

---

## Armazenamento de conexões

```
database/
  sqlserver/connections.json
  postgresql/connections.json
  mysql/connections.json
  ...
```

Samples: [database/sqlserver/connections.sample.json](database/sqlserver/connections.sample.json)

Arquivos `connections.json` são locais e nunca vão para o git.

---

## Layout do repositório

```
IdempotentBasePublic/
├── app/          Executável, DLLs, assets e samples embutidos
├── database/     Samples de conexão
├── docs/         Arquitetura, segurança, metadata, roadmap
├── img/          Banner e imagens do projeto
├── util/         Scripts de build para mantenedores
└── releases/     ZIP local (não versionado no git)
```

---

## Releases

Downloads oficiais: [GitHub Releases](https://github.com/Edinaldosa2/IdempotentBasePublic/releases)

| Versão | Pacote | Destaques |
|--------|--------|-----------|
| v1.0.2 | `IdempotentBase-v1.0.2-win-x64.zip` | Correção no scan de parâmetros de rotinas MySQL (PARAMETER_DEFAULT) |
| v1.0.1 | `IdempotentBase-v1.0.1-win-x64.zip` | Workflow Migrate cross-provider, correções MySQL |
| v1.0.0 | `IdempotentBase-v1.0.0-win-x64.zip` | Release pública inicial |

Para rebuild, veja [util/README.md](util/README.md).

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Design multi-provider, fluxo de dados |
| [docs/safety-rules.md](docs/safety-rules.md) | Regras de classificação e operações bloqueadas |
| [docs/sqlserver-metadata.md](docs/sqlserver-metadata.md) | Cobertura de catalog SQL Server |
| [docs/roadmap.md](docs/roadmap.md) | Funcionalidades planejadas |

---

## Licença

MIT License. Veja [LICENSE](LICENSE).

---

## Autor

[Edinaldosa2](https://github.com/Edinaldosa2)

IdempotentBase é um **assistente seguro de reconciliação de schema**. Ajuda a entender drift, gerar SQL conservador e proteger produção — sem substituir o julgamento do DBA.
