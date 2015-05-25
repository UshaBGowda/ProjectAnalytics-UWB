USE [UserAnalytics]
GO

BEGIN
BEGIN TRANSACTION
BEGIN TRY

DECLARE @ErrMsg          VARCHAR(256)
-------------------------------------------------------------------
--  Backup and Drop/Create the Table(s)
-------------------------------------------------------------------


  IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo'
	AND   TABLE_NAME   = 'tblProject'
	AND   TABLE_TYPE   = 'BASE TABLE')

	BEGIN
        PRINT 'Backing up table [dbo].[tblProject]' 
        

        SELECT * INTO #tblProject FROM dbo.tblProject

        PRINT 'Dropping table [dbo].[tblProject]' 
        DROP TABLE dbo.tblProject

		PRINT 'Creating table [dbo].[tblProject]' 

			CREATE TABLE dbo.tblProject
				(      
					  ProjectID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblProject_ProjectID PRIMARY KEY
					, ProjectName VARCHAR(50) NOT NULL
					,ProjectURL VARCHAR(100) NOT NULL
					, CreatedDT DATETIME NOT NULL DEFAULT GETDATE()
								)

			PRINT 'Created table [tblProject] successfully'
	   
	   --Insert from Backup table
        PRINT 'Inserting to [dbo].[tblProject] from backup' 
	   
	   -- SET IDENTITY_INSERT to ON.
	   SET IDENTITY_INSERT dbo.tblProject ON
        
        INSERT into dbo.tblProject(
								     ProjectID		
									, ProjectName 
									,ProjectURL
									, CreatedDT 
									 
							    )
							  SELECT
									 ProjectID		
									, ProjectName 
									,ProjectURL
									, CreatedDT 
							 FROM #tblProject
        
        -- SET IDENTITY_INSERT to OFF.
	   SET IDENTITY_INSERT dbo.tblProject OFF
	    -- DROP THE BACKUP TABLE
        PRINT 'Removing Backup table' 
        DROP TABLE #tblProject
     END
     ELSE IF  NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo'
	AND   TABLE_NAME   = 'tblProject'
	AND   TABLE_TYPE   = 'BASE TABLE')
     
	BEGIN
	PRINT 'Creating table [dbo].[tblProject]'
		
		CREATE TABLE dbo.tblProject
				(      
					  ProjectID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblProject_ProjectID PRIMARY KEY
					, ProjectName VARCHAR(50) NOT NULL
					,ProjectURL VARCHAR(100) NOT NULL
					, CreatedDT DATETIME NOT NULL DEFAULT GETDATE()
								)

PRINT 'Created table [tblProject] successfully'
	END   
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
	   SET @ErrMsg = ERROR_MESSAGE()
	   SET @ErrMsg  = 'Error Encountered:' + ISNULL(@ErrMsg, '')
	   RAISERROR(@ErrMsg, 16, 1)
	   ROLLBACK TRANSACTION
  END CATCH
END

GO 



------------------------------------------------------------------
--  Finally, GRANT
------------------------------------------------------------------
GRANT  SELECT, UPDATE  ON [dbo].[tblProject]  TO WebApp

GO