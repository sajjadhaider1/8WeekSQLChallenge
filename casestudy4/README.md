# Case Study #4 - Data Bank
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" align="center" width="400" height="400" >

## Introduction:

The financial industry is witnessing the rise of Neo-Banks: digital-only banks without physical branches. Inspired by this innovation, Danny launches Data Bank, a digital bank that also offers secure distributed data storage.

Data Bank allocates cloud storage limits to customers based on their account balances. To better understand customer behavior and plan for future developments, the management team needs insights into metrics and growth projections.

## Available Data:

### Entity Relationship Diagram

<img src="https://8weeksqlchallenge.com/images/case-study-4-erd.png" align="center">

### Table 1: Regions

Data Bank operates on a network of nodes distributed across regions globally.

| region_id | region_name |
|-----------|-------------|
| 1         | Africa      |
| 2         | America     |
| 3         | Asia        |
| 4         | Europe      |
| 5         | Oceania     |


### Table 2: Customer Nodes

Customers are allocated to nodes based on their regions. Below is a sample of the top 10 rows of the `data_bank.customer_nodes`:

| customer_id | region_id | node_id | start_date | end_date   |
|-------------|-----------|---------|------------|------------|
| 1           | 3         | 4       | 2020-01-02 | 2020-01-03 |
| 2           | 3         | 5       | 2020-01-03 | 2020-01-17 |
| 3           | 5         | 4       | 2020-01-27 | 2020-02-18 |
| 4           | 5         | 4       | 2020-01-07 | 2020-01-19 |
| 5           | 3         | 3       | 2020-01-15 | 2020-01-23 |
| 6           | 1         | 1       | 2020-01-11 | 2020-02-06 |
| 7           | 2         | 5       | 2020-01-20 | 2020-02-04 |
| 8           | 1         | 2       | 2020-01-15 | 2020-01-28 |
| 9           | 4         | 5       | 2020-01-21 | 2020-01-25 |
| 10          | 3         | 4       | 2020-01-13 | 2020-01-14 |


### Table 3: Customer Transactions

This table records all customer transactions: deposits, withdrawals, and purchases.

| customer_id | txn_date   | txn_type | txn_amount |
|-------------|------------|----------|------------|
| 429         | 2020-01-21 | deposit  | 82         |
| 155         | 2020-01-10 | deposit  | 712        |
| 398         | 2020-01-01 | deposit  | 196        |
| 255         | 2020-01-14 | deposit  | 563        |
| 185         | 2020-01-29 | deposit  | 626        |
| 309         | 2020-01-13 | deposit  | 995        |
| 312         | 2020-01-20 | deposit  | 485        |
| 376         | 2020-01-03 | deposit  | 706        |
| 188         | 2020-01-13 | deposit  | 601        |
| 138         | 2020-01-11 | deposit  | 520        |

## Case Study Questions

### A. Customer Nodes Exploration

1. **Unique Nodes:** How many unique nodes are there in the Data Bank system?
2. **Nodes per Region:** What is the number of nodes per region?
3. **Customers per Region:** How many customers are allocated to each region?
4. **Customer Reallocation:** How many days, on average, are customers reallocated to a different node?
5. **Reallocation Metrics:** What are the median, 80th, and 95th percentiles for reallocation days by region?

### B. Customer Transactions

1. **Transaction Analysis:** What is the unique count and total amount for each transaction type?
2. **Historical Deposits:** What is the average total historical deposit count and amount for all customers?
3. **Monthly Transactions:** How many customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. **Closing Balances:** What is the closing balance for each customer at the end of the month?
5. **Percentage Increase:** What is the percentage of customers who increase their closing balance by more than 5%?

---

# Solution: Exploring Customer Nodes and Transactions

This case study explores the intersection of banking and data storage. Through data analysis and insights, our aim is to optimize operations and enhance customer experience at Data Bank.

## A. Customer Nodes Exploration



### 1. Unique Nodes Analysis

**Q: How many unique nodes are there on the Data Bank system?**

The first step in understanding Data Bank's infrastructure is to determine the number of unique nodes on the system.

```sql
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;
```

This query counts the distinct `node_id` values from the `customer_nodes` table, providing insight into the network's scale.

**OUTPUT:**

| unique_nodes |
|--------------|
| 5            |



### 2. Nodes per Region

**Q: What is the number of nodes per region?**

To gain regional insights, we analyze the distribution of nodes across different regions.

