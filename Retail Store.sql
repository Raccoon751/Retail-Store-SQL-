create databASe SQLCASeStudy2RetailAnalysis

use SQLCASeStudy2RetailAnalysis

SELECT * FROM prod_cat_info
SELECT * FROM  Transactions
SELECT * FROM Customer

alter table transactions
alter column total_amt float;


----------------DATA PREPARATION AND UNDERSTANDING-------------------
--1.
SELECT	COUNT(transaction_id) AS CountofTransactions		FROM Transactions
UNION
SELECT	COUNT(customer_Id) AS CountofCustomer		FROM Customer
UNION
SELECT	COUNT(prod_cat_code) AS CountofProducts		FROM prod_cat_info

--2. 
SELECT	count(transaction_id) AS CountofReturn FROM Transactions
		WHERE Qty<0

--3.
SELECT	CONVERT(date, tran_date,103) FROM  Transactions


--4.
SELECT	max(tran_date) AS MaxDate, MIN(tran_date) AS MinDate, 
DATEDIFF(DAY, MIN(tran_date),max(tran_date) ) AS Difference_in_Days,
DATEDIFF(MONTH, MIN(tran_date),max(tran_date) ) AS Difference_in_Months, 
DATEDIFF(YEAR, MIN(tran_date),max(tran_date) ) AS Difference_in_Year
FROM	Transactions

--5.
SELECT *
FROM	prod_cat_info
WHERE	prod_subcat ='diy'

-----------------------------------------------------------------------------------
------------------------DATA ANALYSIS---------------------------------------------
--1.
SELECT	MAX(COUNT_OF_CHANNEL)  AS MAX_USED_CHANNEL
FROM (
		SELECT DISTINCT STORE_TYPE, 
		COUNT(STORE_TYPE) AS COUNT_OF_CHANNEL 
		FROM Transactions
		GROUP BY Store_type
		) AS X


--2.
SELECT		GENDER, COUNT(GENDER) AS COUNT_OF_GENDER FROM Customer
WHERE		GENDER ='M'
GROUP BY 	Gender
UNION ALL
SELECT		GENDER, COUNT(GENDER) AS COUNT_OF_FEMALES FROM CUSTOMER
WHERE		GENDER ='F'
GROUP BY 	Gender


--3.
SELECT		CITY_CODE, 
			COUNT(customer_Id) AS CUSTOMER_PER_CITY
FROM		Customer
GROUP BY	city_code
ORDER BY	CUSTOMER_PER_CITY DESC


--4.
SELECT		prod_subcat FROM prod_cat_info
WHERE		prod_cat='BOOKS'


--5.
SELECT		MAX(QTY) AS MAX_QUANTITY
FROM		Transactions


--6.
SELECT		DISTINCT prod_cat, SUM(total_amt) AS SUM_OF_AMOUNT 
FROM		prod_cat_info AS PC
INNER JOIN	Transactions AS T
ON			PC.prod_cat_code=T.prod_cat_code 
WHERE		PC.prod_cat='ELECTRONICS' 
			OR 
			PC.prod_cat='BOOKS'
GROUP BY	prod_cat


--7. GREATER THAN 10 TRANSACTIONS EXCLUDING RETURNS
SELECT		cust_id, COUNT(QTY) AS TransactionCount
FROM		Transactions
WHERE		QTY>0
GROUP BY	CUST_ID
HAVING		COUNT(QTY)>10


--8. 
SELECT		Store_type, SUM(total_amt) AS TOTAL_AMOUNT FROM prod_cat_info AS PC
INNER JOIN  Transactions AS T
ON			PC.prod_cat_code=T.prod_cat_code
WHERE		prod_cat IN ('ELECTRONICS', 'CLOTHING') 
			AND 
			Store_type = 'FLAGSHIP STORE' 
			AND 
			total_amt>0
GROUP BY	Store_type


--9. 
SELECT		prod_subcat,SUM(total_amt) AS TOTAL_REVENUE FROM Customer AS C
INNER JOIN	Transactions AS T
ON			C.customer_Id=T.cust_id
INNER JOIN	prod_cat_info AS PC
ON			T.prod_cat_code=PC.prod_cat_code AND T.prod_subcat_code = PC.prod_sub_cat_code
WHERE		GENDER = 'M' AND prod_cat='ELECTRONICS'
GROUP BY	prod_subcat


--10.

SELECT		TOP 5 prod_subcat,
			SUM( CASE WHEN QTY <0 THEN QTY ELSE NULL END) *100/ ( select sum(qty) from transactions where qty<0)  AS  prcnt_returns,
			SUM(CASE WHEN TOTAL_AMT> 0 THEN  total_amt ELSE NULL END)*100 /(select sum(total_amt) from Transactions where qty>0 )    AS prcnt_sale
FROM		Transactions AS t1
INNER JOIN	prod_cat_info AS t2 on t1.prod_subcat_code= t2.prod_sub_cat_code
GROUP BY	prod_subcat
ORDER BY	prcnt_sale DESC ;


--11
SELECT		datediff(year, c.DOB, getdate()) dateofbirth, SUM(total_amt) AS Total_Revenue
FROM		customer AS c
INNER JOIN	Transactions AS T
ON			c.customer_Id=t.cust_id
WHERE		datediff(year, c.DOB, getdate()) between 25 and 35
GROUP BY	datediff(year, c.DOB, getdate())
ORDER BY	dateofbirth


--12. Which product category hAS seen the max value of returns in the lASt 3 months of transactions?
SELECT		TOP 1  prod_cat_code,
			abs(sum(qty)) AS max_return,
			dateadd(month,-3,max (tran_date)) AS max_date
FROM		Transactions
WHERE		Qty <0
GROUP BY	prod_cat_code,qty
ORDER BY	max_return DESC


--13 Which store-type sells the maximum products; by value of sales amount and by quantity sold?
SELECT		TOP 1 Store_type, SUM(total_amt) MAX_TOTAL_AMOUNT, SUM(Qty) MAX_QUANTITY
FROM		Transactions
GROUP BY	Store_type
ORDER BY	MAX_TOTAL_AMOUNT DESC, MAX_QUANTITY DESC


--14 What are the categories for which average revenue is above the overall average.
SELECT		prod_cat,AVG(total_amt) AVERAGE_AMOUNT
FROM		Transactions T
INNER JOIN	prod_cat_info P
ON			P.prod_cat_code = T.prod_cat_code
GROUP BY	prod_cat
HAVING		AVG(total_amt) > (SELECT AVG(total_amt) FROM Transactions) 


--15 Find the average and total revenue by each subcategory for the categories which are among TOP 5 categories in terms of quantity sold.
SELECT		TOP 5 prod_cat, prod_subcat,
			sum(qty) AS Quantity_Sold,
			avg(total_amt) AS Average_Revenue,
			sum(total_amt) AS Total_Revenue
FROM		Transactions AS x
JOIN		prod_cat_info AS y on y.prod_cat_code = x.prod_cat_code
WHERE		total_amt >0
GROUP BY	prod_cat, prod_subcat
ORDER BY	Quantity_Sold DESC ;
