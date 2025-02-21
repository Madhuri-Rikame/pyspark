use [AdventureWorks2022]

--1.Find the first 20 employees who joined very early in the company.
--RequiredTable
select *from [HumanResources].[Employee]
select*from Person.Person
--Query
select top 20 
Concat_ws('',p.firstName,p.Lastname)Emp_Name_Who_joinEarly
from [HumanResources].[Employee] e,
person.person p
where p.businessEntityId=e.BusinessEntityID
order by e.HireDate asc;

/*2.Find all employees names, job titles, and card details
whose credit card expired in the month 9 and year 2009.*/

select*from person.person
select*from [HumanResources].[Employee]
select*from [Sales].[CreditCard]
select*from [Sales].[PersonCreditCard]

select pp.firstName,
pp.Lastname,
e.jobTitle,
c.cardType,
c.Cardnumber,
c.expMonth,
c.expYear
from person.person pp,
 [HumanResources].[Employee] e,
 [Sales].[CreditCard] c,
 [Sales].[PersonCreditCard] pc
 where pp.businessEntityID=pc.businessEntityID and
 e.BusinessEntityID=pc.businessEntityID and
 c.creditcardId=pc.creditcardId and
 c.expMonth=9 and c.expyear=2009

 --Conclusion:there is no employee whose credit card expired in the month 9 and year 2009

/*3.Find the store address and contact number based on tables "store" 
and "Business entity". Check if any other table is required.*/

select*From sales.store
select*from [Person].[BusinessEntity]
select*from [Person].[Address]
select*From [Person].[AddressType]
--Query
select 
    s.Name AS StoreName, 
    a.AddressLine1, 
    a.AddressLine2, 
    a.City, 
    sp.Name AS StateProvince, 
    a.PostalCode, 
    pp.PhoneNumber
from [Sales].[Store] s
JOIN [Person].[BusinessEntity] be ON s.BusinessEntityID = be.BusinessEntityID
JOIN [Person].[BusinessEntityAddress] bea ON be.BusinessEntityID = bea.BusinessEntityID
JOIN [Person].[Address] a ON bea.AddressID = a.AddressID
JOIN [Person].[StateProvince] sp ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN [Person].[PersonPhone] pp ON be.BusinessEntityID = pp.BusinessEntityID;


/*4.Check if any employee from the "job candidate" table has any payment revisions.*/
select*from [HumanResources].[JobCandidate]
select*from[HumanResources].[EmployeePayHistory]
select*from person.person

select JobCandidateID
from [HumanResources].[JobCandidate] 
where BusinessEntityID in
(select BusinessEntityID 
from[HumanResources].[EmployeePayHistory]
where PayFrequency>0)
--or
select j.Jobcandidateid,
pp.FirstName,
pp.LastName
from person.person pp,
[HumanResources].[EmployeePayHistory] p,
[HumanResources].[JobCandidate] j
where pp.businessentityid=j.businessentityId and
j.businessentityID=p.businessentityid and
p.payfrequency>0

/*5.Check color-wise standard cost.*/
select*from [Production].[Product]
select*from [Production].[ProductCostHistory]

select standardcost,
count(*)over (partition by color) color_wise_count
from [Production].[Product] 
order by color
--or
select standardcost
from [Production].[Product] 
order by color

/*6.Which product is purchased more? (Based on purchase order details).*/
select*from [Production].[Product] 
select*from[Purchasing].[PurchaseOrderDetail]

select top 1 p.productID,
p.Name,po.Purchaseorderid,
sum(po.orderQty) as totalpurchased
from [Purchasing].[PurchaseOrderDetail] po,
[Production].[Product] p
where po.productID=p.ProductID
group by p.productId,p.productID,
p.Name,po.Purchaseorderid
order by totalpurchased desc

/*7.Find the total values for "line total" for the product having the maximum order.*/
select*from [Production].[Product]

/*8.Which product is the oldest product as of today? (Refer to the product sell start date).*/
select top 1 with TIES 
    ProductID, 
    Name AS ProductName, 
    SellStartDate
from [Production].[Product]
order by SellStartDate asc;

/*9.Find all the employees whose salary is more than the average salary.*/
select*from [HumanResources].[EmployeePayHistory]
select*from [HumanResources].[JobCandidate]
select*from [HumanResources].[Employee]
select*from Person.Person
select*from [Sales].[SalesTerritory]

select e.BusinessEntityID, e.JobTitle, eph.Rate as Salary
from [HumanResources].[EmployeePayHistory] eph
join [HumanResources].[Employee] e on eph.BusinessEntityID = e.BusinessEntityID
where eph.Rate > (select AVG(Rate) from [HumanResources].[EmployeePayHistory])
order by eph.Rate desc;

/*10.Display country region code, group average sales quota based on territory ID.*/
use [AdventureWorks2022]
select*from [Sales].[SalesTerritory]
select*from [Sales].[SalesPerson] 

select 
st.countryregioncode,
st.[Group],
avg(sp.salesQuota)over (partition by sp.territoryID) avg_salesquota
from [Sales].[SalesTerritory] st 
join [Sales].[SalesPerson] sp 
on st.territoryID=sp.territoryID

/*11.Find the average age of males and females.*/
select*from [HumanResources].[Employee]

select gender,
avg(datediff(year,birthdate,GETDATE())) avg_age_f_M
from [HumanResources].[Employee]
group by gender

/*12.Which product is purchased more? (Based on purchase order details).*/
select*from [Purchasing].[PurchaseOrderDetail]
select*from [Production].[Product]
--check
select top 1 pp.ProductID,
pp.name productName,
sum(po.orderQty) from 
[Purchasing].[PurchaseOrderDetail] po,
[Production].[Product] pp
group by pp.ProductID,pp.Name
order by sum(po.orderQty)
--or
select top 1 pp.ProductID,po.PurchaseOrderID,
pp.name productName,
sum(po.orderQty) from 
[Purchasing].[PurchaseOrderDetail] po,
[Production].[Product] pp
group by pp.ProductID,pp.Name,po.PurchaseOrderID
order by po.PurchaseOrderID

/*13.Check for salesperson details who are working in stores (find the salesperson ID).*/
select*from[Sales].[SalesPerson]  
select*from [Sales].[Store] 

select * 
from [Sales].[Store] 
where businessentityID in
(select businessentityID
from[Sales].[SalesPerson])

select salespersonID
from [Sales].[SalesPerson] sp
join [Sales].[Store] s
on sp.BusinessEntityID=s.BusinessEntityID

/*14.Display the product name, product price, 
and count of product cost revisions (from product cost history).*/
select*from[Production].[Product] 
select*from[Production].[ProductCostHistory] 

--Query
select 
    p.Name AS ProductName, 
    p.ListPrice AS ProductPrice, 
    COUNT(pch.ProductID) AS CostRevisionCount
from [Production].[Product] p
LEFT JOIN [Production].[ProductCostHistory] pch ON p.ProductID = pch.ProductID
group by p.Name, p.ListPrice
order by CostRevisionCount desc; 

/*15.Check which department has more salary revisions.*/
select*from[HumanResources].[EmployeePayHistory] 
select*from[HumanResources].[Department]
select*from[HumanResources].[EmployeeDepartmentHistory]

select top 1 
d.DepartmentID,
d.Name Dept_name,PayFrequency
from [HumanResources].[Department] d join
[HumanResources].[EmployeeDepartmentHistory] ed 
on d.DepartmentID=ed.DepartmentID join
[HumanResources].[EmployeePayHistory] ep 
on ep.BusinessEntityID=ed.BusinessEntityID
order by PayFrequency
