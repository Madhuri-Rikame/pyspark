--1. find the average currency rate conversion from USD to Algerian Dinar  and Australian Doller

select * from HumanResources.JobCandidate 
select * from Sales.CurrencyRate

select cr.FromCurrencyCode, cr.ToCurrencyCode , avg(cr.AverageRate)
from Sales.CurrencyRate cr
where cr.FromCurrencyCode = 'usd'
and cr.ToCurrencyCode in ( 'aud', 'dzd')
group by cr.FromCurrencyCode , cr.ToCurrencyCode
order by cr.FromCurrencyCode , cr.ToCurrencyCode

-- 2. Find the products having offer on it and display product name , safety Stock Level,
---Listprice, and product model id, type of discount, percentage of discount, offer start date and offer end date

select * from Sales.SpecialOffer -- specialofferid , description discountpct , type, startdate, enddate
select * from sales.SpecialOfferProduct -- specialofferid , productid 
select * from Sales.SalesOrderDetail --- specialofferid, unitpricediscount, 
select * from Production.Product p   


select s.SpecialOfferID, s.DiscountPct, s.Type ,s.StartDate, s.EndDate ,
		so.ProductID , p.name p_name , p.SafetyStockLevel, p.ListPrice
from Sales.SpecialOffer s 
join sales.SpecialOfferProduct so
on s.SpecialOfferID = so.SpecialOfferID
join Production.Product p
on p.ProductID = so.ProductID
where s.DiscountPct > 0;

--3. create view to display Product name and Product review
create view prod_review as 
select p.name , v.Comments
from Production.Product p 
join Production.ProductReview v
on p.ProductID = v.ProductID

select * from prod_review


--- 4.  find out the vendor for product paint, Adjustable Race and blade

select * from Purchasing.ProductVendor



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

--5. find product details shipped through ZY - EXPRESS

select s.name as  s_name , p.productid, p.name as prodName ,p.ListPrice ,s.ShipMethodID
from Sales.SalesOrderHeader h
join  sales.SalesOrderDetail d
on d.SalesOrderID = h.SalesOrderID
join  Production.Product p
on d.ProductID = d.ProductID
join Purchasing.ShipMethod s
on s.ShipMethodID = h.ShipMethodID 
where s.name = 'zy - express' ;

--Que.6)  find the tax amt for products where order date and ship date are on the same day 
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


--8 find the name of employees working in day shift 


select CONCAT_WS('  ', p.FirstName, p.LastName) e_name
from Person.Person p
join HumanResources.Employee e 
on p.BusinessEntityID =e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory h
on h.BusinessEntityID = p.BusinessEntityID
join HumanResources.Shift s 
on h.ShiftID = s.ShiftID 
where s.name = 'Day' 

--
----Que.9) based on product and product cost history find the name , service provider time and average Standardcost   
select * from production.Product p
select * from Production.ProductCostHistory


select p.name as prod_name ,p.DaysToManufacture time_provided, p.StandardCost 
from Production.ProductCostHistory h, production.Product p
where p.ProductID = h.ProductID and
p.StandardCost = h.StandardCost

--- Que.10)  find products with average cost more than 500 

select p.name as p_name, avg(p.StandardCost)
from production.Product p
join  Production.ProductCostHistory h
on p.ProductID = h.ProductID
group by p.name
having avg(p.standardcost) > 500;


---Que.11) find the employee who worked in multiple territory 
select sp.BusinessEntityID, concat_ws('   ',p.FirstName, p.LastName)P_name,COUNT(h.TerritoryID) AS TerritoryCount
FROM Sales.SalesPerson sp
join sales.SalesTerritoryHistory h 
on sp.BusinessEntityID = h.BusinessEntityID
join Person.Person p 
on p.BusinessEntityID = sp.BusinessEntityID
group by sp.BusinessEntityID, p.FirstName,p.LastName
having count(h.TerritoryID) > 1;


--- Que.12)  find out the Product model name,  product description for culture as Arabic 

select m.name as m_name ,d.Description as describe 
from Production.ProductModel m
join [Production].[ProductModelProductDescriptionCulture] b
on m.ProductModelID = b.ProductModelID
join Production.ProductDescription d
on d.ProductDescriptionID = b.ProductDescriptionID
where b.CultureID = 'ar';
 
 --13.  find  first 20 emp who join very early in the company.
 select * from HumanResources.Employee

 select top 20 HireDate , BusinessEntityID
 from HumanResources.Employee e
