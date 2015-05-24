GO
/*
Table Name:	 tblAddress
Created by:	 Usha
Date: 		 05/17/2015
Version: 		 1.0

Purpose:  This table is used to hold information about dev and PM
*/
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		 IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
			WHERE TABLE_SCHEMA = 'dbo'
			AND   TABLE_NAME   = 'tblAddress'
			AND   TABLE_TYPE   = 'BASE TABLE')

			BEGIN
				Drop Table dbo.tblAddress
				PRINT 'Dropping table [dbo].[tblAddress]' 
			END

			CREATE TABLE dbo.tblAddress
				(      
					  ID			INT	IDENTITY (1, 1)			NOT NULL CONSTRAINT PK_tblAddress_ID PRIMARY KEY
					, Address1 VARCHAR(50) NOT NULL
					, Address2 VARCHAR(50) NOT NULL
					, City VARCHAR(20) NOT NULL
					, State VARCHAR(2) NOT NULL
					, Zip VARCHAR(5) NOT NULL
			)
			PRINT 'Created table [tblAddress] successfully'
		COMMIT TRANSACTION
	  END TRY
	  BEGIN CATCH
		   PRINT 'Error while creating table [dbo].[tblAddress] - Error Message: ' + ERROR_MESSAGE()
		   ROLLBACK TRANSACTION
	  END CATCH
END

GO 

------------------------------------------------------------------
--  Finally, GRANT
------------------------------------------------------------------
GRANT  SELECT, UPDATE  ON [dbo].[tblAddress]  TO [Webapp]

GO