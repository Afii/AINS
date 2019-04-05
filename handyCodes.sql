/***ALL jobs and execution status***/
SELECT sj.name
   , sja.*
FROM msdb.dbo.sysjobactivity AS sja
INNER JOIN msdb.dbo.sysjobs AS sj ON sja.job_id = sj.job_id
WHERE sja.start_execution_date IS NOT NULL and start_execution_date>'2019-02-17'
order by run_requested_date desc


/***list of tables in a database***/
SELECT * FROM [INFORMATION_SCHEMA].[TABLES]
 /**OR**/
 SELECT *
 FROM sysobjects WHERE xtype = 'U'
 



 /**list of all tables with specified column name**/
  
  SELECT      c.name  AS 'ColumnName'
            ,t.name AS 'TableName'
FROM        sys.columns c
JOIN        sys.tables  t   ON c.object_id = t.object_id
WHERE       c.name LIKE '%subsys%' and c.name not LIKE '%subsystem%'
ORDER BY    TableName
            ,ColumnName;



/*** List of all packages under all SQL Agent jobs ***/
select 
    --Job Information
     a.job_id
    ,a.name
    ,a.description
    --SSIS package Information
    ,b.name
    ,b.id
    ,b.description
    --Job steps Information
    ,js.step_id
    ,js.step_name
    ,js.subsystem
    ,js.command

 from  msdb.dbo.sysjobs  a 
Left Join msdb.dbo.sysjobsteps js on js.job_id=a.job_id 
left join msdb.dbo.sysssispackages b
on a.name=b.name



/*** SSIS Expression - Replace **/
/*      "\"" in expression means/returns " and "\"\"" means ""        */
 
 -- THE CODE --      "\"" + REPLACE(data,"\"","\"\"") + "\""



/** prepares list of same command in bulk over a range of objects **/
DECLARE @SqlStatement NVARCHAR(MAX)
SELECT @SqlStatement = 
    COALESCE(@SqlStatement, N'') + N'DROP TABLE [PLAN_DEV].' + QUOTENAME(TABLE_NAME) + N';' + CHAR(13)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME like 'TBD%' and TABLE_TYPE = 'BASE TABLE'

PRINT @SqlStatement