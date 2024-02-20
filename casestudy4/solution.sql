## A. Customer Nodes Exploration

### 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

### 2. What is the number of nodes per region?
SELECT 
  r.region_id,
  r.region_name,
  COUNT(n.node_id) AS nodes
FROM customer_nodes n
JOIN regions r ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;

### 3. How many customers are allocated to each region?
SELECT 
  r.region_id,
  r.region_name,
  COUNT(DISTINCT n.customer_id) AS customers
FROM customer_nodes n
JOIN regions r ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;

### 4. How many days on average are customers reallocated to a different node?

SELECT AVG(DATEDIFF(end_date, start_date)) as avg_days
FROM customer_nodes
WHERE end_date != '99991231';

### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

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
	

## B. Customer Transactions

### 1. What is the unique count and total amount for each transaction type?

SELECT 
	txn_type,
    COUNT(*) as count,
    SUM(txn_amount) as amount
FROM customer_transactions
GROUP BY txn_type
ORDER BY 2;

### 2. What is the average total historical deposit counts and amounts for all customers?

SELECT
	AVG(c) as avg_count,
    AVG(s) as avg_amount
FROM 
	(SELECT COUNT(txn_type) as c, SUM(txn_amount) as s
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id) as subquery;

### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

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
GROUP BY txn_month
ORDER BY txn_month;

### 4. What is the closing balance for each customer at the end of the month?

SELECT
	customer_id,
	MONTH(txn_date) AS month,
	SUM(
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END)) 
		OVER (PARTITION BY customer_id ORDER BY MONTH(txn_date) ROWS UNBOUNDED PRECEDING) 
        AS closing_balance
FROM customer_transactions
GROUP BY 1, 2 ORDER BY 1, 2;



### 5. What is the percentage of customers who increased their closing balance by more than 5%?

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
