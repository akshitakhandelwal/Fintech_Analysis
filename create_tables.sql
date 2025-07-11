use fintech;
#users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    kyc_status ENUM('Verified', 'Pending', 'Rejected'),
    signup_date DATE,
    city VARCHAR(50),
    annual_income INT,
    dob DATE
);
#accounts
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    wallet_balance DECIMAL(10,2),
    credit_limit DECIMAL(10,2),
    created_on DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- 3. TRANSACTIONS
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    txn_type ENUM('UPI', 'Wallet', 'Credit', 'BNPL', 'Refund'),
    amount DECIMAL(10,2),
    txn_time DATETIME,
    merchant VARCHAR(100),
    status ENUM('Success', 'Failed', 'Reversed'),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 4. LOANS
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    loan_type ENUM('BNPL', 'InstantCredit', 'Personal'),
    principal DECIMAL(10,2),
    start_date DATE,
    tenure_months INT,
    interest_rate DECIMAL(4,2),
    status ENUM('Active', 'Closed', 'Defaulted'),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- 5. REPAYMENTS
CREATE TABLE repayments (
    repayment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT,
    due_date DATE,
    paid_on DATE,
    amount_paid DECIMAL(10,2),
    status ENUM('Paid', 'Late', 'Missed'),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- 6. CREDIT SCORES
CREATE TABLE credit_scores (
    score_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    score INT,
    reported_on DATE,
    source ENUM('Experian', 'CIBIL', 'InternalAI'),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 7. FRAUD FLAGS
CREATE TABLE fraud_flags (
    flag_id INT AUTO_INCREMENT PRIMARY KEY,
    txn_id INT,
    reason VARCHAR(255),
    flagged_on DATETIME,
    resolved BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (txn_id) REFERENCES transactions(txn_id)
);


