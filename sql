sql/

## 01_data_exploration.sql
  SELECT * FROM `project-2508a3e1-ef82-4dc3-ac4.Salesdata.Sales Table` LIMIT 1000

## 02_sales_funnel_analysis.sql
  WITH funnel_stages AS (

  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payments,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
  
  FROM `project-2508a3e1-ef82-4dc3-ac4.Salesdata.Sales Table`
)

SELECT
  stage_1_views,

  stage_2_cart,
  ROUND(stage_2_cart * 100.0 / stage_1_views, 2) AS view_to_cart_rate,

  stage_3_checkout,
  ROUND(stage_3_checkout * 100.0 / stage_2_cart, 2) AS cart_to_checkout_rate,

  stage_4_payments,
  ROUND(stage_4_payments * 100.0 / stage_3_checkout, 2) AS checkout_to_payment_rate,

  stage_5_purchase,
  ROUND(stage_5_purchase * 100.0 / stage_4_payments, 2) AS payment_to_purchase_rate,

  ROUND(stage_5_purchase * 100.0 / stage_1_views, 2) AS overall_conversion_rate

FROM funnel_stages;


## 03_traffic_source_analysis.sql
  WITH source_funnel AS (
  SELECT
  traffic_source,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase

  FROM `project-2508a3e1-ef82-4dc3-ac4.Salesdata.Sales Table`

  GROUP BY traffic_source

)
SELECT
traffic_source,
views,
cart,
purchase,
ROUND(cart * 100.0 / views) AS cart_conversion_rate,
ROUND(purchase * 100.0 / views) AS purchase_conversion_rate,
ROUND(purchase * 100.0 / cart) AS cart_to_purchase_conversion_rate,

FROM source_funnel
ORDER BY purchase DESC

## 04_customer_journey_analysis.sql
  WITH user_journey AS (
  SELECT
    user_id,
    MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time

  FROM `project-2508a3e1-ef82-4dc3-ac4.Salesdata.Sales Table`

  GROUP BY user_id

  HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)
SELECT
  COUNT(*) AS converted_users,

  ROUND(AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)), 2) 
    AS avg_view_to_cart_minutes,

  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)), 2) 
    AS avg_cart_to_purchase_minutes,

  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)), 2) 
    AS avg_total_journey_minutes
FROM user_journey;


## 05_revenue_analysis.sql
WITH funnel_revenue AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
    SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders

  FROM `project-2508a3e1-ef82-4dc3-ac4.Salesdata.Sales Table`
)
SELECT
  total_visitors,
  total_buyers,
  total_revenue,
  total_orders,

  ROUND(total_revenue / total_orders, 2) AS avg_order_value,

  ROUND(total_revenue / total_buyers, 2) AS revenue_per_buyer,

  ROUND(total_revenue / total_visitors, 2) AS revenue_per_visitor

FROM funnel_revenue;

