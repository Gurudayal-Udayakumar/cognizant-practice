-- =======================
-- Exercise 1: Control Structures
-- =======================

-- Create bank_customer table
CREATE TABLE bank_customer (
  cust_id       NUMBER PRIMARY KEY,
  full_name     VARCHAR2(100),
  years_old     NUMBER,
  curr_balance  NUMBER(12,2),
  vip_status    VARCHAR2(5) DEFAULT 'FALSE'
);

-- Create customer_loan table
CREATE TABLE customer_loan (
  loan_no   NUMBER PRIMARY KEY,
  cust_id   NUMBER NOT NULL,
  rate      NUMBER(5,2),
  due_on    DATE,
  CONSTRAINT fk_loan_customer FOREIGN KEY (cust_id)
    REFERENCES bank_customer(cust_id)
);

-- Insert sample data into bank_customer
INSERT INTO bank_customer VALUES (1, 'Arun', 67, 9000, 'FALSE');
INSERT INTO bank_customer VALUES (2, 'Bina', 58, 13000, 'FALSE');
INSERT INTO bank_customer VALUES (3, 'Chitra', 73, 16000, 'FALSE');
COMMIT;

-- Insert sample data into customer_loan
INSERT INTO customer_loan VALUES (1001, 1, 8.75, SYSDATE + 12);
INSERT INTO customer_loan VALUES (1002, 2, 9.20, SYSDATE + 45);
INSERT INTO customer_loan VALUES (1003, 3, 10.10, SYSDATE + 25);
COMMIT;

-- Scenario 1: Interest discount for senior citizens
BEGIN
  FOR rec IN (
    SELECT loan_no, rate
    FROM customer_loan l
    JOIN bank_customer c ON l.cust_id = c.cust_id
    WHERE c.years_old > 60
  )
  LOOP
    UPDATE customer_loan
    SET rate = rec.rate - 1
    WHERE loan_no = rec.loan_no;
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Interest discount given to senior clients.');
END;
/

-- Scenario 2: Mark customers as VIP based on balance
BEGIN
  FOR rec IN (
    SELECT cust_id
    FROM bank_customer
    WHERE curr_balance > 10000
  )
  LOOP
    UPDATE bank_customer
    SET vip_status = 'TRUE'
    WHERE cust_id = rec.cust_id;
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('High-value customers marked as VIP.');
END;
/

-- Scenario 3: Loan reminders for loans due in next 30 days
BEGIN
  FOR rec IN (
    SELECT loan_no, cust_id, due_on
    FROM customer_loan
    WHERE due_on BETWEEN SYSDATE AND SYSDATE + 30
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE('Loan #' || rec.loan_no || ' for customer ' || rec.cust_id ||
                         ' is due on ' || TO_CHAR(rec.due_on, 'DD-MON-YYYY'));
  END LOOP;
END;
/
