create or replace table add_on_periods as 
with base_periods as 
(
SELECT
  calendar_periods.start_of_month as revenue_month,
  calendar_periods.month_days,
  concat(calendar_periods.start_of_month,'_' , add_on_period_pk) as start_of_month_add_on_period_pk,
  periods.ADD_ON_PERIOD_PK,
  periods.ADD_ON_INSTANCE_ID,
  periods.ADD_ON_SUBSCRIPTION_ID,
  instances.PROVIDER_ID,
  instances.ADD_ON_NAME,
  partners.KEY_COUNTRY as partner_key_country,
  partners.STAFF_SEGMENT as partner_staff_segment,
  partners.BUSINESS_TYPE as partner_busness_type,
  periods.PERIOD_PAYMENT_STATUS,
  periods.IS_TRIAL_PERIOD,
  periods.CREATED_AT as period_created_at,
  periods.active_from_date,
  periods.ACTIVE_FROM,
  periods.active_to_date,
  periods.ACTIVE_TO,
  1+ date_sub('day', periods.active_from_date, periods.active_to_date) as full_period_length_days,

  periods.PRICE_USD as full_sub_price_usd,
  case 
      when period_payment_status = 'paid' 
      and is_trial_period is false then periods.PRICE_USD else 0 
  end as full_revenue_usd,

  -- --Next Period from same instance
lead( periods.ACTIVE_FROM) over (partition by instances.PROVIDER_ID, periods.ADD_ON_INSTANCE_ID 
  order by periods.ACTIVE_FROM) as next_period_instance_at,
-- lead( periods.ADD_ON_PERIOD_PK) over (partition by instances.PROVIDER_ID, periods.ADD_ON_INSTANCE_ID 
--   order by periods.ACTIVE_FROM) as next_add_on_period_pk,

-- --Previous Period from same instance
lag( periods.ACTIVE_FROM) over (partition by instances.PROVIDER_ID, periods.ADD_ON_INSTANCE_ID 
  order by periods.ACTIVE_FROM) as previous_period_instance_at,
-- lag( periods.ADD_ON_PERIOD_PK) over (partition by instances.PROVIDER_ID, periods.ADD_ON_INSTANCE_ID 
--   order by periods.ACTIVE_FROM) as previous_add_on_period_pk,  


  
-- --Next subscription period from same provider and others unneeded for the excercise
-- lead(  periods.ADD_ON_SUBSCRIPTION_ID) over (
--   partition by instances.PROVIDER_ID, periods.ADD_ON_INSTANCE_ID  
-- order by periods.ADD_ON_SUBSCRIPTION_ID) as next_add_on_subscription_id,
  
-- lag(  periods.ADD_ON_SUBSCRIPTION_ID) over ( partition by instances.PROVIDER_ID,   periods.ADD_ON_INSTANCE_ID  
-- order by periods.ADD_ON_SUBSCRIPTION_ID) as previous_add_on_subscription_id,
-- lead(  periods.ADD_ON_SUBSCRIPTION_ID) over (partition by instances.PROVIDER_ID, periods.ADD_ON_INSTANCE_ID,  periods.ADD_ON_SUBSCRIPTION_ID 
--   order by periods.ACTIVE_FROM) as next_add_on_subscription_id,
-- row_number() over (partition by instances.PROVIDER_ID,periods.ADD_ON_INSTANCE_ID  order by calendar_periods.start_of_month, periods.ACTIVE_FROM) 
--   as partner_instance_period_numb, 
-- row_number() over (partition by instances.PROVIDER_ID,periods.ADD_ON_PERIOD_PK  order by calendar_periods.start_of_month, periods.ACTIVE_FROM) 
--   as partner_instance_period_numb,

--active_days_of_month logic - maybe macro for DRY code
case 
  --Full month outside definition or exact match month length
    when periods.active_from_date <= calendar_periods.start_of_month 
    and periods.active_to_date >= calendar_periods.end_of_month
  then calendar_periods.month_days
  
  --Start outside end inside
    when  periods.active_from_date < calendar_periods.start_of_month 
    and periods.active_to_date < calendar_periods.end_of_month
  then (calendar_periods.month_days - 
   date_sub('day', periods.active_to_date, calendar_periods.end_of_month ))
  
  --Start inside end outside
    when  periods.active_from_date >= calendar_periods.start_of_month 
    and periods.active_to_date > calendar_periods.end_of_month 
  then 1+date_sub('day', periods.active_from_date ,calendar_periods.end_of_month )
  
  --Start inside end inside
    when  periods.active_from_date >= calendar_periods.start_of_month 
    and periods.active_to_date <= calendar_periods.end_of_month 
  then 1+date_sub('day', periods.active_from_date ,periods.active_to_date )
end as active_days_of_month
  
FROM
(select start_of_month, end_of_month, month_days from calendar group by 1,2,3)  as calendar_periods
inner join 
    periods as periods 
  on 
      periods.active_to_date >= calendar_periods.start_of_month
  and periods.active_from_date <= calendar_periods.end_of_month 
left join 
    instances as instances  ON instances.ADD_ON_INSTANCE_ID = periods.ADD_ON_INSTANCE_ID
left join 
    partners as partners on partners.PROVIDER_ID = instances.PROVIDER_ID
)

  
select 
  *,

  -- Adding rollover to subs for breakfree subscriptions and success of free trials
  case when date_sub('day', ACTIVE_TO, next_period_instance_at) <= 1 then 1 else 0 end as is_rollover_period_instance,
  active_days_of_month *  (full_revenue_usd /period_length_days) as month_revenue_usd,
  active_days_of_month *  (full_sub_price_usd /period_length_days) as month_cost_usd,
from base_periods
