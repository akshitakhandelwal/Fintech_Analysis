use fintech;
select * from transactions;


#1.Identify the top 5 users who performed the highest number of successful transactions across all transaction types combined.
with user_acc_txn as (select u.user_id,u.full_name, t.txn_id, t.txn_type
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id=a.account_id
where t.status="Success")

select user_id,count(txn_id) as total,
count(case when txn_type="UPI" then txn_id  end ) as UPI,
count(case when txn_type="Wallet" then txn_id  end) as Wallet,
count(case when txn_type="Credit" then txn_id  end) as Credit,
count(case when txn_type="Refund" then txn_id  end) as Refund,
count(case when txn_type="BNPL" then txn_id  end) as BNPL
from user_acc_txn
group by user_id
order by count(txn_id) desc
limit 5;

#2.For each month in the last year, calculate the number of unique users who made at least one successful transaction.
with query as (select u.user_id,u.full_name, t.txn_id, t.txn_time
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id=a.account_id
where t.status="Success")

select monthname(txn_time) as month, count(distinct(user_id)) as unique_users
from query
group by monthname(txn_time)
order by count(distinct(user_id)) desc;

#3.Find all users who have ever made a single transaction amount greater than their credit limit.
with query1 as (select u.user_id,u.full_name,a.credit_limit,t.txn_id,t.amount
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id=a.account_id
)
select user_id,full_name,count(txn_id)
from query1
where amount>credit_limit
group by user_id,full_name
order by count(txn_id);

#4. For each user who took loan calculate: total amount,amount_repaid and repayment_completion_rate= amount_repaid/principal
with query2 as (select u.user_id,u.full_name,l.principal,r.amount_paid
from users as u
inner join loans as l on l.user_id=u.user_id
inner join repayments as r on r.loan_id=l.loan_id)

select user_id, full_name,sum(principal) as total_amount , sum(amount_paid) as amount_paid,
sum(amount_paid)/sum(principal) as repayment_completeion_rate
from query2
group by user_id,full_name
order by sum(amount_paid);

#5. Identify users who have made 5 or more failed transactions within a single day.
with query3 as (select u.user_id,u.full_name,t.txn_id
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id=a.account_id
where t.status="Failed")
select user_id,full_name,count(txn_id) as failed_payment
from query3
group by user_id,full_name
having count(txn_id)>5
order by count(txn_id) desc;

#6.Find users who have made transactions above the average transaction amount.
with cte as (select u.user_id,u.full_name,t.amount
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id=a.account_id
)
select user_id, full_name
from cte
where amount>(select avg(amount) from transactions);

#7.Find all users who have never made even one failed transaction.
SELECT full_name
FROM users
WHERE user_id NOT IN (
    SELECT a.user_id
    FROM accounts a
    JOIN transactions t ON t.account_id = a.account_id
    WHERE t.status = 'Failed'
);

#8. Get a list of all latest successfull transactiosn of all users
SELECT u.user_id, u.full_name, t.amount, t.txn_time
FROM users u
INNER JOIN accounts a ON a.user_id = u.user_id
INNER JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'Success'
AND t.txn_time = (
    SELECT MAX(t2.txn_time)
    FROM accounts a2
    JOIN transactions t2 ON t2.account_id = a2.account_id
    WHERE a2.user_id = u.user_id AND t2.status = 'Success'
);

#9.Find all users who have made at least one transaction higher than their own average transaction amount.
select u.user_id,u.full_name,t.amount
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id =a.account_id
where t.status="Success"
AND t.amount>(Select avg(t2.amount)
from accounts as a2
inner join transactions as t2 on t2.account_id=a2.account_id
where a2.user_id=u.user_id);

#10."Find the top 3 users (by name and ID) who have spent the most above their own average transaction amount, and show the breakdown of those high-value transactions by transaction type (e.g., UPI, Wallet, etc.)."
WITH high_value_txns AS (
    SELECT 
        u.user_id,
        u.full_name,
        t.txn_type,
        t.amount
    FROM users u
    JOIN accounts a ON a.user_id = u.user_id
    JOIN transactions t ON t.account_id = a.account_id
    WHERE t.status = 'Success'
      AND t.amount > (
          SELECT AVG(t2.amount)
          FROM accounts a2
          JOIN transactions t2 ON t2.account_id = a2.account_id
          WHERE a2.user_id = u.user_id
      )
),
user_total_high_spend AS (
    SELECT 
        user_id,
        full_name,
        SUM(amount) AS total_high_value_spent
    FROM high_value_txns
    GROUP BY user_id, full_name
    ORDER BY total_high_value_spent DESC
    LIMIT 3
)

SELECT 
    h.user_id,
    h.full_name,
    h.txn_type,
    COUNT(*) AS total_high_value_txns,
    SUM(h.amount) AS total_high_value_spent
FROM high_value_txns h
JOIN user_total_high_spend u ON u.user_id = h.user_id
GROUP BY h.user_id, h.full_name, h.txn_type
ORDER BY total_high_value_spent DESC;
