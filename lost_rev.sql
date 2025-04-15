--unpaid
select 
  count(distinct(add_on_period_pk)) as total_periods,
  count(distinct(start_of_month_add_on_period_pk)) as total_month_add_on_period_pk,
  count(distinct(case when period_payment_status = 'unpaid' then add_on_period_pk else null end)) as unpaid_periods,
  count(case when period_payment_status = 'unpaid' then start_of_month_add_on_period_pk else null end) as unpaid_monthly_periods,
  sum(case when period_payment_status = 'unpaid' then month_cost_usd else null end) 
  - sum(case when period_payment_status = 'unpaid' then month_revenue_usd else null end) as lost_rev,
  sum(month_cost_usd) - sum(month_revenue_usd) as lost_rev_checking
from 
add_on_periods


--Checking my Columns again
--   select 
--   -- *
--   -- period_payment_status
--   count(*) as add_on_periods, 
--   sum(month_cost_usd) as month_cost_usd,
--   sum(month_revenue_usd) as month_revenue_usd,
--   sum(month_cost_usd) - sum(month_revenue_usd) as lost_rev
--   from 
--   add_on_periods
-- where not is_trial_period