declare
    -- Outer cursor to fetch distinct transaction numbers
   cursor trans_cursor is
   select distinct transaction_no
     from new_transactions;
    
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

begin 
    -- Outer loop: Loop through each distinct transaction number
   for trans_rec in trans_cursor loop
        -- Inner loop: Loop through each row for the current transaction number
      for trans_details_rec in trans_details_cursor(trans_rec.transaction_no) loop

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

      end loop; -- inserted 04012025 Bhel
        
        -- Insert into TRANSACTION_HISTORY
      insert into transaction_history (
         transaction_no,
         transaction_date,
         description
      ) values ( trans_rec.transaction_no,
                 trans_details_rec.transaction_date,
                 trans_details_rec.description );


        -- Delete processed rows from NEW_TRANSACTIONS 
      delete from new_transactions
       where transaction_no = trans_rec.transaction_no;

   end loop;

   commit;
end;
/