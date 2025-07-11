use fintech;
select * from repayments;
#1.Find the total transaction amount per user across all their accounts (Success only).

#1.Find the total transaction amount per user across all their accounts (Success only).
WITH a AS (
    SELECT u.user_id, u.full_name, t.amount 
    FROM users AS u
    INNER JOIN accounts AS acc ON acc.user_id = u.user_id
    INNER JOIN transactions AS t ON t.account_id = acc.account_id
    WHERE t.status = "Success"
)
SELECT user_id, full_name, SUM(amount) AS total_amount
FROM a
GROUP BY user_id, full_name
ORDER BY total_amount DESC;

#2. How many loans were disbursed each month?
select count(loan_id) as total_loans, date_format(start_date,'%Y-%M') as disbursed_month from loans
group by disbursed_month
order by total_loans desc;

#3.Write a query to get the top 5 users with the highest wallet balances.
select u.user_id,u.full_name,a.balance
from users as u
inner join accounts as a on a.user_id=u.user_id;

#4. Users with more than 2 late repayments
with repayment as (select u.user_id, u.full_name,r.repayment_id
from users u
inner join loans as l on u.user_id=l.user_id
inner join repayments as r on r.loan_id=l.loan_id 
where r.status="Late")

select user_id,full_name, count(repayment_id) as total_repayment
from repayment
group by user_id,full_name
having count(repayment_id)>2
order by count(repayment_id);

#5.  For each user calculate their average credit score
with credit as (select u.user_id,u.full_name,c.score
from users as u
inner join credit_scores as c on c.user_id=u.user_id)

select user_id,full_name,avg(score) as average_credit_score
from credit
group by user_id,full_name
order by avg(score);

#6. List the names and income of users who have at least one loan with a status = 'Default'.
with loan as (select u.full_name,u.annual_income,l.loan_id
from users as u
inner join loans as l on l.user_id=u.user_id
where l.status="Default")

select full_name,annual_income,count(loan_id) as total_loans
from loan
group by full_name,annual_income
order by count(loan_id);

#7. For each user, calculate their wallet usage ratio, defined as: wallet_usage_ratio = (Total amount of wallet transactions) / (wallet_balance)
with wallet_balance as (select u.user_id, u.full_name,t.txn_id,a.wallet_balance,t.amount
from users as u
inner join accounts as a on a.user_id=u.user_id
inner join transactions as t on t.account_id=a.account_id
where t.txn_type="Wallet")

select user_id,full_name, (sum(amount)/(wallet_balance)) as wallet_usage_ratio
from wallet_balance
group by user_id,full_name,wallet_balance
order by (sum(amount)/(wallet_balance)) desc;

#8. Compare total spending per transaction type (UPI, Credit, BNPL) and display the totals side-by-side.
#solution one: using groupby
select txn_type as type, sum(amount)
from transactions
group by txn_type
having txn_type in ("UPI","Credit","BNPL")
order by sum(amount) desc;
#solution 2: using case statements
SELECT
    SUM(CASE WHEN txn_type = 'UPI' THEN amount ELSE 0 END) AS upi_total,
    SUM(CASE WHEN txn_type = 'Credit' THEN amount ELSE 0 END) AS credit_total,
    SUM(CASE WHEN txn_type = 'BNPL' THEN amount ELSE 0 END) AS bnpl_total
FROM transactions;

#9. top 10 failed transactions where amount was greater than 20k
select txn_id from transactions
where status="Failed" and amount>20000
order by amount desc
limit 10;

#10. for every user display total_loan amount and how much have they repaid and how much is left
with loan_repayment as (select u.user_id, u.full_name,l.principal,l.interest_rate,l.tenure_months,r.amount_paid
from users as u
inner join loans as l on l.user_id=u.user_id
inner join repayments as r on r.loan_id=l.loan_id)

select user_id,full_name, sum(principal) as total_loan_amount, sum(amount_paid), 
sum(principal)-sum(amount_paid)as amount_left
from loan_repayment
group by user_id,full_name
order by total_loan_amount desc;
