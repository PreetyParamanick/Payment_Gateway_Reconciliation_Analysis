															-- Payment Gateway Data Analysis --
																-- By Preety Paramanick --

-- Creating a Database --
Create database payment_gateway;

-- Choosing the database --
use payment_gateway;

																	-- OBJECTIVE NO.1 --
-- Find Duplicate Records in each Dataset --
-- Find Duplicate in Siply --
SELECT Customer_id,COUNT(DISTINCT goal_id)
FROM siply
GROUP BY Customer_id
HAVING COUNT(DISTINCT goal_id) > 1;

-- Find Duplicate Cashfree --
SELECT order_id,COUNT(DISTINCT bank_reference_no)
FROM Cashfree
GROUP BY 1
HAVING COUNT(DISTINCT bank_reference_no) > 1;

-- Find Duplicate in Collection --
SELECT bank_ref_no, COUNT(DISTINCT bank_ref_no)
FROM Collection
GROUP BY 1
HAVING COUNT(DISTINCT bank_ref_no) > 1;

                                                                  -- OBJECTINE NO.2 --
-- Find Matching Records Between All Three Datasets by Tracking Payment --
-- Creating Index for fast fetching dada --
CREATE INDEX idx_co_goal_id ON Collection(goal_id);
CREATE INDEX idx_siply_goal_id ON Siply(goal_id);
CREATE INDEX idx_cashfree_payment_mode ON Cashfree(payment_mode);
-- Query to find Mtching records --
SELECT co.Goal_ID,c.bank_ref_no,co.Trxns_date, co.Amount, co.Payment_mode,co.Txn_status,Installment,Trxns_type
FROM Collection co  
JOIN Siply s ON co.goal_id = s.goal_id
JOIN Cashfree c ON s.payment_mode = c.payment_mode
where co.payment_mode="UPI" ;               

                                                                   -- OBJECTIVE NO.3 --   
                                                                   
-- Prepare Summary of Matching/Unmatching Records and Amount --
-- Matching Records and Unmatching records --
SELECT 
    'Matching Records' AS Summary,
    COUNT(*) AS NumberOfRecords,
    SUM(C.amount) AS TotalAmount
FROM Cashfree C
JOIN Collection Co ON C.bank_ref_no= Co.bank_ref_no
JOIN Siply S ON C.Amount = S.Amount
UNION
SELECT 
    'Unmatching Records Cashfree1' AS Summary,
    COUNT(*) AS NumberOfRecords,
    SUM(C.amount) AS TotalAmount
FROM Cashfree C
LEFT JOIN Collection Co ON C.bank_ref_no = Co.bank_ref_no
LEFT JOIN Siply S ON C.payment_mode = S.payment_mode
WHERE Co.payment_mode IS NULL OR S.payment_mode IS NULL
UNION
SELECT 
    'Unmatching Records Collection1' AS Summary,
    COUNT(*) AS NumberOfRecords,
    SUM(Co.amount) AS TotalAmount
FROM Collection Co
LEFT JOIN Cashfree C ON Co.bank_ref_no = C.bank_ref_no
LEFT JOIN Siply S ON Co.payment_mode = S.payment_mode
WHERE C.payment_mode IS NULL OR S.payment_mode IS NULL
UNION
SELECT 
    'Unmatching Records Siply1' AS Summary,
    COUNT(*) AS NumberOfRecords,
    SUM(S.amount) AS TotalAmount
FROM Siply S
LEFT JOIN Cashfree C ON S.paymeny_mode= C.payment_mode
LEFT JOIN Collection Co ON S.goal_id = Co.goal_id
WHERE C.payment_mode IS NULL OR Co.payment_mode IS NULL;         

                                                                          -- OBJECTIVE NO.4 --
                                                                          
-- Identify Cases of Any Amount Mismatch --
-- Cashfree and Collection amount mismatch --
SELECT *
FROM Cashfree c
JOIN Collection co ON c.bank_ref_no = co.bank_ref_no
WHERE c.AMOUNT <> co.AMOUNT;

-- Siply and Collection amount mismatch --
SELECT *
FROM Siply s 
JOIN Collection co ON s.goal_id=c.goal_id
WHERE s.Amount<> co.Amount;

-- Siply and Cashfree amount match --
SELECT *
FROM Cashfree c 
JOIN Siply s ON c.payment_mode=s.payment_mode
WHERE c.Amount<>s.Amount;                                                                          
                                                                  