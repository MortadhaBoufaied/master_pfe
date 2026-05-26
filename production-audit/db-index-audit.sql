-- PostgreSQL production-readiness index audit.
-- Run against a staging-like database after restoring representative data.

-- 1. Foreign keys without a matching leading-column index.
WITH fk_columns AS (
    SELECT
        con.oid AS constraint_oid,
        con.conname AS constraint_name,
        con.conrelid AS table_oid,
        con.conrelid::regclass AS table_name,
        con.conkey AS constrained_columns
    FROM pg_constraint con
    WHERE con.contype = 'f'
),
indexed_columns AS (
    SELECT
        idx.indrelid AS table_oid,
        idx.indexrelid::regclass AS index_name,
        idx.indkey::smallint[] AS indexed_columns,
        idx.indisvalid AS is_valid
    FROM pg_index idx
    WHERE idx.indisvalid
)
SELECT
    fk.table_name,
    fk.constraint_name,
    fk.constrained_columns
FROM fk_columns fk
WHERE NOT EXISTS (
    SELECT 1
    FROM indexed_columns ix
    WHERE ix.table_oid = fk.table_oid
      AND ix.indexed_columns[1:array_length(fk.constrained_columns, 1)] = fk.constrained_columns
)
ORDER BY fk.table_name::text, fk.constraint_name;

-- 2. Largest tables and index footprint.
SELECT
    relid::regclass AS table_name,
    n_live_tup AS estimated_rows,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_indexes_size(relid)) AS index_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 25;

-- 3. Sequential scans that may indicate missing indexes.
SELECT
    relid::regclass AS table_name,
    seq_scan,
    idx_scan,
    n_live_tup AS estimated_rows,
    CASE
        WHEN idx_scan = 0 THEN NULL
        ELSE round(seq_scan::numeric / idx_scan, 2)
    END AS seq_to_index_scan_ratio
FROM pg_stat_user_tables
WHERE n_live_tup > 1000
ORDER BY seq_scan DESC
LIMIT 25;

-- 4. Query plan templates for critical product paths.
-- Replace placeholders with representative IDs before running.
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM players
WHERE academy_id = :academy_id
ORDER BY id DESC
LIMIT 50;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM payments
WHERE academy_id = :academy_id
  AND paid = false
ORDER BY mois DESC
LIMIT 50;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM scouting_reports
WHERE player_id = :player_id
ORDER BY created_at DESC
LIMIT 25;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM player_performance_observations
WHERE player_id = :player_id
ORDER BY observed_at DESC
LIMIT 25;

