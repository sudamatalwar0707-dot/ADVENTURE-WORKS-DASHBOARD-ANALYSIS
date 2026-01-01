Create database Adventure_Works;

use Adventure_Works;

-- 1. Union of Fact Internet sales and Fact internet_sales_new

create table Sales_data as select * from factinternetsales 
union all select * from fact_internet_sales_new;

-- 2. Adding Sale_Amount, Production_Cost, profit Column with their respective data

Alter table sales_data add column Sales_Amount decimal(10,2);
Alter table sales_data add column Production_Cost decimal(10,2);
Alter table sales_data add column profit decimal(10,2);

update sales_data set Sales_Amount = (UnitPrice - DiscountAmount) * OrderQuantity;

update sales_data set Production_Cost = (ProductStandardCost * OrderQuantity);

update sales_data set Profit = Sales_Amount - Production_Cost;

-- 3. To Calculate all the KPI Value in Million

select round( sum(sales_amount)/1000000,2) as Total_Sales_in_Million,
round( sum(profit)/1000000,2) as Total_Profit_in_Million,
 round(sum(Production_Cost)/1000000,2) as Total_Production_Cost,
 round(sum(TaxAmt)/1000000,2) as Total_Tax_Amount,
 count(OrderQuantity) as total_order_Placed From sales_data;
 
 -- 4. Alter table Dimcustomer by adding Customer_Full_Name Using Concate Function
alter table dimcustomer  add column customer_Fullname varchar(150);
update dimcustomer set customer_Fullname = concat(FirstName,MiddleName,LastName);

-- 5. Calculate Customer_Full name , gender, yearly income, each Customer order Placed, to get customers detailed information

select customer_Fullname,Gender,YearlyIncome, count(OrderQuantity) as Orders_Placed_by_Customer, sum(Profit) As Profit_Amount
from dimcustomer inner join sales_data 
on dimcustomer.CustomerKey = sales_data.CustomerKey
group by customer_Fullname,Gender,YearlyIncome
order by Profit_Amount desc;

-- 6. Calculate the Product wise profit & Sales Details

select EnglishProductName,round(sum(profit),2)as  profit, round(sum(Sales_Amount),2) as Sales From dimproduct
inner join sales_data on sales_data.productkey = dimproduct.ProductKey
group by  EnglishProductName 
order by profit desc;
 
-- 7. Calculate the Sub-Product wise profit & Sales Detailes

select EnglishProductSubcategoryName,round(sum(profit),2) as profit, round(sum(Sales_Amount),2) as Sales_Amount From dimproductsubcategory
inner join dimproduct on  dimproduct.ProductSubcategoryKey = dimproductsubcategory.ProductSubcategoryKey 
inner join sales_data on dimproduct.ProductKey = sales_data.productkey
group by  EnglishProductSubcategoryName 
order by profit desc;

 -- 8. Calculate the Category wise profit & Sales Details
Select EnglishProductCategoryName,round(sum(profit),2) as profit,round(sum(Sales_Amount),2) as sales from dimproductcategory
inner join dimproductsubcategory on dimproductcategory.ProductCategoryKey = dimproductsubcategory.ProductCategoryKey
inner join dimproduct on dimproductsubcategory.ProductSubcategoryKey = dimproduct.ProductSubcategoryKey
inner join sales_data on dimproduct.ProductKey = sales_data.productkey
group by EnglishProductCategoryName
order by profit desc;
 
--  9. Calculate Territory Country wise Profit & Sales Data

select SalesTerritoryCountry,round(sum(profit),2) as Territory_Country_Profit,round(sum(sales_amount),2) as Territory_Country_Sales
from dimsalesterritory join Sales_data on dimsalesterritory.SalesTerritoryKey = sales_data.SalesTerritoryKey
group by SalesTerritoryCountry
order by Territory_Country_Profit desc;

-- 10. Create view for getting the entire details of product 

create view product_details as
	select EnglishProductName,Size,DaysToManufacture,Status,
    round(sum(profit),2) as product_profit,round(sum(Sales_Amount),2) as product_sales,
    count(OrderQuantity) as order_quntity_of_Product from dimproduct 
    inner join sales_data on dimproduct.ProductKey = sales_data.ProductKey
    group by EnglishProductName,Size,DaysToManufacture,Status;

select * from product_details;

-- 11. Create the Stored procedure to get the Customers details

delimiter //
create procedure Customer_Details()
begin
	select customer_Fullname,Gender,YearlyIncome, 
    count(OrderQuantity) as Orders_Placed_by_Customer, 
    round(sum(Profit),2) As Profit_Amount,
    round(sum(UnitPrice),2) as Unit_Price,
	round(sum(sales_amount),2) As Sales_Amount
	from dimcustomer inner join sales_data 
	on dimcustomer.CustomerKey = sales_data.CustomerKey
	group by customer_Fullname,Gender,YearlyIncome
	order by Profit_Amount desc;

	end //

call Customer_Details();

-- 12. Create the Stored procedure to get the country details

delimiter //
create procedure Country_details(in country_Name varchar(50))
begin
	select SalesTerritoryCountry,round(sum(profit),2) as Country_Profit,
    round(sum(sales_amount),2) as Country_Sales, 
    round(sum(Production_Cost),2) as Country_Production_Cost, 
    round(sum(TaxAmt),2) as Territory_Country_taxAmt, 
    count(OrderQuantity) as Total_order_from_Country ,
    round(sum(UnitPrice),2) as Unit_Price
    from dimsalesterritory inner join sales_data on 
    dimsalesterritory.SalesTerritoryKey = sales_data.SalesTerritoryKey
    where SalesTerritoryCountry = country_Name
    group by SalesTerritoryCountry;
end //

call Country_details("United States");
call Country_details("Australia");
 call Country_details("france");
call Country_details("Germany");
call Country_details("Canada");
call Country_details("United Kingdom");








