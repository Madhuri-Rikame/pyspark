select * from Sales.Currency
select * from sales.CountryRegionCurrency
select * from Sales.Customer
select * from Sales.ShoppingCartItem
select * from Sales.CurrencyRate
use AdventureWorks2022
--- Que.1)  find the average currency rate conversion from USD to Algerian Dinar and Australian Doller  


select  avg(AverageRate), FromCurrencyCode, ToCurrencyCode
from Sales.CurrencyRate 
where FromCurrencyCode='usd' and 
ToCurrencyCode IN ('AUD', 'DZD');

----Que.2)Find the products having offer on it and display product name , safety Stock Level, Listprice, 
--- and product model id, type of discount,  percentage of discount,  offer start date and offer end date
select * from Sales.SpecialOffer o
select * from Production.Product p

select   p.name as prod_name , p.SafetyStockLevel, p.ListPrice,p.ProductID, o.DiscountPct, o.[Type] ,o.StartDate,o.EndDate
from sales.SpecialOffer o , 
Production.Product p
where DiscountPct > 0


select
    p.Name  Prod_Name, 
    p.StandardCost SafetyStockLevel, 
    p.ListPrice, 
    p.ProductID, 
    o.DiscountPct, 
    o.Type, 
    o.StartDate, 
    o.EndDate
from Sales.SpecialOffer o
join Sales.SpecialOfferProduct sop on o.SpecialOfferID = sop.SpecialOfferID
join  Production.Product p on sop.ProductID = p.ProductID
where o.DiscountPct > 0;


--- Que.3)  create  view to display Product name and Product review 

create view prod_review_view2  as
select p.name as prod_name , pr.comments
from Production.Product p
right join Production.ProductReview pr
on p.ProductID = pr.ProductID 

select * from prod_review_view2  ---- to see the view of prod_review_view1

--- Que.4)  find out the vendor for product   paint, Adjustable Race and blade	  

select v.name as v_name ,p.name as p_name
from Production.Product p
join Purchasing.ProductVendor pv 
on pv.productid = p.ProductID
join Purchasing.Vendor v
on v.BusinessEntityID = pv.BusinessEntityID
where
(p.name  like '%paint%' or
p.name like '%blade%' or
p.name like '%adjustable race%')
group by v.name ,p.name
order by v.name


SELECT v.Name AS v_name, 
       (SELECT p.Name 
        FROM Production.Product p 
        WHERE p.ProductID = pv.ProductID) AS p_name
FROM Purchasing.ProductVendor pv
JOIN Purchasing.Vendor v 
ON v.BusinessEntityID = pv.BusinessEntityID
WHERE pv.ProductID IN (
    SELECT ProductID 
    FROM Production.Product 
    WHERE Name LIKE '%paint%' 
       OR Name LIKE '%blade%' 
       OR Name LIKE '%adjustable race%'
)
ORDER BY v.Name;



---- Que.5)  find product details shipped through ZY - EXPRESS 
select * from Production.Product p
select * from sales.SalesOrderDetail d
select * from Purchasing.ShipMethod s
select * from Sales.SalesOrderHeader h

select s.name as  s_name , p.productid, p.name as prodName ,p.ListPrice ,s.ShipMethodID
from Sales.SalesOrderHeader h
join  sales.SalesOrderDetail d
on d.SalesOrderID = h.SalesOrderID
join  Production.Product p
on d.ProductID = d.ProductID
join Purchasing.ShipMethod s
on s.ShipMethodID = h.ShipMethodID 
where s.name = 'zy - express' ;


---- Que.6)  find the tax amt for products where order date and ship date are on the same day 
select * from Purchasing.PurchaseOrderHeader

select sh.TaxAmt
from Sales.SalesOrderHeader sh
where sh.OrderDate = sh.ShipDate;
-----------------------------------------------------------------------
SELECT soh.SalesOrderID, 
       sod.ProductID, 
       soh.OrderDate, 
       soh.ShipDate, 
       soh.TaxAmt
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate = soh.ShipDate;



