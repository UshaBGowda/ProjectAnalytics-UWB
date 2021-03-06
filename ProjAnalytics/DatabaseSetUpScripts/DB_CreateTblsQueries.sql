USE [master]
GO
ALTER DATABASE [UserAnalytics] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [UserAnalytics] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [UserAnalytics] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [UserAnalytics] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [UserAnalytics] SET ARITHABORT OFF 
GO
ALTER DATABASE [UserAnalytics] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [UserAnalytics] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [UserAnalytics] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [UserAnalytics] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [UserAnalytics] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [UserAnalytics] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [UserAnalytics] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [UserAnalytics] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [UserAnalytics] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [UserAnalytics] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [UserAnalytics] SET  DISABLE_BROKER 
GO
ALTER DATABASE [UserAnalytics] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [UserAnalytics] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [UserAnalytics] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [UserAnalytics] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [UserAnalytics] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [UserAnalytics] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [UserAnalytics] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [UserAnalytics] SET RECOVERY FULL 
GO
ALTER DATABASE [UserAnalytics] SET  MULTI_USER 
GO
ALTER DATABASE [UserAnalytics] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [UserAnalytics] SET DB_CHAINING OFF 
GO
ALTER DATABASE [UserAnalytics] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [UserAnalytics] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'UserAnalytics', N'ON'
GO
USE [UserAnalytics]
GO
/****** Object:  User [Webapp]    Script Date: 6/6/2015 9:31:47 PM ******/
CREATE USER [Webapp] FOR LOGIN [Webapp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [Webapp]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Webapp]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Webapp]
GO
GRANT EXECUTE TO [Webapp]
GO
/****** Object:  StoredProcedure [dbo].[sp_get]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[sp_get]
AS
begin
select * from dbo.tblPerson A
left join dbo.tblAddress B on A.AddressID = B.AddressID
end


GO
/****** Object:  StoredProcedure [dbo].[spAssignProj]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spAssignProj](

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
/****** Object:  StoredProcedure [dbo].[spCreatePerson]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCreatePerson](

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


GO
/****** Object:  StoredProcedure [dbo].[spDeletePerson]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spDeletePerson](

			  @Input            int
			, @Debug            BIT = 0
			, @Error_Message    VARCHAR (1024) = NULL OUTPUT)
    
AS

BEGIN

     
      DECLARE @Return_Code           INT
            , @Object_Name           VARCHAR (256)
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                V A R I A B L E   I N I T I A L I Z A T I O N                                                    --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      
      SET @Return_Code                = 0
      SET @Object_Name                = 'Delete a Person-- : --'
      
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

			delete A from dbo.tblAddress AS A JOIN dbo.tblPerson AS P ON  A.AddressID = P.AddressID where P.ID =  @Input;

			delete from dbo.tblPerson where ID =  @Input;
			SELECT * from dbo.tblPerson
            
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

GRANT EXECUTE ON [spDeletePerson] TO Webapp
GO
/****** Object:  StoredProcedure [dbo].[spGetProjects]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetProjects](

			  @personID           int
			, @Debug            BIT = 0
			, @Error_Message    VARCHAR (1024) = NULL OUTPUT)
    
AS

BEGIN

     
      DECLARE @Return_Code           INT
            , @Object_Name           VARCHAR (256)
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                V A R I A B L E   I N I T I A L I Z A T I O N                                                    --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      
      SET @Return_Code                = 0
      SET @Object_Name                = 'Get project names assigned for a user-- : --'
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                                                        V A L I D A T I O N S                                                   --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      

            BEGIN TRY
                  
                  IF (ISNULL(@personID,'')='')
				       RAISERROR('Invalid/empty personID.', 16, 1)
                  
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

			SELECT * from dbo.tblProject p join dbo.tblUserProjXRef UP ON p.ProjectID = UP.ProjectID where UP.UserID =  @personID;           
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

GRANT EXECUTE ON [spGetProjects] TO Webapp
GO
/****** Object:  StoredProcedure [dbo].[spLogin]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spLogin](

			  @LoginName        VARCHAR(50)
			, @Password			VARCHAR(50)
			, @Debug            BIT = 0
			, @Error_Message    VARCHAR (1024) = NULL OUTPUT)
    
AS

BEGIN

     
      DECLARE @Return_Code           INT
            , @Object_Name           VARCHAR (256)
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                V A R I A B L E   I N I T I A L I Z A T I O N                                                    --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      
      SET @Return_Code                = 0
      SET @Object_Name                = 'Authenticate a Person-- : --'
      
      -- =============================================================================================================================================== --
      --                                                                                                                                                 --
      --                                                                                        V A L I D A T I O N S                                                   --
      --                                                                                                                                                 --
      -- =============================================================================================================================================== --
      

            BEGIN TRY
                  
                  IF (ISNULL(@LoginName,'')='' or ISNULL(@Password,'')='')
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

		
			SELECT * from dbo.tblPerson Where LoginName = @LoginName AND UserPassword = @Password
            
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

GRANT EXECUTE ON dbo.[spLogin] TO Webapp
GO
/****** Object:  Table [dbo].[tblAddress]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblAddress](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[Address1] [varchar](50) NOT NULL,
	[Address2] [varchar](50) NOT NULL,
	[City] [varchar](20) NOT NULL,
	[State] [varchar](2) NOT NULL,
	[Zip] [varchar](5) NOT NULL,
 CONSTRAINT [PK_tblAddress_AddressID] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblPerson]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblPerson](
	[ID] [int] IDENTITY(1000,1) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[LoginName] [varchar](50) NOT NULL,
	[AddressID] [int] NULL,
	[RoleID] [int] NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
	[UserPassword] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tblPerson_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblProject]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblProject](
	[ProjectID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectName] [varchar](50) NOT NULL,
	[ProjectURL] [varchar](100) NOT NULL,
	[CreatedDT] [datetime] NOT NULL,
 CONSTRAINT [PK_tblProject_ProjectID] PRIMARY KEY CLUSTERED 
(
	[ProjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRole]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRole](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NOT NULL,
	[CreatedDT] [datetime] NOT NULL,
 CONSTRAINT [PK_tblRole_RoleID] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserProjXRef]    Script Date: 6/6/2015 9:31:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserProjXRef](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ProjectID] [int] NOT NULL,
	[CreatedDT] [datetime] NOT NULL,
	[ModifiedDT] [datetime] NOT NULL,
	[ActiveFlag] [bit] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
 CONSTRAINT [PK_tblUserProjXRef_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[tblAddress] ON 

INSERT [dbo].[tblAddress] ([AddressID], [Address1], [Address2], [City], [State], [Zip]) VALUES (106, N'18115 Campus Way NE', N'', N'Bothell', N'WA', N'98011')
INSERT [dbo].[tblAddress] ([AddressID], [Address1], [Address2], [City], [State], [Zip]) VALUES (107, N'18115 Campus Way NE', N'', N'Bothell', N'WA', N'98011')
SET IDENTITY_INSERT [dbo].[tblAddress] OFF
SET IDENTITY_INSERT [dbo].[tblPerson] ON 

INSERT [dbo].[tblPerson] ([ID], [FirstName], [LastName], [LoginName], [AddressID], [RoleID], [EmailAddress], [UserPassword]) VALUES (1010, N'Emily', N'Howell', N'EmilyH', 106, 1, N'emily@uw.edu', N'password')
INSERT [dbo].[tblPerson] ([ID], [FirstName], [LastName], [LoginName], [AddressID], [RoleID], [EmailAddress], [UserPassword]) VALUES (1011, N'Dennis', N'Ritchie', N'DennisR', 107, 2, N'Dennis@uw.edu', N'password')
SET IDENTITY_INSERT [dbo].[tblPerson] OFF
SET IDENTITY_INSERT [dbo].[tblProject] ON 

INSERT [dbo].[tblProject] ([ProjectID], [ProjectName], [ProjectURL], [CreatedDT]) VALUES (1, N'BrainGrid', N'BrainGrid', CAST(0x0000A4A301322D87 AS DateTime))
INSERT [dbo].[tblProject] ([ProjectID], [ProjectName], [ProjectURL], [CreatedDT]) VALUES (2, N'Octokit', N'Octokit', CAST(0x0000A4A301322D89 AS DateTime))
INSERT [dbo].[tblProject] ([ProjectID], [ProjectName], [ProjectURL], [CreatedDT]) VALUES (3, N'ProjectAnalytics-UWB', N'ProjectAnalytics-UWB', CAST(0x0000A4A301322D8A AS DateTime))
SET IDENTITY_INSERT [dbo].[tblProject] OFF
SET IDENTITY_INSERT [dbo].[tblRole] ON 

INSERT [dbo].[tblRole] ([RoleID], [RoleName], [CreatedDT]) VALUES (1, N'Admin', CAST(0x0000A4A801404890 AS DateTime))
INSERT [dbo].[tblRole] ([RoleID], [RoleName], [CreatedDT]) VALUES (2, N'Manager', CAST(0x0000A4A8014056FF AS DateTime))
SET IDENTITY_INSERT [dbo].[tblRole] OFF
SET IDENTITY_INSERT [dbo].[tblUserProjXRef] ON 

INSERT [dbo].[tblUserProjXRef] ([ID], [UserID], [ProjectID], [CreatedDT], [ModifiedDT], [ActiveFlag], [ModifiedBy]) VALUES (24, 1010, 1, CAST(0x0000A4AF015FDD16 AS DateTime), CAST(0x0000A4AF015FDD16 AS DateTime), 1, 1010)
INSERT [dbo].[tblUserProjXRef] ([ID], [UserID], [ProjectID], [CreatedDT], [ModifiedDT], [ActiveFlag], [ModifiedBy]) VALUES (25, 1010, 2, CAST(0x0000A4AF015FDD16 AS DateTime), CAST(0x0000A4AF015FDD16 AS DateTime), 1, 1010)
INSERT [dbo].[tblUserProjXRef] ([ID], [UserID], [ProjectID], [CreatedDT], [ModifiedDT], [ActiveFlag], [ModifiedBy]) VALUES (26, 1010, 3, CAST(0x0000A4AF015FDD16 AS DateTime), CAST(0x0000A4AF015FDD16 AS DateTime), 1, 1010)
INSERT [dbo].[tblUserProjXRef] ([ID], [UserID], [ProjectID], [CreatedDT], [ModifiedDT], [ActiveFlag], [ModifiedBy]) VALUES (27, 1011, 2, CAST(0x0000A4AF015FEC38 AS DateTime), CAST(0x0000A4AF015FEC38 AS DateTime), 1, 1010)
INSERT [dbo].[tblUserProjXRef] ([ID], [UserID], [ProjectID], [CreatedDT], [ModifiedDT], [ActiveFlag], [ModifiedBy]) VALUES (28, 1011, 3, CAST(0x0000A4AF015FEC38 AS DateTime), CAST(0x0000A4AF015FEC38 AS DateTime), 1, 1010)
SET IDENTITY_INSERT [dbo].[tblUserProjXRef] OFF
ALTER TABLE [dbo].[tblPerson] ADD  DEFAULT ((1)) FOR [RoleID]
GO
ALTER TABLE [dbo].[tblProject] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[tblRole] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[tblUserProjXRef] ADD  DEFAULT (getdate()) FOR [ModifiedDT]
GO
ALTER TABLE [dbo].[tblUserProjXRef] ADD  DEFAULT ((1)) FOR [ActiveFlag]
GO
USE [master]
GO
ALTER DATABASE [UserAnalytics] SET  READ_WRITE 
GO
