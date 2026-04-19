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