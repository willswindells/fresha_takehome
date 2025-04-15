--4,729 Rows
create or replace table periods as (
SELECT
ADD_ON_PERIOD_PK as add_on_period_pk,
ADD_ON_INSTANCE_ID as add_on_instance_id,
ADD_ON_SUBSCRIPTION_ID as add_on_subscription_id,
PERIOD_PAYMENT_STATUS as period_payment_status,
IS_TRIAL_PERIOD as is_trial_period,
CREATED_AT as created_at,
ACTIVE_FROM as active_from,
ACTIVE_TO as active_to,
cast(ACTIVE_FROM AS DATE) as active_from_date,
cast(ACTIVE_TO as date) as active_to_date,
PRICE_USD as price_usd,
KEY_DRIVER_VALUE as key_driver_value,
  FROM 'periods.csv'
  )