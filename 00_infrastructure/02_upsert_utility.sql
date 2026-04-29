--USE ibraheem_test;

-----

CREATE OR ALTER PROCEDURE dailyData.usp_UpsertDailyTable
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Full NVARCHAR(300) = 'dailyData.' + @TableName;
    DECLARE @SQL  NVARCHAR(MAX);

    -- Drop persistent table if exists
    IF OBJECT_ID(@Full) IS NOT NULL
        SET @SQL = 'DROP TABLE ' + @Full + '; ';
    ELSE
        SET @SQL = '';

    -- Always recreate from #result
    SET @SQL = @SQL + 'SELECT * INTO ' + @Full + ' FROM #result;';

    EXEC(@SQL);

    EXEC('SELECT * FROM ' + @Full);
END;

-----


/*------------------------------------------------------------
 Usage:
 EXEC ibraheem_test.dailyData.usp_UpsertDailyTable 'tableName';
------------------------------------------------------------*/ 