use Q4_orders
go

drop table if exists Q4_orders.dbo.orders
drop table if exists Q4_orders.dbo.order_delivery
go

create table ORDERS(
Order_ID int,
Date_Order date,
Good_Type nvarchar(20),
Good_Amount int,
Client_ID int)
go
create table ORDER_DELIVERY(
Order_ID int,
Date_Delivery date,
Delivery_Employee_Code char(5))
go

insert into ORDERS values (10, '05-01-2019', 'Computer', 10000000, 88)
insert into ORDERS values (12, '05-05-2020', 'Computer', 10000000, 88)
insert into ORDERS values (24, '06-06-2020', 'Laptop', 8000000, 123)
insert into ORDERS values (45, '01-07-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (46, '01-08-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (47, '01-15-2024', 'Monitor', 2000000, 10)
insert into ORDERS values (48, '02-16-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (49, '02-28-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (50, '02-28-2024', 'Monitor', 2000000, 10)
insert into ORDERS values (51, '03-07-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (52, '05-08-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (53, '06-08-2024', 'Monitor', 2000000, 10)
insert into ORDERS values (54, '06-07-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (55, '08-01-2024', 'Monitor', 3000000, 10)
insert into ORDERS values (56, '08-08-2024', 'Monitor', 2000000, 10)
go

insert into ORDER_DELIVERY values (15,'07-06-2020','1a')
insert into ORDER_DELIVERY values (2,'04-22-2017','5c')
insert into ORDER_DELIVERY values (3,'11-09-2018','6e')
insert into ORDER_DELIVERY values (10,'09-10-2019','2e')

-- 1 Count number of unique client order and number of orders by order month.
select	YEAR(o.Date_Order) as Year, 
		MONTH(o.Date_Order) as Month,
		count (o.Order_ID) as number_of_orders , 
		count(distinct o.Client_ID) as number_of_unique_client_order
from ORDERS o
group by YEAR(o.Date_Order), MONTH(o.Date_Order)

-- 2 Get list of client who have more than 10 orders in this year (every year).
select YEAR(o.Date_Order) as Year, o.Client_ID as client_have_more_than_10_orders
from ORDERS o
-- condition for this year
where  YEAR(o.Date_Order) = YEAR(GETDATE())
group by YEAR(o.Date_Order), o.Client_ID
having count (o.Order_ID) > 10

-- 3 From the above list of client: get information of first and second last order of client (Order date,
--goods type, and amount)

select top 2 o.Date_Order, o.Good_Type, o.Good_Amount
from ORDERS o
where o.Client_ID in (select o.Client_ID as client_have_more_than_10_orders
					from ORDERS o
					-- condition for this year
					where  YEAR(o.Date_Order) = YEAR(GETDATE())
					group by YEAR(o.Date_Order), o.Client_ID
					having count (o.Order_ID) > 10)
order by o.Date_Order desc

-- 4 Calculate total good amount and Count number of Order which were delivered in Sep.2019
select sum(Good_Amount) as sum_good_amount, count(od.Order_ID) as num_order
from ORDERS o join ORDER_DELIVERY od on o.Order_ID = od.Order_ID
where YEAR(od.Date_Delivery) = 2019 and MONTH(od.Date_Delivery) = 09

-- 5 Assuming your 2 tables contain a huge amount of data and each join will take about 30 hours, 
-- while you need to do daily report, what is your solution?

-- Giải pháp: Sử dụng kết hợp đánh chỉ mục (index) và phân vùng dữ liệu (partition) cho các bảng cần join với nhau,
-- nếu thực hiện hợp lý, thời gian thực thi sẽ giảm đáng kể.