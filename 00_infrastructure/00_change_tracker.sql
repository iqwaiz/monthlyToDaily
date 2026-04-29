/* ------------------------------------------------------------
   00_change_tracker
   ------------------------------------------------------------
   Description:
     Creates the ETL_SourceChangeTracker table used to track
     upstream source changes.

   Instructions:
     Run this file before any other ETL scripts.
------------------------------------------------------------ */

--USE ibraheem_test;
--

IF OBJECT_ID('dailyData.ETL_SourceChangeTracker') IS NOT NULL
    DROP TABLE dailyData.ETL_SourceChangeTracker;

CREATE TABLE dailyData.ETL_SourceChangeTracker (
    source_name        SYSNAME         NOT NULL PRIMARY KEY,
    object_schema      SYSNAME         NOT NULL,
    object_name        SYSNAME         NOT NULL,
    last_checksum      VARBINARY(8000) NULL,
    last_change_time   DATETIME        NULL,
    last_etl_run_time  DATETIME        NULL,
    is_active          BIT             NOT NULL DEFAULT (1)
);
