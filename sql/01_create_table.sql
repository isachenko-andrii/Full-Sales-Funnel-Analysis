-- ============================================================
-- 01_create_table.sql
-- Schema definition and data loading
-- Compatible with: PostgreSQL 13+ / SQLite / BigQuery (adapted)
-- ============================================================

-- Drop table if re-running
DROP TABLE IF EXISTS user_funnels;

-- Create main funnel table
CREATE TABLE user_funnels (
    user_id    VARCHAR(50)  NOT NULL,
    stage      VARCHAR(50)  NOT NULL,
    conversion BOOLEAN      NOT NULL
);

-- -----------------------------------------
-- Load data from CSV (PostgreSQL)
-- -----------------------------------------
COPY user_funnels (user_id, stage, conversion)
FROM '/absolute/path/to/data/user_data.csv'
DELIMITER ','
CSV HEADER;

-- For SQLite, use in shell:
-- .mode csv
-- .import data/user_data.csv user_funnels

-- -----------------------------------------
-- Quick sanity check after load
-- -----------------------------------------
SELECT
    COUNT(*)             AS total_rows,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT stage)   AS unique_stages
FROM user_funnels;

-- Expected: total_rows=17175, unique_users=17175, unique_stages=5
