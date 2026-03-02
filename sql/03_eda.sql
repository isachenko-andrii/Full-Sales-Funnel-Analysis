-- ============================================================
-- 03_eda.sql
-- Exploratory Data Analysis (EDA)
-- ============================================================

-- -----------------------------------------
-- 1. Total records and unique users per stage
-- -----------------------------------------
SELECT
    stage,
    COUNT(*)  AS user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_all_records
FROM user_funnels
GROUP BY stage
ORDER BY
    CASE stage
        WHEN 'homepage'     THEN 1
        WHEN 'product_page' THEN 2
        WHEN 'cart'         THEN 3
        WHEN 'checkout'     THEN 4
        WHEN 'purchase'     THEN 5
    END;

-- -----------------------------------------
-- 2. Overall distribution of conversion field
-- -----------------------------------------
SELECT
    conversion,
    COUNT(*)  AS cnt,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM user_funnels
GROUP BY conversion;

-- -----------------------------------------
-- 3. Conversion breakdown per stage
-- -----------------------------------------
SELECT
    stage,
    COUNT(*)                                           AS total,
    COUNT(*) FILTER (WHERE conversion = TRUE)          AS converted,
    COUNT(*) FILTER (WHERE conversion = FALSE)         AS not_converted,
    ROUND(
        COUNT(*) FILTER (WHERE conversion = TRUE)
        * 100.0 / COUNT(*), 1
    )                                                  AS conversion_rate_pct
FROM user_funnels
GROUP BY stage
ORDER BY
    CASE stage
        WHEN 'homepage'     THEN 1
        WHEN 'product_page' THEN 2
        WHEN 'cart'         THEN 3
        WHEN 'checkout'     THEN 4
        WHEN 'purchase'     THEN 5
    END;

-- -----------------------------------------
-- 4. Stage with the most drop-offs (absolute)
-- -----------------------------------------
SELECT
    stage,
    COUNT(*) FILTER (WHERE conversion = FALSE) AS dropped_users
FROM user_funnels
GROUP BY stage
ORDER BY dropped_users DESC
LIMIT 1;

-- -----------------------------------------
-- 5. Sample user journeys (first 20 users)
-- -----------------------------------------
SELECT
    user_id,
    STRING_AGG(stage, ' → ' ORDER BY
        CASE stage
            WHEN 'homepage'     THEN 1
            WHEN 'product_page' THEN 2
            WHEN 'cart'         THEN 3
            WHEN 'checkout'     THEN 4
            WHEN 'purchase'     THEN 5
        END
    ) AS journey
FROM user_funnels
GROUP BY user_id
LIMIT 20;