--- Que.7)  find the average days required to ship the product based on shipment type. 

select * from sales.SalesOrderHeader h   --- which table have to used 
select * from Purchasing.PurchaseOrderHeader   


select s.name ship_name ,
avg(datediff(day, h.orderdate, h.shipdate)) avgdayship
from Purchasing.PurchaseOrderHeader h 
join Purchasing.ShipMethod s 
on h.ShipMethodID = s.ShipMethodID
where h.ShipDate is not null
group by s.name 


select s.name ship_name ,
avg(datediff(day, h.orderdate, h.shipdate)) avgdayship
from sales.SalesOrderHeader h 
join Purchasing.ShipMethod s 
on h.ShipMethodID = s.ShipMethodID
where h.ShipDate is not null
group by s.name 

--- Que.8)  find the name of employees working in day shift 
select *  from HumanResources.Shift
select * from Person.Person p
select  * from HumanResources.Employee



select CONCAT_WS('  ', p.FirstName, p.LastName) e_name
from Person.Person p
join HumanResources.Employee e 
on p.BusinessEntityID =e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory h
on h.BusinessEntityID = p.BusinessEntityID
join HumanResources.Shift s 
on h.ShiftID = s.ShiftID 
where s.name = 'Day' 


----Que.9) based on product and product cost history find the name , service provider time and average Standardcost   
select * from production.Product p
select * from Production.ProductCostHistory


select p.name as prod_name ,p.DaysToManufacture time_provided, p.StandardCost 
from Production.ProductCostHistory h, production.Product p
where p.ProductID = h.ProductID and
p.StandardCost = h.StandardCost

 
 select p.Name  ProductName, 
p.DaysToManufacture ServiceProviderTime, 
AVG(pch.StandardCost)AvgStandardCost
from Production.Product p
JOIN Production.ProductCostHistory pch on p.ProductID = pch.ProductID
group by  p.Name, p.DaysToManufacture;


--- Que.10)  find products with average cost more than 500 
select * from production.Product p
select * from Production.ProductCostHistory

select p.name as p_name, avg(p.StandardCost)
from production.Product p
join  Production.ProductCostHistory h
on p.ProductID = h.ProductID
group by p.name
having avg(p.standardcost) > 500;


---Que.11) find the employee who worked in multiple territory 
select * from Sales.SalesTerritory
select * from Sales.SalesTerritoryHistory
select * from Sales.SalesPerson
select * from Person.Person
 

select sp.BusinessEntityID, concat_ws('   ',p.FirstName, p.LastName)P_name,COUNT(h.TerritoryID) AS TerritoryCount
FROM Sales.SalesPerson sp
join sales.SalesTerritoryHistory h 
on sp.BusinessEntityID = h.BusinessEntityID
join Person.Person p 
on p.BusinessEntityID = sp.BusinessEntityID
group by sp.BusinessEntityID, p.FirstName,p.LastName
having count(h.TerritoryID) > 1;


--- Que.12)  find out the Product model name,  product description for culture as Arabic 
select * from Production.Product p
select * from Production.ProductDescription d
select * from Production.ProductModel m
select * from [Production].[ProductModelProductDescriptionCulture] b


select m.name as m_name ,d.Description as describe 
from Production.ProductModel m
join [Production].[ProductModelProductDescriptionCulture] b
on m.ProductModelID = b.ProductModelID
join Production.ProductDescription d
on d.ProductDescriptionID = b.ProductDescriptionID
where b.CultureID = 'ar';

--------------------------------------------------------------- SUB-QUERY----------------------------------------------------------