```sql
SELECT 
  r.region_id,
  r.region_name,
  COUNT(n.node_id) AS nodes
FROM customer_nodes n
JOIN regions r ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;
```

By joining the `customer_nodes` and `regions` tables, we identify the number of nodes in each region, facilitating resource allocation planning.

**OUTPUT:**

| region_id | region_name | nodes |
|-----------|-------------|-------|
| 1         | Australia   | 770   |
| 2         | America     | 735   |
| 3         | Africa      | 714   |
| 4         | Asia        | 665   |
| 5         | Europe      | 616   |



### 3. Customer Allocation by Region

**How many customers are allocated to each region?**

Understanding customer distribution across regions is essential for targeted marketing and service optimization.

```sql
SELECT 
  r.region_id,
  r.region_name,
  COUNT(DISTINCT n.customer_id) AS customers
FROM customer_nodes n
JOIN regions r ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;
```

This query calculates the count of unique customers allocated to each region, providing insights into regional customer demographics.

**OUTPUT:**

| region_id | region_name | customers |
|-----------|-------------|-----------|
| 1         | Australia   | 110       |
| 2         | America     | 105       |
| 3         | Africa      | 102       |
| 4         | Asia        | 95        |
| 5         | Europe      | 88        |



### 4. Customer Reallocation Analysis

**Q: How many days on average are customers reallocated to a different node?**

Analyzing the frequency of customer reallocation to different nodes sheds light on system dynamics.

```sql
SELECT AVG(DATEDIFF(end_date, start_date)) as avg_days
FROM customer_nodes
WHERE end_date != '99991231';
```

By computing the average duration between node reallocations, we gauge customer mobility within the system.

**OUTPUT:**

| avg_days |
|----------|
| 14.634   |



### 5. Reallocation Days Percentile Analysis by Region

**Q: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**


This SQL query calculates the median, 80th percentile, and 95th percentile for the duration spent in each region by customers. 
It first calculates the durations spent by customers in each region and their corresponding percentiles using a CTE. Then, it selects the region name along with the median, 80th percentile, and 95th percentile durations for each region. The result is a table with four columns: `region`, `median`, `percentile_80`, and `percentile_95`.

```sql
WITH RankedNodes AS (
	SELECT
		r.region_id as r_id,
		r.region_name as r_name,
		DATEDIFF(end_date, start_date) AS days_spent,
		((ROW_NUMBER() 
		    OVER (PARTITION BY r.region_name 
	        ORDER BY DATEDIFF(c.end_date, c.start_date))-1)/COUNT(*)
			OVER (PARTITION BY r.region_name))*100 as percentile
	FROM customer_nodes c join regions r
	ON r.region_id = c.region_id
	WHERE end_date != '99991231'
	ORDER BY r.region_name, percentile)
SELECT
	r_name as region,
    MIN(CASE WHEN percentile >= 50 THEN days_spent END) AS median,
    MIN(CASE WHEN percentile >= 80 THEN days_spent END) AS percentile_80,
    MIN(CASE WHEN percentile >= 95 THEN days_spent END) AS percentile_95
FROM RankedNodes
GROUP BY r_name;
```
**OUTPUT:**

| region    | median | percentile_80 | percentile_95 |
|-----------|--------|---------------|---------------|
| Africa    | 15     | 24            | 28            |
| America   | 15     | 23            | 28            |
| Asia      | 15     | 23            | 28            |
| Australia | 15     | 23            | 28            |
| Europe    | 15     | 24            | 28            |



Let's dive further into each part of the SQL query: 

1. **Common Table Expression (CTE)**:
   - `RankedNodes`: This CTE calculates the duration spent (`days_spent`) by customers in each region. It also assigns a percentile value to each row based on the relative position of the row within its region's duration distribution.

2. **SELECT Clause**:
   - `r_name as region`: This selects the region name from the CTE and aliases it as `region`.
   - `MIN(CASE WHEN percentile >= 50 THEN days_spent END) AS median`: This expression calculates the median by finding the minimum value of `days_spent` where the percentile is greater than or equal to 50.
   - `MIN(CASE WHEN percentile >= 80 THEN days_spent END) AS percentile_80`: This expression calculates the 80th percentile by finding the minimum value of `days_spent` where the percentile is greater than or equal to 80.
   - `MIN(CASE WHEN percentile >= 95 THEN days_spent END) AS percentile_95`: This expression calculates the 95th percentile by finding the minimum value of `days_spent` where the percentile is greater than or equal to 95.

