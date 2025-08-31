-----------------------------------------------------------
-- Create Product Dimension View
-- This view flattens Product, SubCategory, and Category
-----------------------------------------------------------
CREATE VIEW DimProduct AS
SELECT
    p.ProductID,                       -- Unique identifier for the product
    p.Name AS ProductName,             -- Product name
    p.ProductNumber,                   -- Internal product number
    p.ListPrice,                       -- Standard product price
    pc.Name AS CategoryName,           -- Category (e.g., Bikes, Components)
    psc.Name AS SubCategoryName        -- Sub-category (e.g., Mountain Bikes)
FROM Production.Product AS p
LEFT JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS pc
    ON psc.ProductCategoryID = pc.ProductCategoryID;


-----------------------------------------------------------
-- Switch to AdventureWorks2019 Database
-----------------------------------------------------------
USE AdventureWorks2019;
GO

-- Required session settings for view creation
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


-----------------------------------------------------------
-- Create FactSales View
-- This is the fact table for sales, combining order headers
-- and details. It includes calculated allocations for tax,
-- freight, and total at line level.
-----------------------------------------------------------
CREATE VIEW dbo.FactSales AS
SELECT
    SOD.SalesOrderDetailID,                 -- Unique line item ID
    SOD.SalesOrderID,                       -- Order ID
    SOH.OrderDate,                          -- Order creation date
    SOH.DueDate,                            -- Order due date
    SOH.ShipDate,                           -- Date shipped
    SOD.ProductID,                          -- Product being sold
    SOH.CustomerID,                         -- Customer placing the order
    SOH.SalesPersonID,                      -- Assigned salesperson
    SOH.TerritoryID,                        -- Sales territory
    SOH.ShipMethodID,                       -- Shipping method
    SOD.OrderQty,                           -- Quantity ordered
    SOD.UnitPrice,                          -- Price per unit
    SOD.LineTotal,                          -- Extended line total (qty * price)
    SOH.Status AS StatusID,                 -- Order status (integer code)
    SOH.OnlineOrderFlag,                    -- Online (1) or offline (0) order
    SOH.SubTotal,                           -- Order subtotal (all lines before tax/freight)
    SOH.TotalDue AS OrderTotalDue,          -- Total amount due for the order

    -- Allocate tax, freight, and total proportionally to each line item
    (SOD.LineTotal / SOH.SubTotal) * SOH.TaxAmt    AS LineTaxAmt,
    (SOD.LineTotal / SOH.SubTotal) * SOH.Freight   AS LineFreight,
    (SOD.LineTotal / SOH.SubTotal) * SOH.TotalDue  AS LineTotalDue
FROM Sales.SalesOrderDetail AS SOD WITH (NOLOCK)
LEFT JOIN Sales.SalesOrderHeader AS SOH WITH (NOLOCK)
    ON SOD.SalesOrderID = SOH.SalesOrderID;
GO


-----------------------------------------------------------
-- Create Sales Territory Dimension View
-- Contains info about sales regions and performance metrics
-----------------------------------------------------------
CREATE VIEW DimSalesTerritory AS
SELECT
    TerritoryID,                  -- Unique territory identifier
    Name AS TerritoryName,        -- Territory name (e.g., Northwest)
    CountryRegionCode,            -- Country code
    Group AS TerritoryGroup,      -- Territory grouping (e.g., North America)
    SalesYTD,                     -- Sales year-to-date
    SalesLastYear,                -- Sales for prior year
    CostYTD,                      -- Cost year-to-date
    CostLastYear                  -- Cost for prior year
FROM Sales.SalesTerritory;


-----------------------------------------------------------
-- Create Ship Method Dimension View
-- Lists shipping methods and costs
-----------------------------------------------------------
CREATE VIEW DimShipMethod AS
SELECT
    ShipMethodID,                 -- Unique shipping method ID
    Name AS ShipMethodName,       -- Method name (e.g., UPS Ground)
    ShipBase,                     -- Base shipping cost
    ShipRate                      -- Rate per unit or weight
FROM Purchasing.ShipMethod;
