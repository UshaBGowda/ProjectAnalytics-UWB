USE [UserAnalytics]
GO

/****** Object:  StoredProcedure [dbo].[sp_get]    Script Date: 5/25/2015 4:42:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER Procedure [dbo].[sp_get]
AS
begin
select * from dbo.tblPerson A
left join dbo.tblAddress B on A.AddressID = B.AddressID
end

GO


