/* ==========================================================================================================
   File:            10_sources.sql
   Layer:           /01_sources
   Purpose:         Registers all TRUE upstream source tables used by the ETL pipeline.
                    These are the ONLY real external data origins for the entire system.

   Execution Order: Run AFTER /00_infrastructure.
   Re-run Safety:   Safe to re-run anytime — resets and reseeds the source tracker.

   Version:         1.1.0
   Change Log:
                      - 1.1.0 : Corrected Border source name to BOARDER_INBOUND_VW.
                      - 1.0.0 : Initial creation.
========================================================================================================== */

--USE ibraheem_test;
--

/* ==========================================================================================================
   1. Reset the source tracker
========================================================================================================== */

DELETE FROM dailyData.ETL_SourceChangeTracker;

/* ==========================================================================================================
   2. Insert TRUE upstream source tables
========================================================================================================== */

INSERT INTO dailyData.ETL_SourceChangeTracker (source_name, object_schema, object_name)
VALUES
    /* Border */
    ('BOARDER_INBOUND_VW',      'MT.tdp',               'BOARDER_INBOUND_VW'),

    /* Facts */
    ('Fact_Visits',             'SIDR.Business_Review', 'Fact_Visits'),
    ('Fact_Spend',              'SIDR.Business_Review', 'Fact_Spend'),

    /* Targets */
    ('Fact_Visits_Target',      'SIDR.Business_Review', 'Fact_Visits_Target'),
    ('Fact_Spend_Target',       'SIDR.Business_Review', 'Fact_Spend_Target'),

    /* Estimates */
    ('Estimates_Flows',         'MT.estimates',         'TOURISM_FLOWS_YTD_TBL'),
    ('Estimates_MAS',           'MT.mas',               'MAS_DOMESTICS_INC_VW'),

    /* Predictions */
    ('Pred_Inbound',            'ANALYTICS.dbo',        'V20_ENHANCE_INBOUND_FORECAST_tb_inbound_forecasting_scored'),
    ('Pred_Domestic',           'ANALYTICS.dbo',        'VERSION3_DOMESTIC_TRIPS_FORECAST_4_tb_domestic_dest_forecasting_scored');