3. **FROM Clause**:
   - `RankedNodes`: This is the CTE we defined earlier, which contains the calculated durations and percentiles for each region.

4. **GROUP BY Clause**:
   - `GROUP BY r_name`: This groups the results by region name.



## B. Customer Transactions Analysis



### 1. Transaction Type Summary

**Q: What is the unique count and total amount for each transaction type?**

Understanding transaction types and their volumes is crucial for business insights.

```sql
SELECT 
	txn_type,
    COUNT(*) as count,
    SUM(txn_amount) as amount
FROM customer_transactions
GROUP BY txn_type
ORDER BY 2;
```

This query summarizes transaction types by count and total amount, providing insights into customer behavior.

**OUTPUT:**

| txn_type   | count | amount  |
|------------|-------|---------|
| withdrawal | 1580  | 793003  |
| purchase   | 1617  | 806537  |
| deposit    | 2671  | 1359168 |



### 2. Historical Deposit Analysis

**Q: What is the average total historical deposit counts and amounts for all customers?**

Analyzing historical deposit counts and amounts aids in understanding customer saving behaviors.

```sql
SELECT
	AVG(c) as avg_count,
    AVG(s) as avg_amount
FROM 
	(SELECT COUNT(txn_type) as c, SUM(txn_amount) as s
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id) as subquery;
```

By computing the average deposit counts and amounts, we gain insights into customer saving trends.

**OUTPUT:**

| avg_count | avg_amount |
|-----------|------------|
| 5.342     | 2718.336   |



### 3. Monthly Transaction Analysis

**Q: For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

The question asks us to analyze customer behavior in terms of their transaction patterns, specifically focusing on months where customers made more than one deposit and either a purchase or a withdrawal. 

The query first calculates a summary of customer transactions by month using a CTE. Then, it filters for months where customers made more than one deposit and either a withdrawal or a purchase. Finally, it counts the number of distinct customers meeting these criteria for each month and presents the results ordered by month.

```sql
WITH MonthlySummary AS (
    SELECT
        MONTH(txn_date) AS txn_month,
        customer_id,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposits,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawals,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchases
    FROM customer_transactions
    GROUP BY MONTH(txn_date), customer_id) 
SELECT txn_month, COUNT(customer_id)
FROM MonthlySummary
WHERE deposits > 1 AND (withdrawals > 0 OR purchases > 0)
GROUP BY txn_month ORDER BY txn_month;
```

**OUTPUT:**

| txn_month | COUNT(customer_id) |
|-----------|--------------------|
| 1         | 168                |
| 2         | 181                |
| 3         | 192                |
| 4         | 70                 |


Let's break down the query:

1. **Common Table Expression (CTE)**:
   - `MonthlySummary`: This CTE calculates a summary of customer transactions aggregated by month (`txn_month`) and `customer_id`. It counts the number of deposits, withdrawals, and purchases made by each customer in each month.

2. **SELECT Clause**:
   - `txn_month`: This selects the month of the transactions from the `MonthlySummary` CTE.
   - `COUNT(customer_id)`: This counts the number of distinct customers who meet the specified conditions in each month.
  
3. **FROM Clause**:
   - `MonthlySummary`: This is the CTE we defined earlier, which contains the aggregated summary of customer transactions by month and customer.

4. **WHERE Clause**:
   - `deposits > 1`: This condition filters for months where customers made more than one deposit.
   - `(withdrawals > 0 OR purchases > 0)`: This condition filters for months where customers made either a withdrawal or a purchase.

5. **GROUP BY Clause**:
   - `GROUP BY txn_month`: This groups the results by month, aggregating the counts of customers meeting the specified conditions for each month.

6. **ORDER BY Clause**:
   - `ORDER BY txn_month`: This orders the results by month in ascending order.



### 4. Monthly Closing Balance Analysis

**Q: What is the closing balance for each customer at the end of the month?**

This SQL query calculates the closing balance for each customer at the end of each month. It utilizes window functions to compute the cumulative sum of transaction amounts for each customer, ordered by month. This effectively calculates the closing balance for each customer at the end of each month based on their transaction history. The result is a table with three columns: `customer_id`, `month`, and `closing_balance`.

```sql
SELECT
	customer_id,
	MONTH(txn_date) AS month,
	SUM(
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END)) 
		OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) ROWS UNBOUNDED PRECEDING) 
        AS closing_balance
FROM customer_transactions
GROUP BY 1, 2 ORDER BY 1, 2;
```
**OUTPUT (truncated):**