--- Que.13)  display EMP name, territory name, saleslastyear salesquota and bonus 
select concat_ws(' ', p.FirstName,
p.LastName) emp_name ,
st.name as territoryname,
sp.saleslastyear,
sp.bonus,
sp.salesquota
from
	Sales.SalesPerson sp,
	Sales.SalesTerritory st,
	Person.Person p
where 
 st.TerritoryID =sp.TerritoryID
	and
	p.BusinessEntityID =sp.BusinessEntityID;

---Que.14)  display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom 

SELECT 
    (SELECT CONCAT_WS(' ', p.FirstName, p.LastName) 
     FROM Person.Person p
     WHERE p.BusinessEntityID = sp.BusinessEntityID)  e_name,
     (SELECT st.Name AS TerritoryName 
     FROM Sales.SalesTerritory st
     WHERE st.TerritoryID = sp.TerritoryID) ter_name,
	 (select st.[group] from sales.SalesTerritory st
	 where st.territoryId = sp.TerritoryID),
       sp.SalesLastYear,
	   sp.bonus,
	   sp.salesquota
FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN 
    (SELECT st.TerritoryID 
     FROM Sales.SalesTerritory st 
     WHERE st.Name IN ('Germany', 'United Kingdom'));

--- Que.15)  Find all employees who worked in all North America territory 

SELECT 
    (SELECT CONCAT_WS(' ', p.FirstName, p.LastName) 
     FROM Person.Person p
     WHERE p.BusinessEntityID = sp.BusinessEntityID)  e_name 
FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN 
    (SELECT st.TerritoryID 
     FROM Sales.SalesTerritory st 
     WHERE st.[Group] in ('North America'));


---Que.16)  find all products in the cart 

SELECT 
    p.ProductID,
    p.Name AS ProdName,
    pod.OrderQty,
    sc.ShoppingCartID,
    sop.ProductID
FROM Production.Product p, 
     Purchasing.PurchaseOrderDetail pod, 
     Sales.ShoppingCartItem sc, 
     Sales.SpecialOfferProduct sop
WHERE p.ProductID = pod.ProductID
AND p.ProductID = sc.ProductID
AND p.ProductID = sop.ProductID; 


--- Que.17)  find all the products with special offer 

SELECT 
    p.ProductID,
    p.Name AS ProdName,
    sop.SpecialOfferID
FROM Production.Product p, 
     Sales.SpecialOfferProduct sop
WHERE p.ProductID = sop.ProductID;

--- Que.18) find all employees name ,job title, card details whose credit card expired in the month 11 and year as 2008  

select
    p.FirstName,
	e.JobTitle,
    e.BusinessEntityID,
    c.CreditCardID,
    c.CardType,
    c.CardNumber,
    c.ExpMonth,
    c.ExpYear
FROM HumanResources.Employee e
JOIN Person.Person p 
    ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.PersonCreditCard pd 
    ON e.BusinessEntityID = pd.BusinessEntityID
JOIN Sales.CreditCard c 
    ON pd.CreditCardID = c.CreditCardID
WHERE c.ExpMonth = 11 
AND c.ExpYear = 2008;

--- Que.19)  Find the employee whose payment might be revised  (Hint : Employee payment history) 
select * from HumanResources.EmployeePayHistory
select * from HumanResources.Employee e
select * from Person.Person p

select e.BusinessEntityID,concat_ws(' ', p.FirstName,p.LastName) e_name, COUNT(*)  RevisionCount
from HumanResources.Employee e
JOIN Person.Person p on e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeePayHistory h on e.BusinessEntityID = h.BusinessEntityID
group by e.BusinessEntityID, p.FirstName, p.LastName
having COUNT(*) > 1;


select h.BusinessEntityID, count(*) 
from HumanResources.EmployeePayHistory h group by BusinessEntityID having count(*) >1;

select * from HumanResources.Employee
where businessentityid not in 
(select BusinessEntityID from HumanResources.EmployeePayHistory)

----- Que.20) Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type) 
select * from Person.Address
select * from Person.AddressType
select * from Person.BusinessEntityAddress
select * from person.Person p 

