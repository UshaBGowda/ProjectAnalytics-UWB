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
	AND   TABLE_NAME   = 'tblUserProjXRef'
	AND   TABLE_TYPE   = 'BASE TABLE')

	BEGIN
        PRINT 'Backing up table [dbo].[tblUserProjXRef]' 
        

        SELECT * INTO #tblUserProjXRef FROM dbo.tblUserProjXRef

        PRINT 'Dropping table [dbo].[tblUserProjXRef]' 
        DROP TABLE dbo.tblUserProjXRef

		PRINT 'Creating table [dbo].[tblUserProjXRef]' 

			CREATE TABLE [dbo].[tblUserProjXRef](
				[ID] [int] IDENTITY(1,1) NOT NULL,
				[UserID] [int] NOT NULL,
				ProjectID int NOT NULL,
				CreatedDT DATETIME NOT NULL,
				ModifiedDT DATETIME NOT NULL DEFAULT GETDATE(),
				ActiveFlag BIT NOT NULL DEFAULT 1,
				ModifiedBy int NOT NULL
			 CONSTRAINT [PK_tblUserProjXRef_ID] PRIMARY KEY CLUSTERED 
			(
				[ID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]

			PRINT 'Created table [tblUserProjXRef] successfully'
	   
	   --Insert from Backup table
        PRINT 'Inserting to [dbo].[tblUserProjXRef] from backup' 
	   
	   -- SET IDENTITY_INSERT to ON.
	   SET IDENTITY_INSERT dbo.tblUserProjXRef ON
        
        INSERT into dbo.tblUserProjXRef(
								   [ID] ,
				[UserID],
				ProjectID,
				CreatedDT ,
				ModifiedDT ,
				ActiveFlag ,
				ModifiedBy 
											    )
							  SELECT
			   [ID] ,
				[UserID],
				ProjectID,
				CreatedDT ,
				ModifiedDT ,
				ActiveFlag ,
				ModifiedBy 
					 
							 FROM #tblUserProjXRef
        
        -- SET IDENTITY_INSERT to OFF.
	   SET IDENTITY_INSERT dbo.tblUserProjXRef OFF
	    -- DROP THE BACKUP TABLE
        PRINT 'Removing Backup table' 
        DROP TABLE #tblUserProjXRef
     END
     ELSE IF  NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo'
	AND   TABLE_NAME   = 'tblUserProjXRef'
	AND   TABLE_TYPE   = 'BASE TABLE')
     
	BEGIN
	PRINT 'Creating table [dbo].[tblUserProjXRef]'
		
		CREATE TABLE [dbo].[tblUserProjXRef](
				[ID] [int] IDENTITY(1,1) NOT NULL,
				[UserID] [int] NOT NULL,
				ProjectID int NOT NULL,
				CreatedDT DATETIME NOT NULL,
				ModifiedDT DATETIME NOT NULL DEFAULT GETDATE(),
				ActiveFlag BIT NOT NULL DEFAULT 1,
				ModifiedBy int NOT NULL
			 CONSTRAINT [PK_tblUserProjXRef_ID] PRIMARY KEY CLUSTERED 
			(
				[ID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]

PRINT 'Created table [tblUserProjXRef] successfully'
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
GRANT  SELECT, UPDATE  ON [dbo].[tblUserProjXRef]  TO WebApp

GO