order by HireDate asc;

--14. Find most trending product based on sales and purchase.
 
 select * from sales.SalesOrderDetail
 select * from Purchasing.PurchaseOrderDetail
 select * from Production.Product 

select top 1 p.name prod_name ,
	sum( d.orderqty  ) as total_score
from Production.Product p 
join sales.SalesOrderDetail s 
on s.ProductID = p.ProductID
join Purchasing.PurchaseOrderDetail d 
on d.ProductID = p.ProductID
group by p.Name
order by total_score desc ;

---                                                                    *** Sub-Query *** 
--- display EMP name, territory name, saleslastyear salesquota and bonus
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


--16 )  display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom 

SELECT 
    (SELECT CONCAT_WS(' ', p.FirstName, p.LastName) 
     FROM Person.Person p
     WHERE p.BusinessEntityID = sp.BusinessEntityID)  e_name,
     (SELECT st.Name AS TerritoryName 
     FROM Sales.SalesTerritory st
     WHERE st.TerritoryID = sp.TerritoryID) ter_name,
	 (select st.[group] from sales.SalesTerritory st
	 where st.territoryId = sp.TerritoryID),
       sp.SalesLastYear, sp.bonus, sp.salesquota
FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN 
    (SELECT st.TerritoryID 
     FROM Sales.SalesTerritory st 
     WHERE st.Name IN ('Germany', 'United Kingdom'));


-- 17.  Find all employees who worked in all North America territory 

SELECT 
    (SELECT CONCAT_WS(' ', p.FirstName, p.LastName) 
     FROM Person.Person p
     WHERE p.BusinessEntityID = sp.BusinessEntityID)  e_name 
FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN 
    (SELECT st.TerritoryID 
     FROM Sales.SalesTerritory st 
     WHERE st.[Group] in ('North America'));


---Que.18)  find all products in the cart 

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


--- Que.19)  find all the products with special offer 

SELECT 
    p.ProductID,
    p.Name AS ProdName,
    sop.SpecialOfferID
FROM Production.Product p, 
     Sales.SpecialOfferProduct sop
WHERE p.ProductID = sop.ProductID;

--- Que.20 find all employees name ,job title, card details whose credit card expired in the month 11 and year as 2008  

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

--- Que.21  Find the employee whose payment might be revised  (Hint : Employee payment history) 
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
 

 --22.  Find total standard cost for the active Product. (Product cost history)
 select * from Production.ProductCostHistory

 select sum(c.standardcost)
 from Production.ProductCostHistory c 
 join Production.Product p 
 on p.ProductID = c.ProductID 
 where p.DiscontinuedDate is  null;


 --23) Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type) 

select *  from
Person.AddressType a,
Person.BusinessEntityAddress b,
person.Person p , 
Person.Address s
where p.BusinessEntityID = b.BusinessEntityID
and a.AddressTypeID = b.AddressTypeID 
and s.AddressID =b.AddressID

------ Que.24 Find the name of employees working in group of North America territory 

select st.[group], h.territoryId,h.businessentityid, CONCAT_WS(' ' , p.FirstName,p.LastName)
from Sales.SalesTerritory st ,Sales.SalesTerritoryHistory h,Person.Person p
where h.BusinessEntityID = p.BusinessEntityID and h.TerritoryID=st.TerritoryID and
st.[Group] = 'North America'


-- 25.   Find the employee whose payment is revised for more than once 

select payfrequency, 
(select p.firstname p_name from Person.Person p 
where p.BusinessEntityID = h.BusinessEntityID) 
from HumanResources.EmployeePayHistory h 
where PayFrequency >1;


--26.   display the personal details of  employee whose payment is revised for more than once. 


select  p.BusinessEntityID,CONCAT_WS(' ',p.FirstName,p.LastName) person_name,                                                            ----------- Or
       h.PayFrequency
FROM HumanResources.EmployeePayHistory h 
right join Person.person p
ON p.BusinessEntityID = h.BusinessEntityID
where PayFrequency >1; 

---  27. Which shelf is having maximum quantity (product inventory)
select * from Production.ProductInventory 

