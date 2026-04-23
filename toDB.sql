
DECLARE @T NVARCHAR(200) = 'table';
DECLARE @Full NVARCHAR(300) = 'ibraheem_test.dailyData.' + @T;
DECLARE @SQL NVARCHAR(MAX);

IF OBJECT_ID(@Full) IS NULL
    SET @SQL = 'SELECT * INTO ' + @Full + ' FROM #' + @T + ';';
ELSE
    SET @SQL = 'TRUNCATE TABLE ' + @Full + '; INSERT INTO ' + @Full + ' SELECT * FROM #' + @T + ';';

EXEC(@SQL);
EXEC('SELECT * FROM '+@Full);