-- A new business is planning to bulk buy some prints for resale I am the CEO of this business. 
-- I will also buy an original art piece for my home
-- First I will create a customer business account 

INSERT INTO Customers
(Username, Email, Business_Acc)
VALUES
('artworks_srishty', 'artworks.saj@gmail.com', 1);

-- Now I will Browse the selection of available original artworks for myself
-- I would like one of a city and so I will try searching in the name 
SELECT *
FROM customer_browse_portal
WHERE print = 0 and Listing like '%city%';

-- I will buy the one result that comes up which has a sale ID of 60
-- Selling_Transaction (Customer_ID , IN No_of_Copies INT, IN Sale_ID_input INT)

SET @Srishty_ID = (SELECT CustomerID FROM Customers WHERE username = 'artworks_srishty');
CALL Selling_Transaction (@Srishty_ID, 1, 60); -- EDIT this for a new transaction

-- Checking if transaction has taken place 
SELECT * FROM art_stock; 
SELECT * FROM orders;
-- test passed - and it you run above again it rollsback as expected as there is only 1 of the piece left

-- I want to now bulk buy some abstract prints painted by Nadeem 
-- but I only want paintings that are released after July 2023 
-- And are priced below £2000
SELECT *
FROM customer_browse_portal
    WHERE Artist LIKE 'Nadeem%' 
    and Art_Style LIKE 'Abstract'
    and print = 1 
    and Release_Date > '2023-07-31' 
    and Price_£ < 2000;
    
-- I will buy 10 copies of Liar and 10 copies of But Why?
CALL Selling_Transaction (@Srishty_ID, 10, 51);
CALL Selling_Transaction (@Srishty_ID, 10, 91);

SELECT * FROM art_stock; 

-- I will now try buying 11 more copies of Liar to show that the transaction fails (as this is more than the stock)
CALL Selling_Transaction (@Srishty_ID, 11, 51);
SELECT * FROM art_stock; 

-- Lets take a look at the new stats after my purchase
-- CALL stats();
------------------------------------------------------------------------------------------

-- Sacho accidentally dropped the painting 'Lovers and Betrayal'
-- The prints have already been made and so only the original artwork needs to be deleted from the table art_stock
-- Luckily noone has bought this piece yet

DELETE FROM Art_Stock
WHERE art_ID IN
	(SELECT Art_ID FROM art_pieces 
	WHERE Name LIKE 'Lovers and Betrayal')
    AND 
    print = 0;

#SALE_ID 70 should be gone 
SELECT * FROM art_stock;