select top 1 max(shelf) max_shelf ,Quantity
 from Production.ProductInventory 
 group by Quantity
order by Quantity desc;

--- 28. Which shelf is using maximum bin(product inventory)
select top 1 Shelf , max(bin) max_b 
 from Production.ProductInventory 
group by Shelf 
order by max_b desc;

--29. Which location is having minimum bin (product inventory

select top 1 locationid , min(bin) min_bin 
from Production.ProductInventory  
group by LocationID
order by min_bin

--30. Find out the product available in most of the locations (product inventory)
 select * from Production.ProductInventory 

 select top 1 with ties   p.Name p_name,
 i.ProductID , count(i.LocationID) loc
 from Production.ProductInventory i
 join Production.Product p
on i.ProductID = p.ProductID
group by i.ProductID , p.Name
order by loc  desc;

--31.. Which sales order is having most order qualtity.
select * from sales.SalesOrderDetail

 select top 1 with ties 
		SalesOrderID, count(orderqty) most_ordered_quality
from sales.SalesOrderDetail
group by SalesOrderID
order by most_ordered_quality desc; 


-- 32 . 


--- 33. check if any employee from jobcandidate table is having any payment revisions  
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

--- Que.34 check the department having more salary revision 



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


---35.check the employee whose payment is not yet revised
select * from HumanResources.EmployeePayHistory p ---
select * from HumanResources.EmployeeDepartmentHistory h


select h.businessentityid, p.payfrequency , count(*) as revisioncount
from HumanResources.employeedepartmenthistory h 
join 
HumanResources.EmployeePayHistory p 
on h.BusinessEntityID=p.BusinessEntityID
group by h.BusinessEntityID,p.PayFrequency
having  count(*) =0;






--36. find the job title having more revised payments 

select  top 1 job_title , count(*) from 
( select e.JobTitle job_title , count(*) cnt , e.BusinessEntityID id 
from humanresources.employee e , HumanResources.EmployeePayHistory ep
where e.BusinessEntityID = ep.BusinessEntityID
group by e.JobTitle, e.BusinessEntityID 
having count(*) >1 ) as t 
group by t.job_title
order by count(*) desc;

--37.  find the employee whose payment is revised in shortest duration (inline view) 


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


--- Que 38)  find the colour wise count of the product (tbl: product) 

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
--- Que.39)  find out the product who are not in position to sell (hint: check the sell start and end date) 

select * from Production.Product p

select p.name as p_name ,SellStartDate, SellEndDate
from Production.Product p 
where p.sellenddate is not  null


--- 40.find the class wise, style wise average standard cost 
select * from Production.Product p 

select p.standardcost , count(p.style) as c_style , count(p.class) as c_class 
from Production.Product p 
group by p.StandardCost 
order by c_class,c_style


--41. check colour wise standard cost 
select standardcost , count(color) clr_count
from Production.Product 
group by StandardCost
order by clr_count

---42. find the product line wise standard cost 

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

--- 43.Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 
select * from Sales.SalesTaxRate
select * from  Person.StateProvince 

select s.[name], t.taxrate
from Person.StateProvince s ,Sales.SalesTaxRate t
where t.StateProvinceID = s.StateProvinceID


-------------- 0r---------
SELECT s.Name AS StateName, t.TaxRate
FROM Sales.SalesTaxRate t
JOIN Person.StateProvince s ON t.StateProvinceID = s.StateProvinceID;


--- 44) Find the department wise count of employees.
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


---- 45 Find the department which is having more employees 
select * from humanresources.Department
select * from HumanResources.EmployeeDepartmentHistory


select top 1 d.[Name], count(h.BusinessEntityID) ID
from humanresources.Department d, HumanResources.EmployeeDepartmentHistory h
where h.DepartmentID=d.DepartmentID
group by d.[Name]
order by id desc

--- 46 Find the job title having more employees 


select jobtitle,count(businessentityid) id
from  HumanResources.Employee 
group by JobTitle
order by  id desc;

----47 Check if there is mass hiring of employees on single day 
select * from HumanResources.Employee 

select hiredate , count(*) c
from HumanResources.Employee
group by HireDate
order by c desc

---48) Which product is purchased more? (purchase order details) 
select * from Purchasing.PurchaseOrderDetail
select * from Production.Product


