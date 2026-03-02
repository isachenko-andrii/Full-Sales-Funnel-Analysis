-- ============================================================
-- 06_advanced_metrics.sql
-- Advanced SQL: window functions, CTEs, cohort template
-- ============================================================

-- -----------------------------------------
-- 1. Full funnel with all window functions
--    LAG / LEAD / FIRST_VALUE / SUM OVER
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
    ord                                                              AS step,
    stage,
    cnt                                                              AS users,
    -- Previous stage user count
    LAG(cnt)          OVER (ORDER BY ord)                           AS prev_stage_users,
    -- Next stage user count
    LEAD(cnt)         OVER (ORDER BY ord)                           AS next_stage_users,
    -- Top of funnel (homepage)
    FIRST_VALUE(cnt)  OVER (ORDER BY ord)                           AS top_users,
    -- Step-to-step conversion
    ROUND(cnt * 100.0 / NULLIF(LAG(cnt) OVER (ORDER BY ord), 0), 1) AS step_conv_pct,
    -- Overall funnel conversion
    ROUND(cnt * 100.0 / FIRST_VALUE(cnt) OVER (ORDER BY ord), 2)   AS overall_conv_pct,
    -- Running total of users lost
    FIRST_VALUE(cnt) OVER (ORDER BY ord) - cnt                      AS cumulative_lost,
    -- % lost from top
    ROUND(
        (FIRST_VALUE(cnt) OVER (ORDER BY ord) - cnt) * 100.0 /
        FIRST_VALUE(cnt) OVER (ORDER BY ord), 2
    )                                                                AS pct_lost_from_top
FROM stage_counts
ORDER BY ord;

-- -----------------------------------------
-- 2. Funnel efficiency score
--    Geometric mean of step conversions
--    (ideal for comparing funnels over time)
-- -----------------------------------------
WITH step_convs AS (
    SELECT
        stage,
        cnt * 100.0 / NULLIF(LAG(cnt) OVER (ORDER BY ord), 0) AS step_pct
    FROM (
        SELECT stage, COUNT(*) AS cnt,
            CASE stage
                WHEN 'homepage'     THEN 1
                WHEN 'product_page' THEN 2
                WHEN 'cart'         THEN 3
                WHEN 'checkout'     THEN 4
                WHEN 'purchase'     THEN 5
            END AS ord
        FROM user_funnels GROUP BY stage
    ) sc
)
SELECT
    ROUND(
        EXP(AVG(LN(step_pct / 100.0))) * 100, 2
    ) AS geometric_mean_step_conv_pct
FROM step_convs
WHERE step_pct IS NOT NULL;


-- -----------------------------------------
-- 3. Rolling 3-stage average conversion
--    (smooths out outlier stages)
-- -----------------------------------------
WITH stage_counts AS (
    SELECT stage, COUNT(*) AS cnt,
        CASE stage
            WHEN 'homepage'     THEN 1
            WHEN 'product_page' THEN 2
            WHEN 'cart'         THEN 3
            WHEN 'checkout'     THEN 4
            WHEN 'purchase'     THEN 5
        END AS ord
    FROM user_funnels GROUP BY stage
),
step_conv AS (
    SELECT stage, ord,
        ROUND(cnt * 100.0 / NULLIF(LAG(cnt) OVER (ORDER BY ord), 0), 1) AS step_pct
    FROM stage_counts
)
SELECT
    stage,
    step_pct,
    ROUND(
        AVG(step_pct) OVER (ORDER BY ord ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 1
    ) AS rolling_3step_avg_pct
FROM step_conv
ORDER BY ord;