select *
from
Person.AddressType a,
Person.BusinessEntityAddress b,
person.Person p , 
Person.Address s
where p.BusinessEntityID = b.BusinessEntityID
and a.AddressTypeID = b.AddressTypeID 
and s.AddressID =b.AddressID

------ Que.21)  Find the name of employees working in group of North America territory 

select * from  Sales.SalesTerritory st 
select *  FROM Sales.SalesTerritoryHistory h
select * from Person.Person p


select st.[group], h.territoryId,h.businessentityid, CONCAT_WS(' ' , p.FirstName,p.LastName)
from Sales.SalesTerritory st ,Sales.SalesTerritoryHistory h,Person.Person p
where h.BusinessEntityID = p.BusinessEntityID and h.TerritoryID=st.TerritoryID and
st.[Group] = 'North America'





---- Que.22)  Find the employee whose payment is revised for more than once 

select payfrequency, 
(select p.firstname p_name from Person.Person p 
where p.BusinessEntityID = h.BusinessEntityID) 
from HumanResources.EmployeePayHistory h 
where PayFrequency >1;

select  p.* ,                                                              ----------- Or
       h.PayFrequency
FROM HumanResources.EmployeePayHistory h 
right join Person.person p
ON p.BusinessEntityID = h.BusinessEntityID
where PayFrequency >1;
                                          -------------------- Or
select businessentityid, count(*) from HumanResources.EmployeePayHistory h 
group by BusinessEntityID
having COUNT(*) >1;

---Que.23)  display the personal details of  employee whose payment is revised for more than once. 


select  p.BusinessEntityID,CONCAT_WS(' ',p.FirstName,p.LastName) person_name,                                                            ----------- Or
       h.PayFrequency
FROM HumanResources.EmployeePayHistory h 
right join Person.person p
ON p.BusinessEntityID = h.BusinessEntityID
where PayFrequency >1;
--------------------------------------------------------

--- Que.25)  check if any employee from jobcandidate table is having any payment revisions  
select * from HumanResources.JobCandidate
select * FROM HumanResources.EmployeePayHistory h 
select * from HumanResources.Employee

select BusinessEntityID from HumanResources.JobCandidate  where BusinessEntityID is  not null;


select p.firstname , p.BusinessEntityID
from Person.Person p ,
	  HumanResources.EmployeePayHistory h,
	  HumanResources.JobCandidate  j 
where p.BusinessEntityID= h.BusinessEntityID
and j.BusinessEntityID= p.BusinessEntityID

--- Que.26) check the department having more salary revision 

select * from HumanResources.Department d
select * from HumanResources.EmployeeDepartmentHistory h
select * from HumanResources.Employee e
select * from HumanResources.EmployeePayHistory ep


select d.[Name],count(*) 
from HumanResources.Department d
join HumanResources.EmployeeDepartmentHistory h
on d.DepartmentID = h.DepartmentID
join HumanResources.Employee e
on e.BusinessEntityID = h.BusinessEntityID
join HumanResources.EmployeePayHistory ep
on ep.BusinessEntityID =e.BusinessEntityID
group by d.[Name]
order by count(*) desc;


--- Que27) check the employee whose payment is not yet revised
select * from HumanResources.EmployeePayHistory p ---
select * from HumanResources.EmployeeDepartmentHistory h


select h.businessentityid, p.payfrequency , count(*) as revisioncount
from HumanResources.employeedepartmenthistory h 
join 
HumanResources.EmployeePayHistory p 
on h.BusinessEntityID=p.BusinessEntityID
group by h.BusinessEntityID,p.PayFrequency
having  count(*) =0;






--- Que.28)  find the job title having more revised payments 

