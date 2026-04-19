-- Analysing all the tables withing the default schema
Select * from information_schema.tables;
-- Analysing the column names and data type for the bright tv tables
Select * from information_schema.columns 
where table_schema = 'default' and table_name = 'bright_tv_viewership';
-- Analysing the column names and data type for the bright tv tables
Select * from information_schema.columns 
where table_schema = 'default' and table_name = 'bright_tv_user_profiles';
-- Get the duration only
Select date_format(`Duration 2`, 'HH:mm:ss') AS TimeOnly
from default.bright_tv_viewership;
--Get Start date for subscription
Select Date(Min(RecordDate2))
from bright_tv_viewership
Limit 1;
--Get last date for subscription
Select Date(Max(RecordDate2))
from bright_tv_viewership
Limit 1;
--How long has the user been watching?
SELECT 
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(`Duration 2`) * 3600
      + minute(`Duration 2`) * 60
      + second(`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership;
--split duration 2 to only duration and show total duration is seconds
SELECT 
  (CAST(SPLIT(SPLIT(`duration 2`, ' ')[1], ':')[0] AS DOUBLE) * 3600) +
  (CAST(SPLIT(SPLIT(`duration 2`, ' ')[1], ':')[1] AS DOUBLE) * 60) +
  (CAST(SPLIT(SPLIT(`duration 2`, ' ')[1], ':')[2] AS DOUBLE)) AS duration_seconds
FROM bright_tv_viewership;
--Calculate total viewerships per day
SELECT 
  dayname(RecordDate2) AS view_day,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(`Duration 2`) * 3600
      + minute(`Duration 2`) * 60
      + second(`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership
GROUP BY dayname(RecordDate2)
ORDER BY view_day;
-- calculate total viewrships per month
SELECT 
  month(RecordDate2) AS view_month,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(`Duration 2`) * 3600
      + minute(`Duration 2`) * 60
      + second(`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership
GROUP BY month(RecordDate2)
ORDER BY view_month;
-- calculate total viewrship per time of day (Morning / Afternoon / Evening / Night)
SELECT 
  CASE 
    WHEN hour(RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN hour(RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN hour(RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Night'
  END AS daytime_range,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(`Duration 2`) * 3600
      + minute(`Duration 2`) * 60
      + second(`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership
GROUP BY 
  CASE 
    WHEN hour(RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN hour(RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN hour(RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Night'
  END
ORDER BY daytime_range;
-- Show total watch time per gender
SELECT 
  u.Gender,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY u.Gender
ORDER BY u.Gender;
-- calculate total watchtime per race
SELECT 
  u.Race,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY u.Race
ORDER BY u.Race;
-- Select top 5 perfoming Channels
SELECT 
  v.Channel2 AS Channel,
  SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`)) AS total_seconds,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY v.Channel2
ORDER BY total_seconds DESC
LIMIT 5;
--select bottom 5 performing channels
SELECT 
  v.Channel2 AS Channel,
  SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`)) AS total_seconds,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY v.Channel2
ORDER BY total_seconds ASC
LIMIT 5;
--Get Month,Day and Time from RecordDate2
SELECT 
  month(RecordDate2)   AS month,
  day(RecordDate2)     AS day,
  date_format(RecordDate2, 'HH:mm:ss') AS time
FROM bright_tv_viewership;
-- Group time as daytime range as Morning,Afternoon,Evening, Night
SELECT 
  UserID,
  Channel2,
  CASE 
    WHEN hour(RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN hour(RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN hour(RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Night'
  END AS daytime_range
FROM bright_tv_viewership;

-- Select top 5 performing users 
SELECT 
  u.Name,
  u.Surname,
  v.UserID,
  SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`)) AS total_seconds,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY u.Name, u.Surname, v.UserID
ORDER BY total_seconds DESC
LIMIT 5;
-- select bottom performing users
SELECT 
  u.Name,
  u.Surname,
  v.UserID,
  SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`)) AS total_seconds,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY u.Name, u.Surname, v.UserID
ORDER BY total_seconds ASC
LIMIT 5;
-- group by age
SELECT 
  CASE 
    WHEN u.Age BETWEEN 1 AND 15 THEN 'Minor'
    WHEN u.Age BETWEEN 16 AND 21 THEN 'Young Adult'
    WHEN u.Age BETWEEN 22 AND 35 THEN 'Adult'
    WHEN u.Age >= 36 THEN 'Senior'
    ELSE 'Unknown'
  END AS age_group,
  SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`)) AS total_seconds,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY 
  CASE 
    WHEN u.Age BETWEEN 1 AND 15 THEN 'Minor'
    WHEN u.Age BETWEEN 16 AND 21 THEN 'Young Adult'
    WHEN u.Age BETWEEN 22 AND 35 THEN 'Adult'
    WHEN u.Age >= 36 THEN 'Senior'
    ELSE 'Unknown'
  END
ORDER BY total_seconds DESC;
-- These are the group by columns Age Group--Gender--Race--Province--Year--Monthname--DayName--time frame (Morning, Afternoon, Evening)
SELECT 
  u.Gender,
  v.Channel2 AS Channel,
  SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) AS total_seconds,
  make_interval(0,0,0,0,0,0,SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u ON v.UserID = u.UserID
GROUP BY u.Gender, v.Channel2
ORDER BY total_seconds DESC
LIMIT 5;
-- Bottom 5 Channels by Gender
SELECT 
  u.Gender,
  v.Channel2 AS Channel,
  SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) AS total_seconds,
  make_interval(0,0,0,0,0,0,SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u ON v.UserID = u.UserID
GROUP BY u.Gender, v.Channel2
ORDER BY total_seconds ASC
LIMIT 5;
--Top 5 Channels by Race
SELECT 
  u.Race,
  v.Channel2 AS Channel,
  SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) AS total_seconds,
  make_interval(0,0,0,0,0,0,SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u ON v.UserID = u.UserID
GROUP BY u.Race, v.Channel2
ORDER BY total_seconds DESC
LIMIT 5;
--Bottom 5 Channels by Race
SELECT 
  u.Race,
  v.Channel2 AS Channel,
  SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) AS total_seconds,
  make_interval(0,0,0,0,0,0,SUM(hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u ON v.UserID = u.UserID
GROUP BY u.Race, v.Channel2
ORDER BY total_seconds ASC
LIMIT 5;
-- Total watch time per Province,gender,  age group,
SELECT 
  u.Province,
  u.Gender,
  CASE 
    WHEN u.Age BETWEEN 1 AND 15 THEN 'Minor'
    WHEN u.Age BETWEEN 16 AND 21 THEN 'Young Adult'
    WHEN u.Age BETWEEN 22 AND 35 THEN 'Adult'
    WHEN u.Age >= 36 THEN 'Senior'
    ELSE 'Unknown'
  END AS AgeGroup,
  date_format(v.RecordDate2, 'EEEE') AS DayName,
  date_format(v.RecordDate2, 'MMMM') AS MonthName,
  CASE 
    WHEN hour(v.RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN hour(v.RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN hour(v.RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Night'
  END AS TimeFrame,
  SUM(hour(v.`Duration 2`) * 3600
      + minute(v.`Duration 2`) * 60
      + second(v.`Duration 2`)) AS total_seconds,
  make_interval(
    0,0,0,0,0,0,
    SUM(hour(v.`Duration 2`) * 3600
        + minute(v.`Duration 2`) * 60
        + second(v.`Duration 2`))
  ) AS TotalDuration
FROM bright_tv_viewership v
JOIN bright_tv_user_profiles u
  ON v.UserID = u.UserID
GROUP BY 
  u.Province,
  u.Gender,
  CASE 
    WHEN u.Age BETWEEN 1 AND 15 THEN 'Minor'
    WHEN u.Age BETWEEN 16 AND 21 THEN 'Young Adult'
    WHEN u.Age BETWEEN 22 AND 35 THEN 'Adult'
    WHEN u.Age >= 36 THEN 'Senior'
    ELSE 'Unknown'
  END,
  date_format(v.RecordDate2, 'EEEE'),
  date_format(v.RecordDate2, 'MMMM'),
  CASE 
    WHEN hour(v.RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN hour(v.RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN hour(v.RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Night'
  END
ORDER BY u.Province, u.Gender, AgeGroup, MonthName, DayName, TimeFrame;

-- Combined query
WITH

-- Base Query: core columns
base_query AS (
  SELECT
    v.UserID,
    u.Name,
    u.Surname,
    u.Email,
    u.Gender,
    u.Race,
    u.Age,
    u.Province,
    v.Channel2,
    v.RecordDate2,
    date_format(v.`Duration 2`, 'HH:mm:ss') AS TimeOnly,
    (hour(v.`Duration 2`) * 3600
     + minute(v.`Duration 2`) * 60
     + second(v.`Duration 2`)) AS duration_seconds,
    date_format(v.RecordDate2, 'EEEE') AS DayName,
    date_format(v.RecordDate2, 'MMMM') AS MonthName,
    month(v.RecordDate2) AS MonthNumber,
    day(v.RecordDate2) AS DayOfMonth,
    date_format(v.RecordDate2, 'HH:mm:ss') AS RecordTime,
    CASE
      WHEN hour(v.RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
      WHEN hour(v.RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
      WHEN hour(v.RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
      ELSE 'Night'
    END AS TimeFrame
  FROM default.bright_tv_viewership v
  JOIN default.bright_tv_user_profiles u
    ON v.UserID = u.UserID
  WHERE v.RecordDate2 IS NOT NULL
),

-- Dataset start / end dates
subscription_dates AS (
  SELECT
    date(min(RecordDate2)) AS DatasetStartDate,
    date(max(RecordDate2)) AS DatasetEndDate
  FROM base_query
),

-- Dataset total watch time (seconds + formatted HH:mm:ss)
total_watch AS (
  SELECT
    sum(duration_seconds) AS DatasetTotalSeconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS DatasetTotalInterval
  FROM base_query
),

-- Duration split example (raw seconds per row)
duration_split AS (
  SELECT UserID, duration_seconds
  FROM base_query
),

-- Watch per DayName
watch_per_day AS (
  SELECT
    DayName,
    sum(duration_seconds) AS day_total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS day_total_interval
  FROM base_query
  GROUP BY DayName
),

-- Watch per MonthName
watch_per_month AS (
  SELECT
    MonthName,
    MonthNumber,
    sum(duration_seconds) AS month_total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS month_total_interval
  FROM base_query
  GROUP BY MonthName, MonthNumber
),

-- Watch per TimeFrame
watch_per_timeframe AS (
  SELECT
    TimeFrame,
    sum(duration_seconds) AS timeframe_total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS timeframe_total_interval
  FROM base_query
  GROUP BY TimeFrame
),

-- Watch per Gender
watch_per_gender AS (
  SELECT
    Gender,
    sum(duration_seconds) AS gender_total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS gender_total_interval
  FROM base_query
  GROUP BY Gender
),

-- Watch per Race
watch_per_race AS (
  SELECT
    Race,
    sum(duration_seconds) AS race_total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS race_total_interval
  FROM base_query
  GROUP BY Race
),

-- Watch per AgeGroup
watch_per_agegroup AS (
  SELECT
    CASE
      WHEN Age BETWEEN 1 AND 15 THEN 'Minor'
      WHEN Age BETWEEN 16 AND 21 THEN 'Young Adult'
      WHEN Age BETWEEN 22 AND 35 THEN 'Adult'
      WHEN Age >= 36 THEN 'Senior'
      ELSE 'Unknown'
    END AS AgeGroup,
    sum(duration_seconds) AS agegroup_total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS agegroup_total_interval
  FROM base_query
  GROUP BY
    CASE
      WHEN Age BETWEEN 1 AND 15 THEN 'Minor'
      WHEN Age BETWEEN 16 AND 21 THEN 'Young Adult'
      WHEN Age BETWEEN 22 AND 35 THEN 'Adult'
      WHEN Age >= 36 THEN 'Senior'
      ELSE 'Unknown'
    END
),

-- Top 5 Channels (dataset-level) using window
top_channels AS (
  SELECT Channel, channel_total_seconds, channel_total_interval
  FROM (
    SELECT
      Channel2 AS Channel,
      sum(duration_seconds) AS channel_total_seconds,
      concat(
        lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
        lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
        lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
      ) AS channel_total_interval,
      row_number() OVER (ORDER BY sum(duration_seconds) DESC) AS rn
    FROM base_query
    GROUP BY Channel2
  ) t
  WHERE rn <= 5
),

-- Bottom 5 Channels
bottom_channels AS (
  SELECT Channel, channel_total_seconds, channel_total_interval
  FROM (
    SELECT
      Channel2 AS Channel,
      sum(duration_seconds) AS channel_total_seconds,
      concat(
        lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
        lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
        lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
      ) AS channel_total_interval,
      row_number() OVER (ORDER BY sum(duration_seconds) ASC) AS rn
    FROM base_query
    GROUP BY Channel2
  ) t
  WHERE rn <= 5
),

-- Top 5 Users
top_users AS (
  SELECT UserID, Name, Surname, user_total_seconds, user_total_interval
  FROM (
    SELECT
      UserID,
      first(Name) AS Name,
      first(Surname) AS Surname,
      sum(duration_seconds) AS user_total_seconds,
      concat(
        lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
        lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
        lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
      ) AS user_total_interval,
      row_number() OVER (ORDER BY sum(duration_seconds) DESC) AS rn
    FROM base_query
    GROUP BY UserID
  ) t
  WHERE rn <= 5
),

-- Bottom 5 Users
bottom_users AS (
  SELECT UserID, Name, Surname, user_total_seconds, user_total_interval
  FROM (
    SELECT
      UserID,
      first(Name) AS Name,
      first(Surname) AS Surname,
      sum(duration_seconds) AS user_total_seconds,
      concat(
        lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
        lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
        lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
      ) AS user_total_interval,
      row_number() OVER (ORDER BY sum(duration_seconds) ASC) AS rn
    FROM base_query
    GROUP BY UserID
  ) t
  WHERE rn <= 5
),

-- Province / Gender / AgeGroup / MonthName / DayName / TimeFrame breakdown
watch_per_province_gender_age AS (
  SELECT
    Province,
    Gender,
    CASE
      WHEN Age BETWEEN 1 AND 15 THEN 'Minor'
      WHEN Age BETWEEN 16 AND 21 THEN 'Young Adult'
      WHEN Age BETWEEN 22 AND 35 THEN 'Adult'
      WHEN Age >= 36 THEN 'Senior'
      ELSE 'Unknown'
    END AS AgeGroup,
    MonthName,
    DayName,
    TimeFrame,
    sum(duration_seconds) AS total_seconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS total_interval
  FROM base_query
  GROUP BY Province, Gender,
    CASE
      WHEN Age BETWEEN 1 AND 15 THEN 'Minor'
      WHEN Age BETWEEN 16 AND 21 THEN 'Young Adult'
      WHEN Age BETWEEN 22 AND 35 THEN 'Adult'
      WHEN Age >= 36 THEN 'Senior'
      ELSE 'Unknown'
    END,
    MonthName, DayName, TimeFrame
),

-- user_agg: one row per user with user-level totals and last activity month/day
user_agg AS (
  SELECT
    UserID,
    min(RecordDate2) AS UserStartDate,
    max(RecordDate2) AS UserEndDate,
    sum(duration_seconds) AS UserTotalSeconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
    ) AS UserTotalInterval,
    count(*) AS UserTotalSessions,
    count(DISTINCT Channel2) AS UserDistinctChannels,
    date_format(max(RecordDate2), 'MMMM') AS UserLastMonthName,
    date_format(max(RecordDate2), 'EEEE') AS UserLastDayName
  FROM base_query
  GROUP BY UserID
),

-- distinct user profile info (one row per user)
user_profile AS (
  SELECT
    UserID,
    first(Name) AS Name,
    first(Surname) AS Surname,
    first(Email) AS Email,
    first(Gender) AS Gender,
    first(Race) AS Race,
    first(Age) AS Age,
    first(Province) AS Province
  FROM base_query
  GROUP BY UserID
)

-- Final SELECT: one row per user with ALL KPI columns included
SELECT
  up.UserID,
  up.Name,
  up.Surname,
  up.Email,
  up.Gender,
  up.Race,
  up.Age,
  up.Province,

  ua.UserStartDate,
  ua.UserEndDate,
  ua.UserTotalSeconds,
  ua.UserTotalInterval,
  ua.UserTotalSessions,
  ua.UserDistinctChannels,
  ua.UserLastMonthName,
  ua.UserLastDayName,

  sd.DatasetStartDate,
  sd.DatasetEndDate,
  tw.DatasetTotalSeconds,
  tw.DatasetTotalInterval,

  wp_prov.total_seconds  AS ProvinceTotalSeconds,
  wp_prov.total_interval AS ProvinceTotalInterval,

  wg.gender_total_seconds  AS GenderTotalSeconds,
  wg.gender_total_interval AS GenderTotalInterval,

  wm.month_total_seconds  AS MonthTotalSeconds,
  wm.month_total_interval AS MonthTotalInterval,

  wd.day_total_seconds  AS DayTotalSeconds,
  wd.day_total_interval AS DayTotalInterval,

  -- aggregated lists (concatenated strings). Order is not guaranteed in Spark collect_list,
  -- but these lists provide the full KPI breakdowns in a single column each.
  (SELECT concat_ws(',', collect_list(concat(DayName, ':', cast(day_total_seconds AS STRING), 's(', day_total_interval, ')'))) FROM watch_per_day) AS WatchPerDay_List,
  (SELECT concat_ws(',', collect_list(concat(MonthName, ':', cast(month_total_seconds AS STRING), 's(', month_total_interval, ')'))) FROM watch_per_month) AS WatchPerMonth_List,
  (SELECT concat_ws(',', collect_list(concat(TimeFrame, ':', cast(timeframe_total_seconds AS STRING), 's(', timeframe_total_interval, ')'))) FROM watch_per_timeframe) AS WatchPerTimeFrame_List,
  (SELECT concat_ws(',', collect_list(concat(Gender, ':', cast(gender_total_seconds AS STRING), 's(', gender_total_interval, ')'))) FROM watch_per_gender) AS WatchPerGender_List,
  (SELECT concat_ws(',', collect_list(concat(Race, ':', cast(race_total_seconds AS STRING), 's(', race_total_interval, ')'))) FROM watch_per_race) AS WatchPerRace_List,
  (SELECT concat_ws(',', collect_list(concat(AgeGroup, ':', cast(agegroup_total_seconds AS STRING), 's(', agegroup_total_interval, ')'))) FROM watch_per_agegroup) AS WatchPerAgeGroup_List,

  (SELECT concat_ws(',', collect_list(concat(Channel, ':', cast(channel_total_seconds AS STRING), 's(', channel_total_interval, ')'))) FROM top_channels) AS TopChannels_List,
  (SELECT concat_ws(',', collect_list(concat(Channel, ':', cast(channel_total_seconds AS STRING), 's(', channel_total_interval, ')'))) FROM bottom_channels) AS BottomChannels_List,

  (SELECT concat_ws(',', collect_list(concat(Name, ' ', Surname, ':', cast(user_total_seconds AS STRING), 's(', user_total_interval, ')'))) FROM top_users) AS TopUsers_List,
  (SELECT concat_ws(',', collect_list(concat(Name, ' ', Surname, ':', cast(user_total_seconds AS STRING), 's(', user_total_interval, ')'))) FROM bottom_users) AS BottomUsers_List,

  (SELECT concat_ws('||', collect_list(concat(Province, '|', Gender, '|', AgeGroup, '|', MonthName, '|', DayName, '|', TimeFrame, ':', cast(total_seconds AS STRING), 's(', total_interval, ')')) ) FROM watch_per_province_gender_age) AS Province_Gender_Age_Month_Day_Timeframe_Breakdown

FROM user_profile up
JOIN user_agg ua ON ua.UserID = up.UserID
CROSS JOIN subscription_dates sd
CROSS JOIN total_watch tw

LEFT JOIN (
  SELECT Province AS province_key, sum(duration_seconds) AS total_seconds,
         concat(
           lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING), 2, '0'), ':',
           lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING), 2, '0'), ':',
           lpad(cast((sum(duration_seconds) % 60) AS STRING), 2, '0')
         ) AS total_interval
  FROM base_query
  GROUP BY Province
) wp_prov ON wp_prov.province_key = up.Province

LEFT JOIN watch_per_gender wg ON wg.Gender = up.Gender
LEFT JOIN watch_per_month wm ON wm.MonthName = ua.UserLastMonthName
LEFT JOIN watch_per_day wd ON wd.DayName = ua.UserLastDayName

ORDER BY up.Province, up.Gender, up.UserID;

-- Final Query 
WITH
base_query AS (
  SELECT
    v.UserID,
    u.Name,
    u.Surname,
    u.Email,
    u.Gender,
    u.Race,
    u.Age,
    u.Province,
    v.Channel2,
    v.RecordDate2,
    (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) AS duration_seconds,
    date_format(v.RecordDate2, 'EEEE') AS DayName,
    date_format(v.RecordDate2, 'MMMM') AS MonthName,
    month(v.RecordDate2) AS MonthNumber,
    day(v.RecordDate2) AS DayOfMonth,
    date_format(v.RecordDate2, 'HH:mm:ss') AS RecordTime,
    CASE
      WHEN hour(v.RecordDate2) BETWEEN 5 AND 11 THEN 'Morning'
      WHEN hour(v.RecordDate2) BETWEEN 12 AND 17 THEN 'Afternoon'
      WHEN hour(v.RecordDate2) BETWEEN 18 AND 22 THEN 'Evening'
      ELSE 'Night'
    END AS TimeFrame
  FROM default.bright_tv_viewership v
  JOIN default.bright_tv_user_profiles u ON v.UserID = u.UserID
  WHERE v.RecordDate2 IS NOT NULL
),

dataset_dates AS (
  SELECT date(min(RecordDate2)) AS DatasetStartDate, date(max(RecordDate2)) AS DatasetEndDate
  FROM base_query
),

dataset_totals AS (
  SELECT
    sum(duration_seconds) AS DatasetTotalSeconds,
    concat(
      lpad(cast(floor(sum(duration_seconds) / 3600) AS STRING),2,'0'), ':',
      lpad(cast(floor((sum(duration_seconds) % 3600) / 60) AS STRING),2,'0'), ':',
      lpad(cast((sum(duration_seconds) % 60) AS STRING),2,'0')
    ) AS DatasetTotalInterval
  FROM base_query
),

watch_per_day AS (
  SELECT DayName, SUM(duration_seconds) AS day_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS day_total_interval
  FROM base_query GROUP BY DayName
),

watch_per_month AS (
  SELECT MonthName, MonthNumber, SUM(duration_seconds) AS month_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS month_total_interval
  FROM base_query GROUP BY MonthName, MonthNumber
),

watch_per_timeframe AS (
  SELECT TimeFrame, SUM(duration_seconds) AS timeframe_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS timeframe_total_interval
  FROM base_query GROUP BY TimeFrame
),

watch_per_gender AS (
  SELECT Gender, SUM(duration_seconds) AS gender_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS gender_total_interval
  FROM base_query GROUP BY Gender
),

watch_per_race AS (
  SELECT Race, SUM(duration_seconds) AS race_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS race_total_interval
  FROM base_query GROUP BY Race
),

watch_per_agegroup AS (
  SELECT
    CASE
      WHEN Age BETWEEN 1 AND 15 THEN 'Minor'
      WHEN Age BETWEEN 16 AND 21 THEN 'Young Adult'
      WHEN Age BETWEEN 22 AND 35 THEN 'Adult'
      WHEN Age >= 36 THEN 'Senior'
      ELSE 'Unknown'
    END AS AgeGroup,
    SUM(duration_seconds) AS agegroup_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS agegroup_total_interval
  FROM base_query
  GROUP BY CASE
    WHEN Age BETWEEN 1 AND 15 THEN 'Minor'
    WHEN Age BETWEEN 16 AND 21 THEN 'Young Adult'
    WHEN Age BETWEEN 22 AND 35 THEN 'Adult'
    WHEN Age >= 36 THEN 'Senior'
    ELSE 'Unknown'
  END
),

-- dataset-level top/bottom channels (kept as rows)
top_channels AS (
  SELECT Channel2 AS Channel, SUM(duration_seconds) AS channel_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS channel_total_interval
  FROM base_query
  GROUP BY Channel2
  ORDER BY channel_total_seconds DESC
  LIMIT 10
),

bottom_channels AS (
  SELECT Channel2 AS Channel, SUM(duration_seconds) AS channel_total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS channel_total_interval
  FROM base_query
  GROUP BY Channel2
  ORDER BY channel_total_seconds ASC
  LIMIT 10
),

-- per-user channel totals and top3 pivot
user_channel_totals AS (
  SELECT UserID, Channel2 AS Channel, SUM(duration_seconds) AS channel_total_seconds
  FROM base_query GROUP BY UserID, Channel2
),

user_top_channels AS (
  SELECT UserID, Channel, channel_total_seconds,
         ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY channel_total_seconds DESC) AS rn
  FROM user_channel_totals
),

user_top_channels_pivot AS (
  SELECT
    UserID,
    MAX(CASE WHEN rn = 1 THEN Channel END) AS top1_channel,
    MAX(CASE WHEN rn = 1 THEN channel_total_seconds END) AS top1_seconds,
    MAX(CASE WHEN rn = 2 THEN Channel END) AS top2_channel,
    MAX(CASE WHEN rn = 2 THEN channel_total_seconds END) AS top2_seconds,
    MAX(CASE WHEN rn = 3 THEN Channel END) AS top3_channel,
    MAX(CASE WHEN rn = 3 THEN channel_total_seconds END) AS top3_seconds
  FROM user_top_channels
  WHERE rn <= 3
  GROUP BY UserID
),

-- per-user aggregates
user_agg AS (
  SELECT
    UserID,
    MIN(RecordDate2) AS UserStartDate,
    MAX(RecordDate2) AS UserEndDate,
    SUM(duration_seconds) AS UserTotalSeconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS UserTotalInterval,
    COUNT(*) AS UserTotalSessions,
    COUNT(DISTINCT Channel2) AS UserDistinctChannels,
    date_format(MAX(RecordDate2), 'MMMM') AS UserLastMonthName,
    date_format(MAX(RecordDate2), 'EEEE') AS UserLastDayName
  FROM base_query
  GROUP BY UserID
),

-- distinct user profile (one row per user)
user_profile AS (
  SELECT UserID, first(Name) AS Name, first(Surname) AS Surname, first(Email) AS Email,
         first(Gender) AS Gender, first(Race) AS Race, first(Age) AS Age, first(Province) AS Province
  FROM base_query GROUP BY UserID
)

-- Final per-user result (no temp views)
SELECT
  up.UserID,
  up.Name,
  up.Surname,
  up.Email,
  up.Gender,
  up.Race,
  up.Age,
  CASE
    WHEN up.Age BETWEEN 1 AND 15 THEN 'Minor'
    WHEN up.Age BETWEEN 16 AND 21 THEN 'Young Adult'
    WHEN up.Age BETWEEN 22 AND 35 THEN 'Adult'
    WHEN up.Age >= 36 THEN 'Senior'
    ELSE 'Unknown'
  END AS AgeGroup,
  up.Province,
  ua.UserStartDate,
  ua.UserEndDate,
  ua.UserTotalSeconds,
  ua.UserTotalInterval,
  ua.UserTotalSessions,
  ua.UserDistinctChannels,
  ua.UserLastMonthName,
  ua.UserLastDayName,
  -- user's last timeframe (based on last record)
  bq_last.TimeFrame AS UserLastTimeFrame,
  dd.DatasetStartDate,
  dd.DatasetEndDate,
  dt.DatasetTotalSeconds,
  dt.DatasetTotalInterval,
  -- totals by province/gender/race (joined to user's attributes)
  prov_tot.total_seconds AS ProvinceTotalSeconds,
  prov_tot.total_interval AS ProvinceTotalInterval,
  gen_tot.gender_total_seconds AS GenderTotalSeconds,
  gen_tot.gender_total_interval AS GenderTotalInterval,
  race_tot.race_total_seconds AS RaceTotalSeconds,
  race_tot.race_total_interval AS RaceTotalInterval,
  -- last-month / last-day totals (contextual)
  mon.month_total_seconds AS MonthTotalSeconds,
  mon.month_total_interval AS MonthTotalInterval,
  dayt.day_total_seconds AS DayTotalSeconds,
  dayt.day_total_interval AS DayTotalInterval,
  -- per-user top 3 channels
  ut.top1_channel,
  ut.top1_seconds,
  ut.top2_channel,
  ut.top2_seconds,
  ut.top3_channel,
  ut.top3_seconds
FROM user_profile up
LEFT JOIN user_agg ua ON ua.UserID = up.UserID
LEFT JOIN base_query bq_last
  ON bq_last.UserID = up.UserID AND bq_last.RecordDate2 = ua.UserEndDate
CROSS JOIN dataset_dates dd
CROSS JOIN dataset_totals dt
LEFT JOIN (
  SELECT Province AS province_key, SUM(duration_seconds) AS total_seconds,
    concat(lpad(cast(floor(sum(duration_seconds)/3600) AS STRING),2,'0'),':',
           lpad(cast(floor((sum(duration_seconds)%3600)/60) AS STRING),2,'0'),':',
           lpad(cast((sum(duration_seconds)%60) AS STRING),2,'0')) AS total_interval
  FROM base_query GROUP BY Province
) prov_tot ON prov_tot.province_key = up.Province
LEFT JOIN watch_per_gender gen_tot ON gen_tot.Gender = up.Gender
LEFT JOIN watch_per_race race_tot ON race_tot.Race = up.Race
LEFT JOIN watch_per_month mon ON mon.MonthName = ua.UserLastMonthName
LEFT JOIN watch_per_day dayt ON dayt.DayName = ua.UserLastDayName
LEFT JOIN user_top_channels_pivot ut ON ut.UserID = up.UserID
ORDER BY up.Province, up.Gender, up.UserID;
