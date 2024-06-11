Use AdventureWorksDW2019

select * from
[dbo].[FactInternetSales]

select * from
[dbo].[DimProduct]

-- Vendas Totais
SELECT
    SUM([SalesAmount]) AS [Total de vendas]
FROM
    FactInternetSales;


-- CONTANDO QUANTOS CLIENTES S�O DO G�NERO MASCULINO E QUANTOS S�O DO G�NERO FEMININO

	SELECT
    SUM(CASE WHEN c.[Gender] = 'M' THEN 1 ELSE 0 END) AS TotalMasculino,
    SUM(CASE WHEN c.[Gender] = 'F' THEN 1 ELSE 0 END) AS TotalFeminino
FROM
    DimCustomer c;

-- M�dia de vendas di�rias:

SELECT
    AVG(f.[SalesAmount]) AS [M�dia di�ria de vendas]
FROM
    FactInternetSales f
INNER JOIN
    DimDate d ON f.[OrderDateKey] = d.[DateKey];
	


select * from
DimCustomer


-- SELECIONANDO AS COLUNAS NECESS�RIAS DA TABELA DimProductSubcategory

SELECT
    ProductSubCategoryKey,
    EnglishProductSubcategoryName,
    ProductCategoryKey
FROM
    DimProductSubcategory;

	-- SELECIONANDO AS COLUNAS NECESS�RIAS DA TABELA DimProductCategory

select ProductCategoryKey,EnglishProductCategoryName AS [Product Category Name]
from
[dbo].[DimProductCategory]


-- SELECIONANDO AS COLUNAS NECESS�RIAS DA TABELA [dbo].[DimGeography]

SELECT GeographyKey,City,CountryRegionCode,EnglishCountryRegionName,SalesTerritoryKey
FROM
[dbo].[DimGeography]



-- SELECIONANDO AS COLUNAS NECESS�RIAS DA TABELAS DimSalesTerritory

SELECT  
    SalesTerritoryKey,
    SalesTerritoryAlternateKey,
    SalesTerritoryRegion,
    SalesTerritoryCountry,
    SalesTerritoryGroup
FROM
    DimSalesTerritory
WHERE
    SalesTerritoryKey BETWEEN 1 AND 10;




-- Adicionar uma coluna condicional a tabela de produtos, chamada 'Classifica��o de vendas' , que avalia a quantidade de vendas e adiciona

SELECT
    p.*,
    CASE
        WHEN [Vendas Totais] > 50000 THEN 'Muito popular'
        WHEN [Vendas Totais] > 30000 THEN 'Popular'
        ELSE 'Menos Vendido'
    END AS [Classifica��o de Vendas]
FROM
    (
    SELECT
        p.[ProductKey],
        p.[EnglishProductName],
        p.[ProductSubcategoryKey],
        p.[ProductLine],
        p.[Color],
        p.[Size],
        p.[StandardCost],
        p.[ListPrice],
        SUM(f.[SalesAmount]) AS [Vendas Totais]
    FROM
        FactInternetSales f
    INNER JOIN
        DimProduct p ON f.[ProductKey] = p.[ProductKey]
    GROUP BY
        p.[ProductKey], p.[EnglishProductName], p.[ProductSubcategoryKey], p.[ProductLine], p.[Color], p.[Size], p.[StandardCost], p.[ListPrice]
    ) AS p;



	-- TRAZENDO A TABELA CUSTOMER, AVALIANDO QUAIS CLIENTES S�O NOVOS,QUAIS CLIENTES S�O FI�IS, QUAIS CLIENTES FIZERAM COMPRAS NOS �LTIMOS 30 DIAS
	-- e calculando a idade de	Cada cliente

SELECT
    c.[CustomerKey],
    c.[FirstName],
    c.[LastName],
    c.[MaritalStatus],
    c.[Gender],
    c.[BirthDate],
    DATEDIFF(year, c.[BirthDate], d.[CurrentDate]) AS [Age],
    c.[DateFirstPurchase],
    c.[CommuteDistance],
    c.[HouseOwnerFlag],
	c.[YearlyIncome],
    COUNT(f.[SalesAmount]) AS [Vendas Totais],
    CASE
        WHEN COUNT(f.[SalesAmount]) >= 10 THEN 'Cliente Fiel'
        ELSE 'Novo Cliente'
    END AS CustomerType,
    CASE
        WHEN MAX(f.[OrderDate]) >= DATEADD(day, -30, d.[CurrentDate]) THEN 'Fez Compra nos �ltimos 30 Dias'
        ELSE 'N�o Fez Compra nos �ltimos 30 Dias'
    END AS [Status de compras Recentes]
