# 01_sources

This folder registers all TRUE upstream source tables used by the ETL pipeline.

These are the only real external data origins.  
All downstream ETL modules ultimately depend on these sources.

## Files

### 10_seed_true_sources.sql
- Clears the ETL_SourceChangeTracker table
- Inserts all TRUE upstream source tables
- Safe to re-run anytime
- Must be executed after the infrastructure layer

## When to modify this folder

Only when:
- A new external source is added
- A source is removed
- A source schema or table name changes
