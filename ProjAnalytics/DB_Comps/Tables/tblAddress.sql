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
	AND   TABLE_NAME   = 'tblAddress'
	AND   TABLE_TYPE   = 'BASE TABLE')

	BEGIN
        PRINT 'Backing up table [dbo].[tblAddress]' 
        

        SELECT * INTO #tblAddress FROM dbo.tblAddress

        PRINT 'Dropping table [dbo].[tblAddress]' 
        DROP TABLE dbo.tblAddress

		PRINT 'Creating table [dbo].[tblAddress]' 

			CREATE TABLE dbo.tblAddress
				(      
					  AddressID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblAddress_AddressID PRIMARY KEY
					, Address1 VARCHAR(50) NOT NULL
					, Address2 VARCHAR(50) NOT NULL
					, City VARCHAR(20) NOT NULL
					, State VARCHAR(2) NOT NULL
					, Zip VARCHAR(5) NOT NULL
			)

			PRINT 'Created table [tblAddress] successfully'
	   
	   --Insert from Backup table
        PRINT 'Inserting to [dbo].[tblAddress] from backup' 
	   
	   -- SET IDENTITY_INSERT to ON.
	   SET IDENTITY_INSERT dbo.tblAddress ON
        
        INSERT into dbo.tblAddress(
								     AddressID		
									, Address1 
									, Address2 
									, City 
									, State
									, Zip 
							    )
							  SELECT
									  AddressID		
									, Address1 
									, Address2 
									, City 
									, State
									, Zip 
							 FROM #tblAddress
        
        -- SET IDENTITY_INSERT to OFF.
	   SET IDENTITY_INSERT dbo.tblAddress OFF
	    -- DROP THE BACKUP TABLE
        PRINT 'Removing Backup table' 
        DROP TABLE #tblAddress
     END
     ELSE IF  NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo'
	AND   TABLE_NAME   = 'tblAddress'
	AND   TABLE_TYPE   = 'BASE TABLE')
     
	BEGIN
	PRINT 'Creating table [dbo].[tblAddress]'
		
		CREATE TABLE dbo.tblAddress
				(      
					  AddressID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblAddress_AddressID PRIMARY KEY
					, Address1 VARCHAR(50) NOT NULL
					, Address2 VARCHAR(50) NOT NULL
					, City VARCHAR(20) NOT NULL
					, State VARCHAR(2) NOT NULL
					, Zip VARCHAR(5) NOT NULL
			)

PRINT 'Created table [tblAddress] successfully'
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
GRANT  SELECT, UPDATE  ON [dbo].[tblAddress]  TO WebApp

GO