select  top 1 job_title , count(*) from 
( select e.JobTitle job_title , count(*) cnt , e.BusinessEntityID id 
from humanresources.employee e , HumanResources.EmployeePayHistory ep
where e.BusinessEntityID = ep.BusinessEntityID
group by e.JobTitle, e.BusinessEntityID 
having count(*) >1 ) as t 
group by t.job_title
order by count(*) desc;

---Que.29)   find the employee whose payment is revised in shortest duration (inline view) 


SELECT BusinessEntityID, RateChangeDate
FROM HumanResources.EmployeePayHistory
WHERE BusinessEntityID = 4
ORDER BY RateChangeDate;



select min(ratechangedate) min_dur , min( duration_revise  ) duration_revise
from (
select ratechangedate,
datediff( day, ratechangedate,
		lead(ratechangedate)
		over ( partition by businessentityid order by ratechangedate))
		duration_revise
from HumanResources.EmployeePayHistory
where BusinessEntityID=4) as t


--- Que 30)  find the colour wise count of the product (tbl: product) 

select * from Production.Product p

select p.color, p.[name],count(*) as pr_count 
from Production.Product p 
where  p.color is not null
group by p.color ,p.[Name] 
order by pr_count ;
-------------------------------------------------------------------------- Or

select p.color,count(Color) as pr_count 
from Production.Product p 
where  p.color is not null
group by p.color 
order by pr_count ;
  
-----------------------------------------------------------------------------------------------------------
--- Que.31)  find out the product who are not in position to sell (hint: check the sell start and end date) 

select * from Production.Product p

select p.name as p_name ,SellStartDate, SellEndDate
from Production.Product p 
where p.sellenddate is not  null


--- Que.32) find the class wise, style wise average standard cost 
select * from Production.Product p 

select p.standardcost , count(p.style) as c_style , count(p.class) as c_class 
from Production.Product p 
group by p.StandardCost 
order by c_class,c_style


--- Que.33)  check colour wise standard cost 
select standardcost , count(color) clr_count
from Production.Product 
group by StandardCost
order by clr_count

--- Que.34)  find the product line wise standard cost 

select ProductLine,StandardCost
from Production.Product
where ProductLine is not null
order by ProductLine


select StandardCost , count(ProductLine) productline   --- count of productline
from Production.Product
where ProductLine is not null
group by  StandardCost
order by ProductLine


-----------------------------------------------------------------------------

--- Que.35) Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 
select * from Sales.SalesTaxRate
select * from  Person.StateProvince 

select s.[name], t.taxrate
from Person.StateProvince s ,Sales.SalesTaxRate t
where t.StateProvinceID = s.StateProvinceID


-------------- 0r---------
SELECT s.Name AS StateName, t.TaxRate
FROM Sales.SalesTaxRate t
JOIN Person.StateProvince s ON t.StateProvinceID = s.StateProvinceID;


--- Que.36) Find the department wise count of employees.
select * from HumanResources.Department d
select * from HumanResources.EmployeeDepartmentHistory  e
select * from Person.Person p
			--------------------------------------------------------------------
select d.[Name], count(e.BusinessEntityID) id
from HumanResources.EmployeeDepartmentHistory h,
		HumanResources.Department d,
		HumanResources.Employee e
where h.DepartmentID = d.DepartmentID and 
		e.BusinessEntityID = h.BusinessEntityID
group by d.[Name]
order by id desc
		------------------------------------------------------------

select d.[Name], count(h.BusinessEntityID) id
from HumanResources.EmployeeDepartmentHistory h, HumanResources.Department d
where  h.DepartmentID = d.DepartmentID 
group by d.[Name]
order by id desc
				--------------------------------------------------

select d.[name],
( select count(*) from HumanResources.EmployeeDepartmentHistory h 
where h.DepartmentID = d.DepartmentID 
and h.EndDate is  null) as id
from HumanResources.Department d 
order by id desc


---- Que.37) Find the department which is having more employees 
select * from humanresources.Department
select * from HumanResources.EmployeeDepartmentHistory


