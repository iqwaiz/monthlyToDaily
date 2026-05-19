------------------------------------------------------------
-- targets
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_targets
AS
BEGIN
    SET NOCOUNT ON;









DECLARE @T SYSNAME = 'targets';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;


with targets AS (
    SELECT
        vt.Year AS year,
        vt.MonthNo AS month,
        -- vt.Country AS country,
        CASE WHEN vt.Country = 'KSA' THEN 'Saudi Arabia' ELSE vt.Country END AS country,
        DAY(EOMONTH(DATEFROMPARTS(vt.Year, vt.MonthNo, 1))) as days_in_month,
        vt.BU,
        vt.Purpose AS purpose,
        COALESCE(SUM(vt.Committed_value), SUM(vt.Value)) AS visits_target,
        COALESCE(SUM(st.Committed_value), SUM(st.Value)) AS spend_target
    FROM [SIDR].[Business_Review].[Fact_Visits_Target] vt
    JOIN [SIDR].[Business_Review].[Fact_Spend_Target] st
          ON  st.Year    = vt.Year
          AND st.MonthNo = vt.MonthNo
          AND st.Country = vt.Country
          AND st.BU      = vt.BU
          AND st.Purpose = vt.Purpose
    GROUP BY
        vt.Year,
        vt.MonthNo,
        vt.Country,
        vt.BU,
        vt.Purpose
), daily_targets as (
    select
	    DATEFROMPARTS(t.year, t.month, d.DayofMonth) as date,
	    t.year,
	    t.month,
	    d.[DayofMonth] as day,
	    t.country,
	    t.BU,
	    t.purpose,
	    t.visits_target as monthly_visits_target,
	    t.spend_target as monthly_spend_target,
	    1.0 * t.visits_target / t.days_in_month as daily_visits_target,
	    1.0 * t.spend_target  / t.days_in_month as daily_spend_target

    from targets t
    join SIDR.dbo.DIM_DATE d
        on d.[YEAR] = t.[year] and d.[MONTH] = t.month

)SELECT * INTO #result FROM daily_targets;

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;





END;