
DECLARE
    -- Outer cursor to fetch distinct transaction numbers
    CURSOR trans_cursor IS
        SELECT DISTINCT TRANSACTION_NUMBER
        FROM NEW_TRANSACTIONS;
    
    -- Inner cursor to fetch transaction-level data for a specific transaction number
    CURSOR trans_details_cursor(p_transaction_number NEW_TRANSACTIONS.TRANSACTION_NUMBER%TYPE) IS
        SELECT TRANSACTION_DATE, DESCRIPTION
        FROM NEW_TRANSACTIONS
        WHERE TRANSACTION_NUMBER = p_transaction_number;

BEGIN 
    -- Outer loop: Loop through each distinct transaction number
    FOR trans_rec IN trans_cursor LOOP
        -- Inner loop: Loop through each row for the current transaction number
        FOR trans_details_rec IN trans_details_cursor(trans_rec.TRANSACTION_NUMBER) LOOP
            
        -- Insert summary row into TRANSACTION_HISTORY
        INSERT INTO transaction_history (
            transaction_no, transaction_date, description
        ) VALUES (
            trans_rec.transaction_no,
            trans_rec.transaction_date,
            trans_rec.description
        );

        -- Delete processed rows from NEW_TRANSACTIONS
        DELETE FROM new_transactions
        WHERE transaction_no = trans_rec.transaction_no;

    End Loop;
    
    COMMIT;
    
END;
/
        
        
    
    