--This file for Microsoft SQL Server.

--(+)Create a physical database with a separate database and schema and give it an appropriate domain-related name.
--(+)Create tables based on the 3nf model developed during the DB Basics module.
--(+)Use appropriate data types for each column and apply NOT NULL constraints, DEFAULT values, and GENERATED ALWAYS AS columns as required.
--(+)Create relationships between tables using primary and foreign keys.
--(+)Apply five check constraints across the tables to restrict certain values, including
----(+)date to be inserted, which must be greater than January 1, 2000
----(+)inserted measured value that cannot be negative
----(+)inserted value that can only be a specific value (as an example of gender)
----(+)unique
----(+)not null
--(+)Populate the tables with the sample data generated, ensuring each table has at least two rows (for a total of 20+ rows in all the tables).
--(+)Add a 'record_ts' field to each table using ALTER TABLE statements, set the default value to current_date, and check to make sure the value has been set for the existing rows.
--(+)SQL command is rerunnable and reusable and executes without errors.
--(+)All objects, data types, and constraints are created according to the logical model from the previous task in the DB Basics module. All data types are selected correctly, and all of the necessary constraints are created. The new column has the appropriate data type and value.

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AuctionHouse')
BEGIN
    CREATE DATABASE AuctionHouse;
END
GO

USE AuctionHouse;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'auction')
BEGIN
    EXEC('CREATE SCHEMA auction');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Persons') AND type in (N'U'))
