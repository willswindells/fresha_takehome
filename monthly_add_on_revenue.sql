create or replace table monthly_add_on_revenue as (
SELECT 
provider_id,
add_on_period_pk,
add_on_name,
start_of_month as revenue_month,
active_days_of_month *  (full_revenue_usd /period_length_days) as revenue_value,
-- active_days_of_month *  (full_sub_price_usd /period_length_days) as cost_value,
from 
add_on_periods
)