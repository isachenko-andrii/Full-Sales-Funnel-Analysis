-- ============================================================
-- 04_funnel_analysis.sql
-- Core funnel metrics: step conversion, drop-off, cumulative CR
-- ============================================================

-- Helper: stage ordering
-- We use a CASE expression throughout to maintain funnel order

-- -----------------------------------------
-- 1. Users at each funnel stage
-- -----------------------------------------
SELECT
    stage,
    COUNT(*) AS users_at_stage
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
-- 2. Step-to-Step Conversion Rate
--    (% who proceeded from previous stage)
-- -----------------------------------------
WITH stage_counts AS (
    SELECT
        stage,
        COUNT(*) AS cnt,
        CASE stage
            WHEN 'homepage'     THEN 1
            WHEN 'product_page' THEN 2
            WHEN 'cart'         THEN 3
            WHEN 'checkout'     THEN 4
            WHEN 'purchase'     THEN 5
        END AS ord
    FROM user_funnels
    GROUP BY stage
),
with_prev AS (
    SELECT
        stage,
        cnt,
        ord,
        LAG(cnt) OVER (ORDER BY ord) AS prev_cnt
    FROM stage_counts
)
SELECT
    stage,
    cnt                                                          AS users,
    prev_cnt                                                     AS prev_stage_users,
    ROUND(cnt * 100.0 / NULLIF(prev_cnt, 0), 1)                 AS step_conversion_pct
FROM with_prev
ORDER BY ord;

-- -----------------------------------------
-- 3. Overall (Top-of-Funnel) Conversion Rate
-- -----------------------------------------
WITH top AS (
    SELECT COUNT(*) AS total FROM user_funnels WHERE stage = 'homepage'
),
bottom AS (
    SELECT COUNT(*) AS purchased FROM user_funnels WHERE stage = 'purchase'
)
SELECT
    total                                              AS homepage_users,
    purchased                                          AS purchase_users,
    ROUND(purchased * 100.0 / total, 2)                AS overall_conversion_pct
FROM top, bottom;

-- Result: 2.25%

-- -----------------------------------------
-- 4. Drop-off Rate per Stage
--    (% who left at this stage)
-- -----------------------------------------
WITH stage_counts AS (
    SELECT
        stage, COUNT(*) AS cnt,
        CASE stage
            WHEN 'homepage'     THEN 1
            WHEN 'product_page' THEN 2
            WHEN 'cart'         THEN 3
            WHEN 'checkout'     THEN 4
            WHEN 'purchase'     THEN 5
        END AS ord
    FROM user_funnels GROUP BY stage
),
with_next AS (
    SELECT
        stage, cnt, ord,
        LEAD(cnt) OVER (ORDER BY ord) AS next_cnt
    FROM stage_counts
)
SELECT
    stage,
    cnt                                                         AS users,
    cnt - COALESCE(next_cnt, cnt)                               AS users_dropped,
    ROUND((cnt - COALESCE(next_cnt, cnt)) * 100.0 / cnt, 1)    AS dropoff_pct
FROM with_next
ORDER BY ord;

-- -----------------------------------------
-- 5. Cumulative Conversion from Homepage
-- -----------------------------------------
WITH top AS (
    SELECT COUNT(*) AS top_cnt FROM user_funnels WHERE stage = 'homepage'
)
SELECT
    uf.stage,
    COUNT(*)                                               AS stage_users,
    top.top_cnt                                            AS homepage_users,
    ROUND(COUNT(*) * 100.0 / top.top_cnt, 2)              AS cumulative_conversion_pct
FROM user_funnels uf, top
GROUP BY uf.stage, top.top_cnt
ORDER BY
    CASE uf.stage
        WHEN 'homepage'     THEN 1
        WHEN 'product_page' THEN 2
        WHEN 'cart'         THEN 3
        WHEN 'checkout'     THEN 4
        WHEN 'purchase'     THEN 5
    END;

-- -----------------------------------------
-- 6. Full Funnel Dashboard (single query)
--    Combines all metrics using window functions
-- -----------------------------------------
WITH stage_counts AS (
    SELECT
        stage,
        COUNT(*) AS cnt,
        CASE stage
            WHEN 'homepage'     THEN 1
            WHEN 'product_page' THEN 2
            WHEN 'cart'         THEN 3
            WHEN 'checkout'     THEN 4
            WHEN 'purchase'     THEN 5
        END AS ord
    FROM user_funnels
    GROUP BY stage
)
SELECT
    stage,
    cnt                                                              AS users,
    ROUND(cnt * 100.0 / FIRST_VALUE(cnt) OVER (ORDER BY ord), 2)   AS pct_of_top,
    ROUND(cnt * 100.0 / NULLIF(LAG(cnt) OVER (ORDER BY ord), 0), 1) AS step_conv_pct,
    cnt - COALESCE(LEAD(cnt) OVER (ORDER BY ord), cnt)               AS users_lost,
    ROUND(
        (cnt - COALESCE(LEAD(cnt) OVER (ORDER BY ord), cnt)) * 100.0 / cnt, 1
    )                                                                AS dropoff_pct
FROM stage_counts
ORDER BY ord;