select top 1 d.[Name], count(h.BusinessEntityID) ID
from humanresources.Department d, HumanResources.EmployeeDepartmentHistory h
where h.DepartmentID=d.DepartmentID
group by d.[Name]
order by id desc

--- Que.38) Find the job title having more employees 


select jobtitle,count(businessentityid) id
from  HumanResources.Employee 
group by JobTitle
order by  id desc;

---- Que.39) Check if there is mass hiring of employees on single day 
select * from HumanResources.Employee 

select hiredate , count(*) c
from HumanResources.Employee
group by HireDate
order by c desc

--- Que.40) Which product is purchased more? (purchase order details) 
select * from Purchasing.PurchaseOrderDetail
select * from Production.Product


select top 1 p.[name],  sum(d.orderQty) max_purchase  
from Purchasing.PurchaseOrderDetail d,
		Production.Product p
where d.ProductID = p.ProductID
group by p.[name]
order by max_purchase desc


--- Que.41) Find the territory wise customers count   (hint: customer) 
select * from Sales.Customer
select * from Sales.SalesTerritory


select t.territoryid  , count(*) cust_count 
from sales.Customer t
group by t.territoryid
order by cust_count


---- Que.42) Which territory is having more customers (hint: customer) 
select * from Sales.Customer
select * from Sales.SalesTerritory

select top 1 t.[name]  t_name , count(c.CustomerID) id
from sales.Customer c, Sales.SalesTerritory t
where t.TerritoryID = c.TerritoryID
group by t.[name]
order by id desc


--- Que.43)Which territory is having more stores (hint: customer) 
select * from Sales.Customer 


select top 1 t.[name]  t_name , count(*) id
from sales.Customer c, Sales.SalesTerritory t
where t.TerritoryID = c.TerritoryID
group by t.[name]
order by id desc

select top 1 t.[name],
(select count(*) from sales.Customer c 
where t.TerritoryID = c.TerritoryID) id
from Sales.SalesTerritory t
order by id desc



--- Que.44)  Is there any person having more than one credit card (hint: PersonCreditCard)
select * from  sales.PersonCreditCard


select count(CreditCardID) id from sales.PersonCreditCard
where  BusinessEntityID  <1


---Que.45)Find the product wise sale price 
select * from sales.SalesOrderDetail
select * from Production.Product

select unitprice ,
(select p.[Name] from Production.Product p
where d.ProductID = p.productid )
from Sales.SalesOrderDetail d

---Que.46) Find the total values for line total product having maximum order 
select * from sales.SalesOrderDetail
select * from Production.Product

select top 1 linetotal , max(orderQty) qty
from sales.SalesOrderDetail 
group by LineTotal
order by qty desc;

 
 --- Que.47) 
 ----                               **** Date Queries *******

 --- Que.47) Calculate the age of employees 
 select * from HumanResources.Employee

 select BusinessEntityID,birthdate, dATEDIFF(year,e.BirthDate,getdate()) age
 from HumanResources.Employee e


 ---Que.48)Calculate the year of experience of the employee based on hire date 

 select BusinessEntityID, HireDate , DATEDIFF(year,HireDate,GETDATE()) Yr_Experience
 from HumanResources.Employee


---Que.49) Find the age of employee at the time of joining 
 
select BusinessEntityID, BirthDate,HireDate,datediff(year,e.BirthDate,e.HireDate) time_of_joining
from HumanResources.Employee e

---Que.50) Find the average age of male and female 
select * from HumanResources.Employee

select Gender , avg(DATEDIFF(year, birthDate, GETDATE()))	age																	
from HumanResources.Employee 
group  by Gender

---Que.51) Which product is the oldest product as on the date (refer  the product sell start date) 

select top 10 p.name ,DATEDIFF(DAY, SellStartDate,GETDATE()) oldProduct
from Production.Product p

---Que.52) 