------------------------------------------------------------
-- vw_all_daily_data
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER VIEW dailyData.vw_all_daily_data
AS
SELECT
    data_type,
    date,
    year,
    month,
    day,
    country,
    BU,
    purpose,
    daily_visits,
    daily_spend,
    daily_visits_target,
    daily_spend_target
FROM ibraheem_test.dailyData.all_daily_data;
