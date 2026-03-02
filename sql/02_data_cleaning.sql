-- ============================================================
-- 02_data_cleaning.sql
-- Data quality validation and cleaning checks
-- ============================================================

-- -----------------------------------------
-- 1. Check for NULL values in all columns
-- -----------------------------------------
SELECT
    COUNT(*) FILTER (WHERE user_id IS NULL)    AS null_user_id,
    COUNT(*) FILTER (WHERE stage IS NULL)      AS null_stage,
    COUNT(*) FILTER (WHERE conversion IS NULL) AS null_conversion,
    COUNT(*)                                    AS total_rows
FROM user_funnels;

-- Expected: all nulls = 0, total_rows = 17175

-- -----------------------------------------
-- 2. Check for empty string values
-- -----------------------------------------
SELECT
    COUNT(*) FILTER (WHERE TRIM(user_id) = '')  AS empty_user_id,
    COUNT(*) FILTER (WHERE TRIM(stage) = '')    AS empty_stage
FROM user_funnels;

-- -----------------------------------------
-- 3. Validate allowed values in 'stage'
-- -----------------------------------------
SELECT
    stage,
    COUNT(*) AS cnt
FROM user_funnels
GROUP BY stage
ORDER BY cnt DESC;

-- Expected 5 values only:
-- homepage, product_page, cart, checkout, purchase

-- Check for unexpected values:
SELECT DISTINCT stage
FROM user_funnels
WHERE stage NOT IN ('homepage', 'product_page', 'cart', 'checkout', 'purchase');
-- Expected: 0 rows

-- -----------------------------------------
-- 4. Validate 'conversion' values
-- -----------------------------------------
SELECT DISTINCT conversion FROM user_funnels;
-- Expected: TRUE and FALSE only

-- -----------------------------------------
-- 5. Check for duplicate records
-- -----------------------------------------
SELECT
    user_id,
    stage,
    COUNT(*) AS cnt
FROM user_funnels
GROUP BY user_id, stage
HAVING COUNT(*) > 1;
-- Expected: 0 rows (no duplicates)

-- Count total duplicates
SELECT COUNT(*) AS duplicate_count
FROM (
    SELECT user_id, stage
    FROM user_funnels
    GROUP BY user_id, stage
    HAVING COUNT(*) > 1
) dups;

-- -----------------------------------------
-- 6. Data quality summary report
-- -----------------------------------------
SELECT
    COUNT(*)                                      AS total_records,
    COUNT(DISTINCT user_id)                       AS unique_users,
    COUNT(DISTINCT stage)                         AS unique_stages,
    COUNT(*) FILTER (WHERE conversion = TRUE)     AS conversions_true,
    COUNT(*) FILTER (WHERE conversion = FALSE)    AS conversions_false,
    ROUND(
        COUNT(*) FILTER (WHERE conversion = TRUE) * 100.0 / COUNT(*), 1
    )                                             AS pct_true
FROM user_funnels;

-- -----------------------------------------
-- 7. Conclusion
-- -----------------------------------------
-- ✅ No NULL values found
-- ✅ No empty strings found
-- ✅ All 5 stage values are valid
-- ✅ Conversion field contains only TRUE/FALSE
-- ✅ No duplicate (user_id, stage) pairs
-- ✅ Dataset is clean and ready for analysis
