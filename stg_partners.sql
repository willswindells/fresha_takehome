create or replace table partners as (
SELECT
PROVIDER_ID as provider_id,
CREATED_AT as created_at,
KEY_COUNTRY as key_country,
STAFF_SEGMENT as staff_segment,
BUSINESS_TYPE as business_type,
  FROM 'partners.csv'
  )