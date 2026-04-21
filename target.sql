select
	    vt.Year as year,
	    vt.MonthNo as month,
	    vt.Country as country,
	    vt.BU,
	    vt.Purpose as purpose,
	    vt.Committed_value as visits_target,
	    st.Committed_value as spend_target
	FROM [SIDR].[Business_Review].[Fact_Visits_Target] vt
	JOIN [SIDR].[Business_Review].[Fact_Spend_Target] st
	      ON  st.Year      = vt.Year
	      AND st.MonthNo   = vt.MonthNo
	      AND st.Country   = vt.Country
	      AND st.BU        = vt.BU
	      AND st.Purpose   = vt.Purpose