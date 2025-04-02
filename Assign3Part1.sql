/* 
Assignment 3 - Part 1: WKIS Transaction Processing
Group Members: Lulubelle, Gabriel, Mitzi, Nicole
Date: April 2025

Description:
- Processes transactions from NEW_TRANSACTIONS table
- Inserts each row into TRANSACTION_DETAIL
- Updates ACCOUNT balances based on default transaction type
- After processing all rows in a transaction:
    - Inserts summary into TRANSACTION_HISTORY
    - Deletes processed rows from NEW_TRANSACTIONS 

Follows all assignment restrictions:
- No SELECT INTO from NEW_TRANSACTIONS
- No use of arrays, GOTOs, stored procedures, or SAVEPOINTs
*/




declare
    -- Outer cursor to fetch distinct transaction numbers
      CURSOR trans_cursor IS
        SELECT DISTINCT transaction_no, transaction_date, description
        FROM new_transactions
        ORDER BY transaction_no;

    
    -- Inner cursor to fetch transaction-level data for a specific transaction number
   cursor trans_details_cursor (
      p_transaction_number new_transactions.transaction_no%type
   ) is
   select transaction_date,
          description,
          account_no,
          transaction_type,
          transaction_amount
     from new_transactions
    where transaction_no = p_transaction_number;

    -- Cursor to fetch default transaction type from ACCOUNT_TYPE
    cursor account_type_cursor (p_account_no account.account_no%type) is
    select at.default_trans_type
        from account a
        join account_type at on a.account_type_code = at.account_type_code
        where a.account_no = p_account_no;

    v_default_trans_type account_type.default_trans_type%type;
    v_transaction_date DATE;
    v_description VARCHAR2(100); 

begin 
    -- Outer loop: Loop through each distinct transaction number
   for trans_rec in trans_cursor loop
   
   -- Insert summary row into TRANSACTION_HISTORY
        INSERT INTO transaction_history (
            transaction_no, transaction_date, description
        ) VALUES (
            trans_rec.transaction_no,
            trans_rec.transaction_date,
            trans_rec.description
        );
   
        -- Inner loop: Loop through each row for the current transaction number
      for trans_details_rec in trans_details_cursor(trans_rec.transaction_no) loop
      
      
      
      v_transaction_date := trans_details_rec.transaction_date; 
      v_description := trans_details_rec.description; 
      
        -- Fetch the default transaction type
        open account_type_cursor(trans_details_rec.account_no);
        fetch account_type_cursor into v_default_trans_type;
        close account_type_cursor;
        
        -- Update ACCOUNT balance based on transaction type
        -- If default transaction type is 'D' (Debit Account)
        if v_default_trans_type = 'D' then
            -- Add amount if it's a Debit transaction
            if trans_details_rec.transaction_type = 'D' then
                update account
                set account_balance = account_balance + trans_details_rec.transaction_amount
                where account_no = trans_details_rec.account_no;
            else
             -- Subtract amount if it's a Credit transaction
                update account
                set account_balance = account_balance - trans_details_rec.transaction_amount
                where account_no = trans_details_rec.account_no;
            end if;
        else -- If default transaction type is 'C' (Credit Account)
            if trans_details_rec.transaction_type = 'D' then
            -- Subtract amount if it's a Debit transaction
                update account
                set account_balance = account_balance - trans_details_rec.transaction_amount
                where account_no = trans_details_rec.account_no;
            else
            -- Add amount if it's a Credit transaction
                update account
                set account_balance = account_balance + trans_details_rec.transaction_amount
                where account_no = trans_details_rec.account_no;
            end if;
        end if;
        
            -- Insert into TRANSACTION_DETAIL
         insert into transaction_detail (
            account_no,
            transaction_no,
            transaction_type,
            transaction_amount
         ) values ( trans_details_rec.account_no,
                    trans_rec.transaction_no,
                    trans_details_rec.transaction_type,
                    trans_details_rec.transaction_amount );

      end loop; 
        
    -- Delete processed rows from NEW_TRANSACTIONS 
      delete from new_transactions
       where transaction_no = trans_rec.transaction_no;

   end loop;

   commit;
end;
/