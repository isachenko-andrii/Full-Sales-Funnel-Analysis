-- ============================================================
-- 05_segmentation.sql
-- User segmentation by funnel depth and behavior
-- ============================================================

-- -----------------------------------------
-- 1. Classify users by their deepest stage
-- -----------------------------------------
WITH user_depth AS (
    SELECT
        user_id,
        MAX(CASE stage
            WHEN 'homepage'     THEN 1
            WHEN 'product_page' THEN 2
            WHEN 'cart'         THEN 3
            WHEN 'checkout'     THEN 4
            WHEN 'purchase'     THEN 5
        END) AS max_depth
    FROM user_funnels
    GROUP BY user_id
)
SELECT
    CASE max_depth
        WHEN 1 THEN '🏠 Bounce        (homepage only)'
        WHEN 2 THEN '👀 Browser       (reached product page)'
        WHEN 3 THEN '🛒 Intent        (reached cart)'
        WHEN 4 THEN '💳 Near-Buyer    (reached checkout)'
        WHEN 5 THEN '✅ Buyer         (completed purchase)'
    END                                                      AS segment,
    COUNT(*)                                                 AS user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)      AS pct_of_users
FROM user_depth
GROUP BY max_depth
ORDER BY max_depth;

-- -----------------------------------------
-- 2. Cart Abandoners
--    Users who added to cart but never checked out
-- -----------------------------------------
SELECT COUNT(DISTINCT user_id) AS cart_abandoners
FROM user_funnels
WHERE stage = 'cart'
  AND user_id NOT IN (
      SELECT user_id FROM user_funnels WHERE stage = 'checkout'
  );
-- Result: 1,050 users

-- List of cart abandoners (for retargeting export)
SELECT DISTINCT
    user_id,
    'cart_abandoner' AS segment
FROM user_funnels
WHERE stage = 'cart'
  AND user_id NOT IN (
      SELECT user_id FROM user_funnels WHERE stage = 'checkout'
  )
ORDER BY user_id;

-- -----------------------------------------
-- 3. Checkout Abandoners
--    Users who started checkout but didn't purchase
-- -----------------------------------------
SELECT COUNT(DISTINCT user_id) AS checkout_abandoners
FROM user_funnels
WHERE stage = 'checkout'
  AND user_id NOT IN (
      SELECT user_id FROM user_funnels WHERE stage = 'purchase'
  );
-- Result: 225 users

-- -----------------------------------------
-- 4. All abandonment segments combined
--    (useful for email retargeting campaigns)
-- -----------------------------------------
SELECT user_id, 'cart_abandoner' AS segment
FROM user_funnels
WHERE stage = 'cart'
  AND user_id NOT IN (SELECT user_id FROM user_funnels WHERE stage = 'checkout')

UNION ALL

SELECT user_id, 'checkout_abandoner' AS segment
FROM user_funnels
WHERE stage = 'checkout'
  AND user_id NOT IN (SELECT user_id FROM user_funnels WHERE stage = 'purchase')

ORDER BY segment, user_id;

-- -----------------------------------------
-- 5. Converters: users who completed purchase
-- -----------------------------------------
SELECT DISTINCT user_id, 'buyer' AS segment
FROM user_funnels
WHERE stage = 'purchase'
ORDER BY user_id;

-- -----------------------------------------
-- 6. Segment summary table
-- -----------------------------------------
WITH segments AS (
    SELECT
        user_id,
        CASE
            WHEN user_id IN (SELECT user_id FROM user_funnels WHERE stage = 'purchase')
                THEN 'Buyer'
            WHEN user_id IN (SELECT user_id FROM user_funnels WHERE stage = 'checkout')
                THEN 'Checkout Abandoner'
            WHEN user_id IN (SELECT user_id FROM user_funnels WHERE stage = 'cart')
                THEN 'Cart Abandoner'
            WHEN user_id IN (SELECT user_id FROM user_funnels WHERE stage = 'product_page')
                THEN 'Browser'
            ELSE 'Bounce'
        END AS segment
    FROM user_funnels
    GROUP BY user_id
)
SELECT
    segment,
    COUNT(*)                                                AS users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)     AS pct
FROM segments
GROUP BY segment
ORDER BY
    CASE segment
        WHEN 'Bounce'               THEN 1
        WHEN 'Browser'              THEN 2
        WHEN 'Cart Abandoner'       THEN 3
        WHEN 'Checkout Abandoner'   THEN 4
        WHEN 'Buyer'                THEN 5
    END;
