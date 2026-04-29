/* ======================================================================================================================
   File:            20_modules_and_dependencies.sql
   Layer:           /02_metadata
   Purpose:         Defines all ETL modules and their dependencies on TRUE upstream sources.
                    This metadata drives the change‑detection engine and the module execution controller.

   Execution Order: Run AFTER:
                      - /00_infrastructure
                      - /01_sources

   Re-run Safety:   Safe to re-run anytime. This script DROPs and recreates metadata tables.
   Author:          Ibraheem
   Version:         1.1.0
   Change Log:
                      - 1.1.0 : Updated module procedure names to include `_daily_` prefix.
                      - 1.0.0 : Initial metadata creation.
====================================================================================================================== */

--USE ibraheem_test;
--

/* ======================================================================================================================
   1. Reset metadata tables
====================================================================================================================== */

IF OBJECT_ID('dailyData.ETL_Dependencies') IS NOT NULL
    DROP TABLE dailyData.ETL_Dependencies;

IF OBJECT_ID('dailyData.ETL_Modules') IS NOT NULL
    DROP TABLE dailyData.ETL_Modules;

/* ======================================================================================================================
   2. Create ETL_Modules
====================================================================================================================== */

CREATE TABLE dailyData.ETL_Modules (
    module_name      SYSNAME       NOT NULL PRIMARY KEY,
    proc_name        SYSNAME       NOT NULL,
    module_order     INT           NOT NULL,
    is_active        BIT           NOT NULL DEFAULT (1),
    module_version   VARCHAR(20)   NULL
);

/* ======================================================================================================================
   3. Create ETL_Dependencies
====================================================================================================================== */

CREATE TABLE dailyData.ETL_Dependencies (
    source_name   SYSNAME NOT NULL,
    module_name   SYSNAME NOT NULL,
    PRIMARY KEY (source_name, module_name)
);

/* ======================================================================================================================
   4. Seed ETL Modules (Corrected `_daily_` procedure names)
====================================================================================================================== */

INSERT INTO dailyData.ETL_Modules (module_name, proc_name, module_order, module_version)
VALUES
    ('domestic_facts',       'usp_build_daily_domestic_facts',       30, '1.1.0'),
    ('inbound_facts',        'usp_build_daily_inbound_facts',        31, '1.1.0'),
    ('targets',              'usp_build_targets',                    32, '1.0.0'),
    ('domestic_estimates',   'usp_build_daily_domestic_estimates',   33, '1.1.0'),
    ('inbound_estimates',    'usp_build_daily_inbound_estimates',    34, '1.1.0'),
    ('domestic_predictions', 'usp_build_daily_domestic_predictions', 35, '1.1.0'),
    ('inbound_predictions',  'usp_build_daily_inbound_predictions',  36, '1.1.0'),
    ('border',               'usp_build_border',                     37, '1.0.0'),
    ('all_daily_data',       'usp_build_all_daily_data',             38, '1.0.0');

/* ======================================================================================================================
   5. Seed Dependencies
====================================================================================================================== */

INSERT INTO dailyData.ETL_Dependencies (source_name, module_name)
VALUES
    -- Domestic facts
    ('Fact_Visits',        'domestic_facts'),
    ('Fact_Spend',         'domestic_facts'),

    -- Inbound facts
    ('Fact_Visits',        'inbound_facts'),
    ('Fact_Spend',         'inbound_facts'),

    -- Targets
    ('Fact_Visits_Target', 'targets'),
    ('Fact_Spend_Target',  'targets'),

    -- Domestic estimates
    ('Estimates_Flows',    'domestic_estimates'),
    ('Estimates_MAS',      'domestic_estimates'),

    -- Inbound estimates
    ('Estimates_Flows',    'inbound_estimates'),
    ('Estimates_MAS',      'inbound_estimates'),

    -- Predictions
    ('Pred_Domestic',      'domestic_predictions'),
    ('Pred_Inbound',       'inbound_predictions'),

    -- Border
    ('Border_Inbound',     'border');
