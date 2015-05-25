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
	AND   TABLE_NAME   = 'tblRole'
	AND   TABLE_TYPE   = 'BASE TABLE')

	BEGIN
        PRINT 'Backing up table [dbo].[tblRole]' 
        

        SELECT * INTO #tblRole FROM dbo.tblRole

        PRINT 'Dropping table [dbo].[tblRole]' 
        DROP TABLE dbo.tblRole

		PRINT 'Creating table [dbo].[tblRole]' 

			CREATE TABLE dbo.tblRole
				(      
					  RoleID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblRole_RoleID PRIMARY KEY
					, RoleName VARCHAR(50) NOT NULL
					, CreatedDT DATETIME NOT NULL DEFAULT GETDATE()
								)

			PRINT 'Created table [tblRole] successfully'
	   
	   --Insert from Backup table
        PRINT 'Inserting to [dbo].[tblRole] from backup' 
	   
	   -- SET IDENTITY_INSERT to ON.
	   SET IDENTITY_INSERT dbo.tblRole ON
        
        INSERT into dbo.tblRole(
								     RoleID		
									, RoleName 
									, CreatedDT 
									 
							    )
							  SELECT
									 RoleID		
									, RoleName 
									, CreatedDT 
							 FROM #tblRole
        
        -- SET IDENTITY_INSERT to OFF.
	   SET IDENTITY_INSERT dbo.tblRole OFF
	    -- DROP THE BACKUP TABLE
        PRINT 'Removing Backup table' 
        DROP TABLE #tblRole
     END
     ELSE IF  NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo'
	AND   TABLE_NAME   = 'tblRole'
	AND   TABLE_TYPE   = 'BASE TABLE')
     
	BEGIN
	PRINT 'Creating table [dbo].[tblRole]'
		
		CREATE TABLE dbo.tblRole
				(      
					  RoleID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblRole_RoleID PRIMARY KEY
					, RoleName VARCHAR(50) NOT NULL
					, CreatedDT DATETIME NOT NULL DEFAULT GETDATE()
								)

PRINT 'Created table [tblRole] successfully'
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
GRANT  SELECT, UPDATE  ON [dbo].[tblRole]  TO WebApp

GO