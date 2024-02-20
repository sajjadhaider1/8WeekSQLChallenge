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

