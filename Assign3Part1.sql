DECLARE
    
    -- Outer cursor
    CURSOR trans_cursor IS
    
    
    -- Inner cursor
    


BEGIN 
    -- loop
    For 
    
    
        -- nested loop
        For
        
        
        End Loop;
        
        
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
        
        
    
    