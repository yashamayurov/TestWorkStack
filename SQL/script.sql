USE [master]
GO
/****** Object:  Database [TestWork]    Script Date: 15.12.2022 12:48:37 ******/
CREATE DATABASE [TestWork]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TestWork', FILENAME = N'/var/opt/mssql/data/TestWork.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TestWork_log', FILENAME = N'/var/opt/mssql/data/TestWork_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [TestWork] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TestWork].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TestWork] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TestWork] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TestWork] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TestWork] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TestWork] SET ARITHABORT OFF 
GO
ALTER DATABASE [TestWork] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [TestWork] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TestWork] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TestWork] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TestWork] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TestWork] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TestWork] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TestWork] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TestWork] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TestWork] SET  ENABLE_BROKER 
GO
ALTER DATABASE [TestWork] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TestWork] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TestWork] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TestWork] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TestWork] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TestWork] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TestWork] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TestWork] SET RECOVERY FULL 
GO
ALTER DATABASE [TestWork] SET  MULTI_USER 
GO
ALTER DATABASE [TestWork] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TestWork] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TestWork] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TestWork] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TestWork] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [TestWork] SET QUERY_STORE = OFF
GO
USE [TestWork]
GO
/****** Object:  Schema [stack]    Script Date: 15.12.2022 12:48:37 ******/
CREATE SCHEMA [stack]
GO
/****** Object:  UserDefinedFunction [stack].[calculate_total_price_for_orders_group]    Script Date: 15.12.2022 12:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [stack].[calculate_total_price_for_orders_group](@igGroup INT)
RETURNS INT
AS 
BEGIN
	DECLARE @result INT;
	WITH OrderTree (ID, ParentID, Name)
	AS
	(
	 SELECT row_id, parent_id, group_name
	 FROM stack.Orders O
	 WHERE o.row_id = @igGroup
	 UNION ALL
	 SELECT row_id, parent_id, group_name
	 FROM stack.Orders O
	 JOIN OrderTree rec ON o.parent_id = rec.ID
	)

	SELECT @result = sum(price)
	FROM OrderTree OD 
		LEFT JOIN stack.OrderItems OI	ON OD.ID = OI.order_id
	RETURN @result
END 
GO
/****** Object:  Table [stack].[Customers]    Script Date: 15.12.2022 12:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stack].[Customers](
	[row_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY NONCLUSTERED 
(
	[row_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [stack].[Orders]    Script Date: 15.12.2022 12:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stack].[Orders](
	[row_id] [int] IDENTITY(1,1) NOT NULL,
	[parent_id] [int] NULL,
	[group_name] [nvarchar](max) NULL,
	[customer_id] [int] NULL,
	[registered_at] [date] NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY NONCLUSTERED 
(
	[row_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [stack].[OrderItems]    Script Date: 15.12.2022 12:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stack].[OrderItems](
	[row_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[price] [int] NOT NULL,
 CONSTRAINT [PK_OrderItems] PRIMARY KEY NONCLUSTERED 
(
	[row_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[select_orders_by_item_name]    Script Date: 15.12.2022 12:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[select_orders_by_item_name]
(@namePosition nvarchar(max))
--RETURNS @resultTable TABLE(idOrder INT, nameCustomer NVARCHAR(MAX), countPosition INT)
RETURNS TABLE AS
RETURN
(	
	SELECT	o.row_id as idOrder
			, c.name as nameCustomer 
			, oi.name
			, count(oi.row_id) as countPosition 
	FROM stack.Orders O
		INNER JOIN stack.OrderItems OI	ON O.row_id = OI.order_id
		INNER JOIN stack.Customers C	ON c.row_id = O.customer_id
	WHERE Upper(oi.name) LIKE UPPER (@namePosition) 
	GROUP BY o.row_id, c.name, oi.name
)
GO
/****** Object:  UserDefinedFunction [stack].[select_orders_by_item_name]    Script Date: 15.12.2022 12:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [stack].[select_orders_by_item_name]
(@namePosition nvarchar(max))
--RETURNS @resultTable TABLE(idOrder INT, nameCustomer NVARCHAR(MAX), countPosition INT)
RETURNS TABLE AS
RETURN
(	
	SELECT	o.row_id as idOrder
			, c.name as nameCustomer 
			, oi.name
			, count(oi.row_id) as countPosition 
	FROM stack.Orders O
		INNER JOIN stack.OrderItems OI	ON O.row_id = OI.order_id
		INNER JOIN stack.Customers C	ON c.row_id = O.customer_id
	WHERE Upper(oi.name) LIKE UPPER (@namePosition) 
	GROUP BY o.row_id, c.name, oi.name
)
GO
ALTER TABLE [stack].[OrderItems]  WITH CHECK ADD  CONSTRAINT [FK_OrderItems_Orders] FOREIGN KEY([order_id])
REFERENCES [stack].[Orders] ([row_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [stack].[OrderItems] CHECK CONSTRAINT [FK_OrderItems_Orders]
GO
ALTER TABLE [stack].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Customers] FOREIGN KEY([customer_id])
REFERENCES [stack].[Customers] ([row_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [stack].[Orders] CHECK CONSTRAINT [FK_Customers]
GO
ALTER TABLE [stack].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Folder] FOREIGN KEY([parent_id])
REFERENCES [stack].[Orders] ([row_id])
GO
ALTER TABLE [stack].[Orders] CHECK CONSTRAINT [FK_Orders_Folder]
GO
USE [master]
GO
ALTER DATABASE [TestWork] SET  READ_WRITE 
GO
