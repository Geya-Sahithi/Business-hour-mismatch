SELECT
   slug AS gh_slug,
   CONCAT((JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].from')),'-',JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].to')) as gh_business_hours,
   STRUCT(
     b_name AS b_name,
     vb_name AS vb_name
   ) AS restaurant_info 
 FROM
   arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours;
