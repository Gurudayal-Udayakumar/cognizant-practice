-- =======================
-- Exercise 2: Error Handling
-- =======================

-- Create user_account table
CREATE TABLE user_account (
  acc_id       NUMBER PRIMARY KEY,
  acc_balance  NUMBER(12,2)
);

-- Create staff_member table
CREATE TABLE staff_member (
  staff_id        NUMBER PRIMARY KEY,
  staff_name      VARCHAR2(100),
  monthly_salary  NUMBER(12,2)
);

-- Create bank_customer table (same structure as Exercise 1 if not reused)
CREATE TABLE bank_customer (
  cust_id       NUMBER PRIMARY KEY,
  full_name     VARCHAR2(100),
  years_old     NUMBER,
  curr_balance  NUMBER(12,2),
  vip_status    VARCHAR2(5) DEFAULT 'FALSE'
);

-- Insert sample data
INSERT INTO user_account VALUES (5001, 1200);
INSERT INTO user_account VALUES (5002, 300);

INSERT INTO staff_member VALUES (301, 'Prakash', 42000);
INSERT INTO staff_member VALUES (302, 'Suman', 36000);

INSERT INTO bank_customer VALUES (1, 'Arun', 67, 9000, 'FALSE');
INSERT INTO bank_customer VALUES (2, 'Bina', 58, 13000, 'FALSE');
COMMIT;

-- Scenario 1: Safe Fund Transfer with error handling
CREATE OR REPLACE PROCEDURE TransferSecure (
  sender_id IN NUMBER,
  receiver_id IN NUMBER,
  amount IN NUMBER
)
IS
  sender_balance NUMBER;
BEGIN
  SELECT acc_balance INTO sender_balance
  FROM user_account
  WHERE acc_id = sender_id
  FOR UPDATE;

  IF sender_balance < amount THEN
    RAISE_APPLICATION_ERROR(-20001, 'Not enough funds');
  END IF;

  UPDATE user_account SET acc_balance = acc_balance - amount WHERE acc_id = sender_id;
  UPDATE user_account SET acc_balance = acc_balance + amount WHERE acc_id = receiver_id;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Transfer failed: ' || SQLERRM);
END;
/

-- Scenario 2: Update salary with exception for missing employee
CREATE OR REPLACE PROCEDURE BoostSalary (
  sid IN NUMBER,
  bonus_pct IN NUMBER
)
IS
BEGIN
  UPDATE staff_member
  SET monthly_salary = monthly_salary + (monthly_salary * bonus_pct / 100)
  WHERE staff_id = sid;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'No such staff found');
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Salary update error: ' || SQLERRM);
END;
/

-- Scenario 3: Add new customer with duplicate ID check
CREATE OR REPLACE PROCEDURE RegisterCustomer (
  cid IN NUMBER,
  cname IN VARCHAR2,
  cage IN NUMBER
)
IS
BEGIN
  INSERT INTO bank_customer (cust_id, full_name, years_old)
  VALUES (cid, cname, cage);
  COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Customer already exists');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Registration failed: ' || SQLERRM);
END;
/

-- Test Cases
BEGIN
  TransferSecure(5001, 5002, 500);
END;
/

BEGIN
  TransferSecure(5002, 5001, 1000);
END;
/

BEGIN
  BoostSalary(301, 10);
END;
/

BEGIN
  BoostSalary(999, 15);
END;
/

BEGIN
  RegisterCustomer(4, 'Devika', 28);
END;
/

BEGIN
  RegisterCustomer(1, 'Duplicate Arun', 67);
END;
/