| customer_id | month | closing_balance |
|-------------|-------|-----------------|
| 1           | 1     | 312             |
| 1           | 3     | -640            |
| 2           | 1     | 549             |
| 2           | 3     | 610             |
| 3           | 1     | 144             |
| 3           | 2     | -821            |
| 3           | 3     | -1222           |
| 3           | 4     | -729            |
| 4           | 1     | 848             |
| 4           | 3     | 655             |


Let's break down the **SELECT** clause and explore it in detail:

**SELECT Clause**:
   - `customer_id`: This column selects the unique identifier of each customer.
   - `MONTH(txn_date) AS month`: This expression extracts the month component from the `txn_date` column and aliases it as `month`.
   - `SUM(SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END))`: This part is a bit complex:
     - The inner `CASE` statement categorizes transactions as deposits or withdrawals/purchases, with deposits being summed positively and withdrawals/purchases being summed negatively.
     - The outer `SUM` function then aggregates the transaction amounts for each customer and month.
   - `OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) ROWS UNBOUNDED PRECEDING)`: This window function calculates the cumulative sum of transaction amounts for each customer, ordered by month, starting from the beginning of the partition (i.e., from the first month).

By computing closing balances, we track changes in customer financial positions over time.

### 5. Percentage of Customers with Increased Closing Balance

**Q: What is the percentage of customers who increase their closing balance by more than 5%?**

This question is a little ambiguous, so we assume that it is asking us how many customers increased their closing balance at the end of their last month by 5% compared to the previous month. 
My solution calculates the percentage of customers whose closing balance increased by more than 5% month-on-month. The query employs nested subqueries and window functions to analyze transaction data, compute month-on-month closing balance changes for each customer, and finally determine the percentage of customers with significant balance increases.

```sql
SELECT 
    ROUND(
        SUM((bal - prevbal)/prevbal > 0.05)/COUNT(DISTINCT customer_id)*100, 2) 
        as pct_customers
FROM (
	SELECT *, 
    LAG(bal) OVER (PARTITION BY customer_id ORDER BY month) as prevbal
	FROM (
	    SELECT
			customer_id, 
			MONTH(txn_date) AS month,
			SUM(
			    SUM(
			        CASE WHEN txn_type='deposit' 
			        THEN txn_amount ELSE -txn_amount END)) 
		            OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) 
                    ROWS UNBOUNDED PRECEDING) AS bal,
		    ROW_NUMBER() OVER (PARTITION BY customer_id 
		        ORDER BY MONTH(txn_date) DESC) AS row_num
        FROM customer_transactions 
        GROUP BY 1, 2 
        ORDER BY 1, 2
        ) AS m
    ) AS f
WHERE row_num = 1;
```
**OUTPUT:**

| pct_customers |
|---------------|
| 46.4          |


Let's break down the query step by step:

1. **Subquery (m)**:
   - The innermost subquery (m) retrieves data from the `customer_transactions` table and aggregates it by `customer_id` and `MONTH(txn_date)` (representing the month).
   - Within this subquery:
     - The `SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END)` calculates the net transaction amount for each customer in each month. It sums the deposit amounts and subtracts withdrawal amounts.
     - The `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) DESC)` assigns a row number to each record within each customer partition, ordered by the month in descending order.

2. **Window Function (LAG)**:
   - The `LAG(bal) OVER (PARTITION BY customer_id ORDER BY month)` window function retrieves the previous month's closing balance (`bal`) for each customer. It helps to compare the current month's closing balance with the previous month's.

3. **Outer Subquery (f)**:
   - The outer subquery (f) references the results from subquery (m).
   - It calculates the percentage of customers whose closing balance increased by more than 5% month-on-month.
   - The expression `(bal - prevbal)/prevbal` computes the percentage change in closing balance compared to the previous month.
   - The `SUM((bal - prevbal)/prevbal > 0.05)` sums the occurrences where the percentage change is greater than 5%.
   - `COUNT(DISTINCT customer_id)` counts the total number of distinct customers.
   - `(SUM((bal - prevbal)/prevbal > 0.05) / COUNT(DISTINCT customer_id)) * 100` calculates the percentage of customers with a closing balance increase exceeding 5%.

4. **Outer Query**:
   - The outer query simply rounds the calculated percentage to two decimal places using the `ROUND` function and aliases it as `pct_customers`.
