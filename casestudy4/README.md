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

This case study explores the intersection of banking and data storage. Through data analysis and insights, your aim is to optimize operations and enhance customer experience at Data Bank.

---

# Solution: Exploring Customer Nodes and Transactions

## A. Customer Nodes Exploration

### 1. Unique Nodes Analysis

The first step in understanding Data Bank's infrastructure is to determine the number of unique nodes on the system.

```sql
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;
```

This query counts the distinct `node_id` values from the `customer_nodes` table, providing insight into the network's scale.

### 2. Nodes per Region

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

### 3. Customer Allocation by Region

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

### 4. Customer Reallocation Analysis

Analyzing the frequency of customer reallocation to different nodes sheds light on system dynamics.

```sql
SELECT AVG(DATEDIFF(end_date, start_date)) as avg_days
FROM customer_nodes
WHERE end_date != '99991231';
```

By computing the average duration between node reallocations, we gauge customer mobility within the system.

### 5. Reallocation Days Percentile Analysis by Region

To assess reallocation patterns across regions, we analyze percentile metrics.

```sql
WITH RankedNodes AS (
	SELECT
		r.region_id as r_id,
		r.region_name as r_name,
		DATEDIFF(end_date, start_date) AS days_spent,
		((ROW_NUMBER() OVER (PARTITION BY r.region_name ORDER BY DATEDIFF(c.end_date, c.start_date))-1)/COUNT(*) OVER (PARTITION BY r.region_name))*100 as percentile
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

This query calculates the median, 80th, and 95th percentiles of reallocation days for each region, aiding in regional performance evaluation.

## B. Customer Transactions Analysis

### 1. Transaction Type Summary

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

### 2. Historical Deposit Analysis

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

### 3. Monthly Transaction Analysis

Analyzing monthly transactions helps identify patterns and customer behavior trends.

```sql
WITH MonthlySummary AS (
    SELECT
        MONTH(txn_date) AS txn_month,
        customer_id,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposits,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawals,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchases
    FROM customer_transactions
    GROUP BY MONTH(tx

n_date), customer_id) 
SELECT txn_month, COUNT(customer_id)
FROM MonthlySummary
WHERE deposits > 1 AND (withdrawals > 0 OR purchases > 0)
GROUP BY txn_month
ORDER BY txn_month;
```

This query identifies months where customers made multiple deposits and either a purchase or a withdrawal, providing insights into transaction frequency.

### 4. Monthly Closing Balance Analysis

Analyzing monthly closing balances provides insights into customer financial health.

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

By computing closing balances, we track changes in customer financial positions over time.

### 5. Percentage of Customers with Increased Closing Balance

Analyzing the percentage of customers with increased closing balances aids in assessing financial growth.

```sql
SELECT ROUND(SUM((bal - prevbal)/prevbal > 0.05)/COUNT(DISTINCT customer_id)*100, 2) as pct_customers
FROM (
	SELECT *, 
    LAG(bal) OVER (PARTITION BY customer_id ORDER BY month) as prevbal
	FROM (SELECT
			customer_id, MONTH(txn_date) AS month,
			SUM(SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END)) 
				OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) ROWS UNBOUNDED PRECEDING) AS bal,
			ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) DESC) AS row_num
		FROM customer_transactions GROUP BY 1, 2 ORDER BY 1, 2) AS m) AS f
WHERE row_num = 1;
```

This query computes the percentage of customers with closing balance increases exceeding 5%, providing insights into financial growth trends.

---

The above SQL queries analyze customer nodes and transactions for Data Bank, offering valuable insights for strategic decision-making and business optimization.
