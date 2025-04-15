select
  revenue_month,
  add_on_name,
  sum(revenue_value)
from monthly_add_on_revenue
group by 1,2