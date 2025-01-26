SELECT * FROM arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours LIMIT 1000;
  
SELECT * FROM arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours LIMIT 1000;

SELECT
   slug AS ue_slug,
   CONCAT(JSON_VALUE(response, '$.data.menus."26bd579e-5664-4f0a-8465-2f5eb5fbe705".sections[0].regularHours[0].startTime'),' - ',JSON_VALUE(response, '$.data.menus."26bd579e-5664-4f0a-8465-2f5eb5fbe705".sections[0].regularHours[0].endTime')) as ue_business_hours,
   STRUCT(
     b_name AS b_name,
     vb_name AS vb_name
   ) AS restaurant_info
 FROM
   arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours;


SELECT
   slug AS gh_slug,
   CONCAT((JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].from')),'-',JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].to')) as gh_business_hours,
   STRUCT(
     b_name AS b_name,
     vb_name AS vb_name
   ) AS restaurant_info 
 FROM
   arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours;


WITH Ubereats AS (
  SELECT
    slug AS ue_slug,
    JSON_VALUE(response, '$.data.menus."26bd579e-5664-4f0a-8465-2f5eb5fbe705".sections[0].regularHours[0].startTime') AS Ubereats_starttime,
    JSON_VALUE(response, '$.data.menus."26bd579e-5664-4f0a-8465-2f5eb5fbe705".sections[0].regularHours[0].endTime') AS Ubereats_endtime,
    STRUCT(
      b_name AS b_name,
      vb_name AS vb_name
    ) AS restaurant_info
  FROM
    `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours`
),

Grubhub AS (
  SELECT
    slug AS gh_slug,
    JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].from') AS Grubhub_starttime,
    JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].to') AS Grubhub_endtime,
    STRUCT(
      b_name AS b_name,
      vb_name AS vb_name
    ) AS restaurant_info
  FROM
    `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
)

SELECT
  Grubhub.gh_slug AS `Grubhub slug`,
  CONCAT(Grubhub.Grubhub_starttime, ' - ', Grubhub.Grubhub_endtime) AS `Virtual Restaurant Business Hours`,
  Ubereats.ue_slug AS `Uber Eats slug`,
  CONCAT(Ubereats.Ubereats_starttime, ' - ', Ubereats.Ubereats_endtime) AS `Uber Eats Business Hours`,
  CASE
    WHEN Grubhub.Grubhub_starttime >= Ubereats.Ubereats_starttime
      AND Grubhub.Grubhub_endtime <= Ubereats.Ubereats_endtime THEN 'In Range'
    WHEN Grubhub.Grubhub_starttime < Ubereats.Ubereats_starttime
      OR Grubhub.Grubhub_endtime > Ubereats.Ubereats_endtime 
      THEN 'Out of Range'
    ELSE 'Out of Range with 5 mins difference'
  END AS `is_out_range`
FROM Ubereats
INNER JOIN Grubhub
  ON Ubereats.restaurant_info = Grubhub.restaurant_info;