FROM
    DimCustomer c
LEFT JOIN
    FactInternetSales f ON c.[CustomerKey] = f.[CustomerKey]
CROSS JOIN
    (SELECT MAX([FullDateAlternateKey]) AS [CurrentDate] FROM DimDate) d -- Supondo que FullDateAlternateKey seja a coluna de data
GROUP BY
    c.[CustomerKey], c.[FirstName], c.[LastName], c.[MaritalStatus], c.[Gender], c.[BirthDate], c.[DateFirstPurchase], c.[CommuteDistance], c.[HouseOwnerFlag],c.[YearlyIncome], d.[CurrentDate];


-- Adicionando uma coluna para mostrar se a venda foi feita durante um per�odo de promo��o ou n�o:
-- Adicionar uma coluna para mostrar a diferen�a entre a data do pedido e a data de envio da compra e adicionando uma coluna para mostrar a margem de lucro de cada venda:

SELECT
    f.[ProductKey],f.[CustomerKey],f.[PromotionKey],f.[SalesTerritoryKey],f.[SalesOrderNumber],f.[OrderQuantity],f.[UnitPrice],f.[ProductStandardCost],f.[SalesAmount],f.[Freight],f.[OrderDate],f.[ShipDate],
    CASE
        WHEN f.[PromotionKey] IS NOT NULL THEN 'Compra durante Promo��o Ativa'
        ELSE 'Compra sem Promo��o'
    END AS PromotionStatus,
    DATEDIFF(day, f.[OrderDate], f.[ShipDate]) AS [Dias at� o envio],
    (f.[SalesAmount] - f.[TotalProductCost]) AS [Margem de Lucro]
FROM
    FactInternetSales f;







SELECT
    f.[ProductKey],
    f.[CustomerKey],
    f.[PromotionKey],
    f.[SalesTerritoryKey],
    f.[SalesOrderNumber],
    f.[OrderQuantity],
    f.[UnitPrice],
    f.[ProductStandardCost],
    f.[SalesAmount],
    f.[Freight],
    d.[FullDateAlternateKey] As [DateKey],
    CASE
        WHEN f.[PromotionKey] IS NOT NULL THEN 'Compra durante Promo��o Ativa'
        ELSE 'Compra sem Promo��o'
    END AS PromotionStatus,
    DATEDIFF(day, f.[OrderDate], f.[ShipDate]) AS [Dias at� o envio],
    (f.[SalesAmount] - f.[TotalProductCost]) AS [Margem de Lucro]
FROM
    FactInternetSales f
JOIN
    DimDate d ON f.[OrderDateKey] = d.[DateKey];







-- CONSULTA PARA  VERIFICAR A QUANTIDADE DE VENDAS NO ANO DE 2014

	SELECT
    SUM(f.SalesAmount) AS TotalVendas2014
FROM
    FactInternetSales f
JOIN
    DimDate d ON f.OrderDateKey = d.DateKey
WHERE
    d.CalendarYear = 2014;



	
-- CONSULTA PARA  VERIFICAR A QUANTIDADE DE VENDAS NO ANO DE 2013

	SELECT 
	SUM(f.salesAmount) AS Totalvendas2013
from
	FactInternetSales f
join
	dimdate d on f.orderdatekey = d.datekey
where
	d.calendaryear = 2013;



-- TOTAL DE VENDAS POR PA�S 


SELECT
    t.[SalesTerritoryCountry],
    SUM(f.[SalesAmount]) AS TotalSales
FROM
    FactInternetSales f
INNER JOIN
    DimSalesterritory t ON f.[SalesTerritoryKey] = t.[SalesTerritoryAlternateKey]
GROUP BY
    t.[SalesTerritoryCountry]
ORDER BY
    SUM(f.[SalesAmount]) DESC;




	SELECT
    pc.[ProductCategoryName],
    SUM(f.[SalesAmount]) AS TotalSales
FROM
    FactInternetSales f
INNER JOIN
    DimProduct p ON f.[ProductKey] = p.[ProductKey]
INNER JOIN
    DimProductSubcategory sc ON p.[ProductSubcategoryKey] = sc.[ProductSubcategoryKey]
INNER JOIN
    DimProductCategory pc ON sc.[ProductCategoryKey] = pc.[ProductCategoryKey]
GROUP BY
    pc.[ProductCategoryName]
ORDER BY
    SUM(f.[SalesAmount]) DESC;
	