select top 1 p.[name],  sum(d.orderQty) max_purchase  
from Purchasing.PurchaseOrderDetail d,
		Production.Product p
where d.ProductID = p.ProductID
group by p.[name]
order by max_purchase desc


--- Que.49) Find the territory wise customers count   (hint: customer) 
select * from Sales.Customer
select * from Sales.SalesTerritory


select t.territoryid  , count(*) cust_count 
from sales.Customer t
group by t.territoryid
order by cust_count


----50. Which territory is having more customers (hint: customer) 
select * from Sales.Customer
select * from Sales.SalesTerritory

select top 1 t.[name]  t_name , count(c.CustomerID) id
from sales.Customer c, Sales.SalesTerritory t
where t.TerritoryID = c.TerritoryID
group by t.[name]
order by id desc


--- 51)Which territory is having more stores (hint: customer) 
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


--52. Is there any person having more than one credit card (hint: PersonCreditCard)
select * from  sales.PersonCreditCard


select count(CreditCardID) id from sales.PersonCreditCard
where  BusinessEntityID  <1


---Q53)Find the product wise sale price 
select * from sales.SalesOrderDetail
select * from Production.Product

select unitprice ,
(select p.[Name] from Production.Product p
where d.ProductID = p.productid )
from Sales.SalesOrderDetail d

---Q 54 Find the total values for line total product having maximum order 
select * from sales.SalesOrderDetail
select * from Production.Product

select top 1 linetotal , max(orderQty) qty
from sales.SalesOrderDetail 
group by LineTotal
order by qty desc;

--                                          ******* Date Queries ******   

 -- 55. Calculate the age of employees 
 select * from HumanResources.Employee 
 select * from HumanResources.EmployeeDepartmentHistory

 select BusinessEntityID,birthdate, dATEDIFF(year,e.BirthDate,getdate()) age
 from HumanResources.Employee e



 ---Q56)Calculate the year of experience of the employee based on hire date 

 select e.businessentityid, e.HireDate, DATEDIFF(year, e.HireDate, h.EndDate) yr_exp
 from HumanResources.Employee e
  join HumanResources.EmployeeDepartmentHistory h
on e.BusinessEntityID=h.BusinessEntityID


---Q57) Find the age of employee at the time of joining 
 
select BusinessEntityID, BirthDate,HireDate,datediff(year,e.BirthDate,e.HireDate) time_of_joining
from HumanResources.Employee e

---Q58) Find the average age of male and female 
select * from HumanResources.Employee

select Gender , avg(DATEDIFF(year, birthDate, GETDATE()))	age																	
from HumanResources.Employee 
group  by Gender

---Q59) Which product is the oldest product as on the date (refer  the product sell start date) 

select top 10 p.name ,DATEDIFF(DAY, SellStartDate,GETDATE()) oldProduct
from Production.Product p


 --- Q 60) Display the product name, standard cost, and time duration for the same cost. (Product cost history)
 select * from Production.ProductCostHistory c
 select * from Production.Product p 

 select p.name p_name , p.standardcost , c.startdate, c.enddate, DATEDIFF(year,c.StartDate, c.EndDate) time_duration_cost
 from Production.ProductCostHistory c
 join Production.Product p 
 on p.ProductID = c.ProductID
--- where c.EndDate is not null
order by p.Name , c.StartDate
 
 --61. Find the purchase id where shipment is done 1 month later of order date


 select purchaseorderid ,ShipMethodID, orderdate, ShipDate 
 from Purchasing.PurchaseOrderHeader 
 where  datediff(month, OrderDate, ShipDate) =1 ;

---62. Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)
select * from Purchasing.PurchaseOrderHeader  


 select sum(totaldue) ,PurchaseOrderID
 from Purchasing.PurchaseOrderHeader 
 where  datediff(month, OrderDate, ShipDate) =1 ;


---63. Find the average difference in due date and ship date based on online order flag 
select *from sales.SalesOrderHeader

select avg(datediff(day ,ShipDate,DueDate)) as avg_due_ship_diff , OnlineOrderFlag
from sales.SalesOrderHeader
group by OnlineOrderFlag;


