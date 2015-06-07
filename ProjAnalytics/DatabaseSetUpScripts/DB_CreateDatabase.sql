USE [master]
GO

/****** Object:  Database [UserAnalytics]    Script Date: 6/6/2015 9:23:43 PM ******/
CREATE DATABASE [UserAnalytics]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'UserAnalytics', FILENAME = N'C:\database\UserAnalytics.mdf' , SIZE = 6848KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'UserAnalytics_log', FILENAME = N'C:\database\UserAnalytics_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [UserAnalytics] SET COMPATIBILITY_LEVEL = 110
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [UserAnalytics].[dbo].[sp_fulltext_database] @action = 'enable'
end
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

ALTER DATABASE [UserAnalytics] SET  READ_WRITE 
GO

