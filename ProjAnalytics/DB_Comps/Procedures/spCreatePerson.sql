USE [UserAnalytics]
GO
/****** Object:  StoredProcedure [dbo].[spCreatePerson]    Script Date: 5/19/2015 7:09:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spCreatePerson](

			  @Input            VARCHAR(MAX)
			, @Debug            BIT = 0
			, @PersonID         INT = 0 OUTPUT
			, @Error_Message    VARCHAR (1024) = NULL OUTPUT)
    
AS

BEGIN

     
      DECLARE @Return_Code           INT
            , @Object_Name           VARCHAR (256)
			, @xmlHandle INT, @AdID INT, @PerID INT
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                V A R I A B L E   I N I T I A L I Z A T I O N                                                    --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      
      SET @Return_Code                = 0
      SET @Object_Name                = 'Create a new Person-- : --'
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                                                        V A L I D A T I O N S                                                   --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      

            BEGIN TRY
                  
                  IF (ISNULL(@Input,'')='')
				       RAISERROR('Invalid/empty Input.', 16, 1)
                  
            END TRY
            
            BEGIN CATCH
            
                  SET @Error_Message = ERROR_MESSAGE()
                  SET @Error_Message = @Object_Name + ISNULL(@Error_Message, '')
                  SET @Return_Code = 1
                  GOTO Procedure_Exit
                        
            END CATCH
            
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                        U P D A T I O N S                                                   --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      BEGIN TRANSACTION
                              
            BEGIN TRY

			
			EXEC sp_xml_preparedocument @xmlHandle OUTPUT, @Input

			SELECT @PerID = ID FROM OPENXML(@xmlHandle, 'Person')
								WITH 
								(
								ID [int] 'ID'
								);

			IF(ISNULL(@PerID,0)>0)
			BEGIN
			SELECT @AdID = tblPerson.AddressID from dbo.tblPerson Where ID = @PerID

				;WITH  Input_Data as (
					    SELECT @AdID as ID, Address1, Address2, City, [State], Zip FROM OPENXML(@xmlHandle, 'Person/Person_Address')
								WITH 
								(
								Address1 [varchar](50) 'Address1',
								Address2 [varchar](50) 'Address2',
								State [varchar](2) 'State',
								Zip [varchar](5) 'ZIP',
								City [varchar](20) 'City'
								
								)
					)
					Update dbo.tblAddress 
						SET tblAddress.Address1 = Input_Data.Address1,
							tblAddress.Address2 = Input_Data.Address2,
							tblAddress.[State] = Input_Data.[State],
							tblAddress.Zip = Input_Data.Zip,
							tblAddress.City = Input_Data.City
							FROM dbo.tblAddress t1
							 INNER JOIN Input_Data  ON t1.AddressID = Input_Data.ID

				;WITH  Input_Data as (
					   			SELECT [FirstName], [LastName],LoginName, ID,EmployeeRole,EmailAddress,Pwd FROM OPENXML(@xmlHandle, 'Person')
								WITH 
								(
								FirstName [varchar](50) 'FirstName',
								LastName [varchar](50) 'LastName',
								LoginName [Varchar](50) 'LoginName',
								ID [int] 'ID',
								EmployeeRole [varchar](50) 'RoleID',
								EmailAddress [varchar](50) 'EmailAddress',
								Pwd [varchar](20) 'userPassword'
								)
					)
					Update dbo.tblPerson
						SET FirstName = Input_Data.FirstName,
							LastName = Input_Data.LastName,
							RoleID = Input_Data.EmployeeRole,
							EmailAddress = Input_Data.EmailAddress,
							UserPassword = Input_Data.Pwd,
							LoginName = Input_Data.LoginName
							FROM dbo.tblPerson t1
							INNER JOIN Input_Data ON t1.ID=Input_Data.ID
							

				select * from dbo.tblPerson A join dbo.tblAddress B on A.AddressID = B.AddressID
                         where A.ID = @PerID

			END
			ELSE
			BEGIN

			INSERT INTO [dbo].[tblAddress]
					   ([Address1]
					   ,[Address2]
					   ,[City]
					   ,[State]
					   ,[Zip])
				 
					    SELECT  Address1, Address2, City, [State], Zip FROM OPENXML(@xmlHandle, 'Person/Person_Address')
								WITH 
								(
								Address1 [varchar](50) 'Address1',
								Address2 [varchar](50) 'Address2',
								State [varchar](2) 'State',
								Zip [varchar](5) 'ZIP',
								City [varchar](20) 'City'
								);
					SELECT @AdID = SCOPE_IDENTITY()	

				INSERT INTO [dbo].[tblPerson]
					   ([FirstName]
					   ,[LastName]
					   ,LoginName
					   ,AddressID
					   ,RoleID
					   ,EmailAddress,
					   UserPassword
					   )
				 
					    SELECT [FirstName], [LastName],LoginName, @AdID,EmployeeRole,EmailAddress,Pwd FROM OPENXML(@xmlHandle, 'Person')
								WITH 
								(
								FirstName [varchar](50) 'FirstName',
								LastName [varchar](50) 'LastName',
								LoginName [Varchar](50) 'LoginName',
								EmployeeRole [varchar](50) 'RoleID',
								EmailAddress [varchar](50) 'EmailAddress',
								Pwd [varchar](20) 'userPassword'
								);
			
				SELECT @PersonID = SCOPE_IDENTITY()	
            
					select * from dbo.tblPerson A join dbo.tblAddress B on A.AddressID = B.AddressID
                         where A.ID = @PersonID
                   END     
            END TRY

            BEGIN CATCH

                  SET @Error_Message = ERROR_MESSAGE()
                        SET @Error_Message = @Object_Name + ISNULL(@Error_Message, '')
                        SET @Return_Code = 1
                        GOTO Procedure_Exit
                        
            END CATCH
      
      COMMIT TRANSACTION      
      
                        
      Procedure_Exit:
      
      IF XACT_STATE() <> 0 
            ROLLBACK TRANSACTION

      RETURN @Return_Code

END

