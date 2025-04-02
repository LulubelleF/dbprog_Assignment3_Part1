DECLARE
    -- Outer cursor to fetch distinct transaction numbers
    CURSOR trans_cursor IS
        SELECT DISTINCT transaction_no FROM NEW_TRANSACTIONS;
    
    -- Inner cursor to fetch transaction-level data for a specific transaction number
    CURSOR trans_details_cursor(p_transaction_number NEW_TRANSACTIONS.transaction_no%TYPE) IS
        SELECT transaction_date, description
        FROM NEW_TRANSACTIONS
        WHERE transaction_no = p_transaction_number;

BEGIN 
    -- Outer loop: Loop through each distinct transaction number
    FOR trans_rec IN trans_cursor LOOP
        -- Inner loop: Loop through each row for the current transaction number
        FOR trans_details_rec IN trans_details_cursor(trans_rec.transaction_no) LOOP
            -- Insert summary row into TRANSACTION_HISTORY
            INSERT INTO transaction_history (
                transaction_no, transaction_date, description
            ) VALUES (
                trans_rec.transaction_no,
                trans_details_rec.transaction_date,
                trans_details_rec.description
            );

        -- Delete processed rows from NEW_TRANSACTIONS 
        DELETE FROM new_transactions
        WHERE transaction_no = trans_rec.transaction_no;

        END LOOP;
    
    COMMIT;
    
END;
/
        
        
    
    