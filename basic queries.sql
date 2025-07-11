use fintech;
show tables;

#1. display total users
select count(user_id) as total_users from users;

#2. which cities have highest number of users
select count(user_id),city from users 
group by city
order by count(user_id) desc;

#3. How many unique merchants are there in all transactions?
select distinct(merchant) from transactions;

#4.  Count how many loans were given of each loan type.
select count(loan_id) as count_per_type , loan_type from loans
group by loan_type
order by count(loan_id) desc;

#5. How many transactions failed?
select count(txn_id) from transactions
where status="Failed";

