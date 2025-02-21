/*A. Find employee having highest rate or highest pay frequency*/

use adventureworks2022;

select*from [HumanResources].[Employee]
select*from person.person
select *from [HumanResources].[EmployeePayHistory]

select max(PayFrequency),
(select concat_ws(' ',firstname,LastName)
from person.person pp
where pp.businessEntityID=ep.businessentityId)Emp_name
from [HumanResources].[EmployeePayHistory] ep
group by BusinessEntityID



--B. Analyze the inventory based on the shelf wise count of the product and their quantity.

SELECT 
    pp.Name AS ProductName, 
    pi.Shelf,
    COUNT(*) OVER (PARTITION BY pp.Name) AS Count_of_shelf,
    SUM(pi.Quantity) OVER (PARTITION BY pp.Name) AS Count_per_quantity
FROM [Production].[ProductInventory] pi
JOIN Production.Product pp ON pi.ProductID = pp.ProductID;

--C. Find the personal details with address and address type

SELECT pp.FirstName, pp.LastName, pa.AddressLine1, pa.AddressLine2, bea.AddressTypeID
FROM person.Person pp
JOIN [Person].[BusinessEntityAddress] bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN [Person].[Address] pa ON bea.AddressID = pa.AddressID;


--D. Find the job title having more revised payments

SELECT e.JobTitle, COUNT(ep.BusinessEntityID) AS PaymentRevisions
FROM [HumanResources].[Employee] e
JOIN [HumanResources].[EmployeePayHistory] ep ON e.BusinessEntityID = ep.BusinessEntityID
GROUP BY e.JobTitle
ORDER BY COUNT(ep.BusinessEntityID) DESC;


--E. Display special offer description, category and avg(discount pct) per the year
select*from [Sales].[SpecialOffer]

select Description,
Category,
avg(discountPct) over (partition by year(StartDate)) Avg_dct_pct_per_year
from [Sales].[SpecialOffer]

--F. Display special offer description, category and avg(discount pct) per the month

select Description,
Category,
avg(discountPct) over (partition by month(StartDate)) Avg_dct_pct_per_month
from [Sales].[SpecialOffer]


--G. Using rank and dense rand find territory wise top sales person
SELECT pp.FirstName, pp.LastName, st.Name AS TerritoryName,
    RANK() OVER (PARTITION BY st.Name ORDER BY sp.SalesYTD DESC) AS Rank_Name,
    DENSE_RANK() OVER (PARTITION BY st.Name ORDER BY sp.SalesYTD DESC) AS DRank_Name
FROM [Sales].[SalesPerson] sp
JOIN [Sales].[SalesTerritory] st ON sp.TerritoryID = st.TerritoryID
JOIN person.Person pp ON sp.BusinessEntityID = pp.BusinessEntityID;

/*H.  Calculate total years of experience of the employee and
find out employees those who server for more than 20 years*/

select*from [HumanResources].[EmployeeDepartmentHistory]

select datediff(year,StartDate,Enddate) Total_year_ofExp
from [HumanResources].[EmployeeDepartmentHistory]

SELECT BusinessEntityID, DATEDIFF(YEAR, StartDate, EndDate) AS TotalYearsOfExperience
FROM [HumanResources].[EmployeeDepartmentHistory]
WHERE DATEDIFF(YEAR, StartDate, EndDate) > 20;

/*I.  Find the employee who is having more vacations than 
the average vacation taken by all employees*/

select*from HumanResources.Employee

select BusinessEntityID, VacationHours
from [HumanResources].[Employee]
where VacationHours > 
(select avg(VacationHours) from [HumanResources].[Employee]);


/*L. Is there any person having more than one credit card (hint: PersonCreditCard)*/
--Required Tables
select*from sales.PersonCreditCard
select*From Person.Person
--Query
select distinct(BusinessEntityID)from 
sales.PersonCreditCard

/*#Conclusions:So, here we can see that all the businessEntityID are unique
beacuse rows before applying distinct and after are sames so there is
no person who is having more than one credit card */



/*M. Find how many subcategories are available per  product . (product sub category */

select*from Production.Product
select*from Production.ProductCategory

SELECT p.ProductID, p.Name AS ProductName, 
    COUNT(psc.ProductSubCategoryID) AS SubCategoryCount
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubCategoryID
GROUP BY p.ProductID, p.Name;


/*N.  Find total standard cost for the active Product where 
end date is not updated. (Product cost history)*/
select*from [Production].[ProductCostHistory]

select sum(standardcost) over (partition by ProductId)
from [Production].[ProductCostHistory]
where EndDate is null


/*O.  Which territory is having more customers (hint: customer)
 (Non-anonymous question)*/
select top 1 st.Name AS Territory, COUNT(c.CustomerID) AS CustomerCount
from Sales.Customer c
JOIN Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID
group by st.Name
order by COUNT(c.CustomerID) DESC;

--Southwest territory is having more customers
