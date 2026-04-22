------------------------------------------------------------
-- targets
------------------------------------------------------------

IF OBJECT_ID('tempdb..#targets') IS NOT NULL DROP TABLE #targets;
with targets AS (
    SELECT
        vt.Year AS year,
        vt.MonthNo AS month,
        vt.Country AS country,
        vt.BU,
        vt.Purpose AS purpose,
        vt.Committed_value AS visits_target,
        st.Committed_value AS spend_target
    FROM [SIDR].[Business_Review].[Fact_Visits_Target] vt
    JOIN [SIDR].[Business_Review].[Fact_Spend_Target] st
          ON  st.Year    = vt.Year
          AND st.MonthNo = vt.MonthNo
          AND st.Country = vt.Country
          AND st.BU      = vt.BU
          AND st.Purpose = vt.Purpose
)SELECT * INTO #targets FROM targets;
