USE [UserAnalytics]
GO
/****** Object:  StoredProcedure [dbo].[spAssignProj]    Script Date: 5/19/2015 7:09:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spAssignProj](

			  @Input            VARCHAR(MAX)
			, @Debug            BIT = 0
			, @UserProjXRefID         INT = 0 OUTPUT
			, @Error_Message    VARCHAR (1024) = NULL OUTPUT)
    
AS

BEGIN

     
      DECLARE @Return_Code           INT
            , @Object_Name           VARCHAR (256)
			, @xmlHandle INT, @ModifiedID INT, @PerID INT
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                V A R I A B L E   I N I T I A L I Z A T I O N                                                    --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      
      SET @Return_Code                = 0
      SET @Object_Name                = 'Assign projec to user-- : --'
      
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

			SELECT @PerID = Assignee, @ModifiedID = Modifier FROM OPENXML(@xmlHandle, 'UserProjects')
								WITH 
								(
								Assignee [int] 'Assignee/ID',
								Modifier [int] 'Modifier/ID'
								);

			DECLARE @XMLDoc2 XML
			SELECT @XMLDoc2 = @Input

		

				INSERT INTO [dbo].[tblUserProjXRef]
					  (
					  UserID
				,ProjectID
				,CreatedDT 
				,ModifiedDT
				,ActiveFlag
				,ModifiedBy 
					   )
				 
					    --SELECT @PerID,projectID,GETDATE(),GETDATE(),1,@ModifiedID FROM OPENXML(@xmlHandle, 'UserProjects/ProjectIDs')
	select @PerID,x.value(N'.', N'int') as projectID,GETDATE(),GETDATE(),1,@ModifiedID
			from @XMLDoc2.nodes(N'/UserProjects/ProjectIDs/int') t(x);
								--WITH 
								--(
						        --projectID int 'int'
								--);
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

GO
GRANT EXECUTE ON dbo.spAssignProj TO Webapp

