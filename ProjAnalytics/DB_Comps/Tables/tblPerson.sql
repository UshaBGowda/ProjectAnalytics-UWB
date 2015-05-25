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
	AND   TABLE_NAME   = 'tblPerson'
	AND   TABLE_TYPE   = 'BASE TABLE')

	BEGIN
        PRINT 'Backing up table [dbo].[tblPerson]' 
        

        SELECT * INTO #tblPerson FROM dbo.tblPerson

        PRINT 'Dropping table [dbo].[tblPerson]' 
        DROP TABLE dbo.tblPerson

		PRINT 'Creating table [dbo].[tblPerson]' 

			CREATE TABLE [dbo].[tblPerson](
				[ID] [int] IDENTITY(1,1) NOT NULL,
				[FirstName] [varchar](50) NOT NULL,
				[LastName] [varchar](50) NOT NULL,
				[AddressID] [int] NULL,
				[RoleID] [int] NOT NULL DEFAULT 1,
				[EmailAddress] [varchar](50) NULL,
			 CONSTRAINT [PK_tblPerson_ID] PRIMARY KEY CLUSTERED 
			(
				[ID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]

			PRINT 'Created table [tblPerson] successfully'
	   
	   --Insert from Backup table
        PRINT 'Inserting to [dbo].[tblPerson] from backup' 
	   
	   -- SET IDENTITY_INSERT to ON.
	   SET IDENTITY_INSERT dbo.tblPerson ON
        
        INSERT into dbo.tblPerson(
								    [ID] ,
									[FirstName],
									[LastName] ,
									[AddressID] ,
									[RoleID],
									[EmailAddress] 
							    )
							  SELECT
									[ID] ,
									[FirstName],
									[LastName] ,
									[AddressID] ,
									[RoleID],
									[EmailAddress] 
							 FROM #tblPerson
        
        -- SET IDENTITY_INSERT to OFF.
	   SET IDENTITY_INSERT dbo.tblPerson OFF
	    -- DROP THE BACKUP TABLE
        PRINT 'Removing Backup table' 
        DROP TABLE #tblPerson
     END
     ELSE IF  NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo'
	AND   TABLE_NAME   = 'tblPerson'
	AND   TABLE_TYPE   = 'BASE TABLE')
     
	BEGIN
	PRINT 'Creating table [dbo].[tblPerson]'
		
		CREATE TABLE [dbo].[tblPerson](
				[ID] [int] IDENTITY(1,1) NOT NULL,
				[FirstName] [varchar](50) NOT NULL,
				[LastName] [varchar](50) NOT NULL,
				[AddressID] [int] NULL,
				[RoleID] [int] NOT NULL DEFAULT 1,
				[EmailAddress] [varchar](50) NULL,
			 CONSTRAINT [PK_tblPerson_ID] PRIMARY KEY CLUSTERED 
			(
				[ID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]

PRINT 'Created table [tblPerson] successfully'
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
GRANT  SELECT, UPDATE  ON [dbo].[tblPerson]  TO WebApp

GO