----                                                                                         **** Window functions **** 
-- 64 . display businessentityid , marital status, gender, vacation hr ,avg vaction basted on marital status

select BusinessEntityID,MaritalStatus,gender, VacationHours,
		avg(vacationhours) over (partition by maritalstatus) vac_based_on_marital_status
from HumanResources.Employee 


-- 65. Display business entity id, marital status, gender, vacationhr, average vacation based on gender

select BusinessEntityID,MaritalStatus,gender, VacationHours, 
	AVG(vacationhours) over (partition by gender) gender_wise_vacc
from HumanResources.Employee

--66. Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level

select BusinessEntityID,MaritalStatus,gender, VacationHours,
	avg(vacationhours) over (partition by organizationlevel) 
from HumanResources.Employee

--67. Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept

select  OrganizationLevel , d.DepartmentID,
	count(e.BusinessEntityID)  over (partition by d.departmentid ) dept_wise_emp,
	count(d.DepartmentID) over (partition by organizationlevel) org_wise_depart
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory h
on h.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d
on h.DepartmentID= d.DepartmentID 

---68. Display department name, average sick leave and sick leave per department
select d.Name AS DepartmentName ,
		avg( e.SickLeaveHours) over (partition by d.departmentid) sickleaves , 
	 sum( e.SickLeaveHours) over ( partition by d.DepartmentID) avg_sick_leaves
from  HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory h
on h.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d
on h.DepartmentID= d.DepartmentID  

--- 69. Display the employee details first name, last name, with total count of various shift done by the person and shifts count per department

select CONCAT_WS(' ',p.firstname, p.lastname),
		h.shiftid, d.name d_name, s.name shift_name,
		count(s.ShiftID) over (partition by d.name) dpt_count
	from Person.Person p
join  HumanResources.EmployeeDepartmentHistory h
on p.BusinessEntityID = h.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID = h.DepartmentID
join HumanResources.Shift s
on s.shiftid = h.shiftid  


--70 . 70. Display country region code, group average sales quota based on territory id
select  distinct(t.TerritoryID),t.CountryRegionCode ,
t.[Group],avg(p.SalesQuota) over (partition by p.territoryId)
from sales.SalesPerson p
join  Sales.SalesTerritory t
on t.TerritoryID = p.TerritoryID

-- 71. Display special offer description, category and avg(discount pct) per the category 

select s.[description],s.Category,s.DiscountPct,
		avg(s.discountpct) over (partition by s.category) avg_disc_per_cat
from  sales.SpecialOffer s 

-- 72. Display special offer description, category and avg(discount pct) per the month 
 select s.[description],s.Category,s.DiscountPct,s.startdate,
		avg(s.discountpct) over (partition by MONTH(startdate)) avg_disc_per_month
from  sales.SpecialOffer s 

-- 73) Display special offer description, category and avg(discount pct) per the year
 select s.[description],s.Category,s.DiscountPct,s.startdate,
		avg(s.discountpct) over (partition by year(startdate)) avg_disc_per_yr
from  sales.SpecialOffer s 

-- 74)  Display special offer description, category and avg(discount pct) per the type
select s.[description],s.Category,s.DiscountPct,s.[type],
		avg(s.discountpct) over (partition by s.[type]) avg_disc_per_month
from  sales.SpecialOffer s 

---75)Using rank and dense rank find territory wise top sales person 
select * from sales.SalesPerson s 
select * from sales.SalesTerritory t 
select * from Person.Person p 


select 
		t.name t_name ,concat_ws(' ', p.FirstName, p.lastname),
    RANK() OVER (PARTITION BY t.TerritoryID ORDER BY s.SalesYTD DESC) Rank_Sales,
    DENSE_RANK() OVER (PARTITION BY t.TerritoryID ORDER BY s.salesytd desc)  dense_rank_sales
from sales.SalesTerritory t
join sales.salesperson s
on t.territoryid = s.territoryid
join person.person p
on p.businessentityid = s.businessentityid;


--- How to extract images is link and file name is given:
---(Hint: refer Production.ProductPhoto)


SELECT ProductPhotoID, LargePhotoFileName, 'https://your_image_url/' + LargePhotoFileName AS ImageLink
FROM Production.ProductPhoto;

SELECT ProductPhotoID, LargePhoto 
FROM Production.ProductPhoto;