CREATE TABLE auction.Persons (
    PersonID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
	Gender NVARCHAR(6) NULL CHECK (Gender IN ('Male', 'Female'))
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Sellers') AND type in (N'U'))
CREATE TABLE auction.Sellers (
    SellerID INT PRIMARY KEY,
    PersonID INT NOT NULL UNIQUE,
    FOREIGN KEY (PersonID) REFERENCES auction.Persons(PersonID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Buyers') AND type in (N'U'))
CREATE TABLE auction.Buyers (
    BuyerID INT PRIMARY KEY,
    PersonID INT NOT NULL UNIQUE,
    FOREIGN KEY (PersonID) REFERENCES auction.Persons(PersonID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Items') AND type in (N'U'))
CREATE TABLE auction.Items (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    ItemName NVARCHAR(255) NOT NULL,
    ItemDescription NVARCHAR(255) NULL DEFAULT 'No description available'
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Countries') AND type in (N'U'))
CREATE TABLE auction.Countries (
    CountryID INT PRIMARY KEY IDENTITY(1,1),
    CountryName NVARCHAR(255) NOT NULL UNIQUE
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Cities') AND type in (N'U'))
CREATE TABLE auction.Cities (
    CityID INT PRIMARY KEY IDENTITY(1,1),
    CityName NVARCHAR(255) NOT NULL,
    CountryID INT NOT NULL,
    FOREIGN KEY (CountryID) REFERENCES auction.Countries(CountryID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Auctions') AND type in (N'U'))
CREATE TABLE auction.Auctions (
    AuctionID INT PRIMARY KEY IDENTITY(1,1),
    AuctionDate DATETIME NOT NULL CHECK (AuctionDate > '2000-01-01'),
    AddressLine NVARCHAR(255) NOT NULL,
    CityID INT NOT NULL,
    SpecialNotes NVARCHAR(255) NULL DEFAULT 'No special notes',
    FOREIGN KEY (CityID) REFERENCES auction.Cities(CityID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.LotNumbers') AND type in (N'U'))
CREATE TABLE auction.LotNumbers (
    LotNumberID INT PRIMARY KEY IDENTITY(1,1),
    LotNumber INT NOT NULL,
    AuctionID INT NOT NULL,
    ItemID INT NOT NULL,
    FOREIGN KEY (AuctionID) REFERENCES auction.Auctions(AuctionID),
    FOREIGN KEY (ItemID) REFERENCES auction.Items(ItemID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.SellerItems') AND type in (N'U'))
CREATE TABLE auction.SellerItems (
    SellerItemID INT PRIMARY KEY IDENTITY(1,1),
    SellerID INT NOT NULL,
    ItemID INT NOT NULL,
    StartingPrice DECIMAL(10, 2) NOT NULL CHECK (StartingPrice >= 0),
    FOREIGN KEY (SellerID) REFERENCES auction.Sellers(SellerID),
    FOREIGN KEY (ItemID) REFERENCES auction.Items(ItemID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'auction.Sales') AND type in (N'U'))
CREATE TABLE auction.Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    LotNumberID INT NOT NULL,
    BuyerID INT NOT NULL,
    ActualPrice DECIMAL(10, 2) NOT NULL CHECK (ActualPrice >= 0),
	VatAmount AS (ActualPrice * 0.20) PERSISTED,
    FOREIGN KEY (LotNumberID) REFERENCES auction.LotNumbers(LotNumberID),
    FOREIGN KEY (BuyerID) REFERENCES auction.Buyers(BuyerID)
);
GO

IF NOT EXISTS (SELECT * FROM auction.Persons)
BEGIN
    INSERT INTO auction.Persons (FirstName, LastName, Gender) VALUES
    ('John', 'Doe', 'Male'),
    ('Jane', 'Doe', 'Female'),
    ('Alice', 'Smith', 'Female'),
    ('Bob', 'Johnson', 'Male'),
    ('Charlie', 'Brown', 'Male'),
    ('Emily', 'Clark', 'Female'),
    ('Frank', 'Lloyd', 'Male'),
    ('Grace', 'Hopper', 'Male');
END
GO

IF NOT EXISTS (SELECT * FROM auction.Sellers)
BEGIN
    INSERT INTO auction.Sellers (SellerID, PersonID) VALUES
    (1, 1),
    (2, 3),
    (3, 5),
    (4, 7);
END
GO

IF NOT EXISTS (SELECT * FROM auction.Buyers)
BEGIN
    INSERT INTO auction.Buyers (BuyerID, PersonID) VALUES
    (1, 2),
    (2, 4),
    (3, 6),
    (4, 8);
END
GO

IF NOT EXISTS (SELECT * FROM auction.Countries)
BEGIN
    INSERT INTO auction.Countries (CountryName) VALUES
    ('United States'),
    ('Canada'),
    ('United Kingdom'),
    ('Australia');
END
GO

IF NOT EXISTS (SELECT * FROM auction.Cities)
BEGIN
    INSERT INTO auction.Cities (CityName, CountryID) VALUES
    ('New York', 1),
    ('Toronto', 2),
    ('London', 3),
    ('Sydney', 4);
END
GO

IF NOT EXISTS (SELECT * FROM auction.Auctions)
BEGIN
    INSERT INTO auction.Auctions (AuctionDate, AddressLine, CityID, SpecialNotes) VALUES
    ('2024-01-15T19:00:00', '123 Auction Lane', 1, 'Evening Auction'),
    ('2024-02-20T19:00:00', '789 Auction Blvd', 2, 'Online Only'),
    ('2024-03-25T19:00:00', '456 Auction St', 3, 'VIP Event'),
    ('2024-04-30T19:00:00', '321 Auction Road', 4, 'Charity Auction');
END
GO

IF NOT EXISTS (SELECT * FROM auction.Items)
BEGIN
    INSERT INTO auction.Items (ItemName, ItemDescription) VALUES
    ('Antique Vase', 'A beautiful old vase.'),
    ('Painting', 'Landscape painting by a famous artist.'),
    ('Sculpture', 'Modern art sculpture.'),
    ('Vintage Car', 'Classic car in mint condition.');
END
GO

IF NOT EXISTS (SELECT * FROM auction.LotNumbers)
BEGIN
    INSERT INTO auction.LotNumbers (LotNumber, AuctionID, ItemID) VALUES
    (101, 1, 1),
    (102, 1, 2),
    (103, 2, 3),
    (104, 2, 4),
    (105, 3, 1),
    (106, 3, 2),
    (107, 4, 3),
    (108, 4, 4);
END
GO

IF NOT EXISTS (SELECT * FROM auction.SellerItems)
BEGIN
    INSERT INTO auction.SellerItems (SellerID, ItemID, StartingPrice) VALUES
    (1, 1, 500.00),
    (2, 2, 1500.00),
    (3, 3, 2000.00),
    (4, 4, 30000.00),
    (1, 3, 2500.00),
    (2, 4, 35000.00),
    (3, 1, 550.00),
    (4, 2, 1600.00);
END
GO

IF NOT EXISTS (SELECT * FROM auction.Sales)
BEGIN
    INSERT INTO auction.Sales (LotNumberID, BuyerID, ActualPrice) VALUES
    (1, 1, 550.00),
    (2, 2, 1600.00),
    (3, 3, 2100.00),
    (4, 4, 30500.00),
    (5, 1, 600.00),
    (6, 2, 1650.00),
    (7, 3, 2200.00),
    (8, 4, 31000.00);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Persons' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Persons
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Sellers' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Sellers
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Buyers' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Buyers
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Items' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Items
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Countries' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Countries
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Cities' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Cities
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Auctions' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Auctions
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'LotNumbers' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.LotNumbers
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'SellerItems' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.SellerItems
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'auction' AND TABLE_NAME = 'Sales' AND COLUMN_NAME = 'record_ts')
BEGIN
    ALTER TABLE auction.Sales
    ADD record_ts DATETIME NOT NULL DEFAULT GETDATE();
END
GO