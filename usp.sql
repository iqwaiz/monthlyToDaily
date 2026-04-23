USE ibraheem_test;

-----

CREATE OR ALTER PROCEDURE dailyData.usp_UpsertDailyTable
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Full NVARCHAR(300) = 'dailyData.' + @TableName;
    DECLARE @SQL  NVARCHAR(MAX);

    IF OBJECT_ID(@Full) IS NULL
        SET @SQL = 'SELECT * INTO ' + @Full + ' FROM #' + @TableName + ';';
    ELSE
        SET @SQL = 'TRUNCATE TABLE ' + @Full + '; INSERT INTO ' + @Full + ' SELECT * FROM #' + @TableName + ';';

    EXEC(@SQL);

    EXEC('SELECT * FROM ' + @Full);
END;

-----


/*------------------------------------------------------------
 Usage:
 EXEC ibraheem_test.dailyData.usp_UpsertDailyTable 'tableName';
------------------------------------------------------------*/ 