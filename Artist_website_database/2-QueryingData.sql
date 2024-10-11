USE artist_website;

-- MAIN QUERIES 
-- SPROC to output some useful table showing statistics which are useful for the artists to know who is their best customer 
-- and which paintings are the most well recieved

-- The next SPROC simulates an order being placed 
-- The user can place an order once they have chosen what artpiece they want - selecting by art type or whatever they wish

-- Finally a view is created which selects important information for when a user wants to browse available artwork
----
-- Used the aggregate functions Avg() and Sum() 
-- Used inbuilt functions CONCAT() and CURDATE()
-- Ordered queries in the sproc stats() appropriately with ORDER BY

----
-- Printing out useful statistics about our current customers and his most popular art work 

DELIMITER // 

CREATE PROCEDURE stats()
BEGIN 
	# how many paintings each customer has bought
	SELECT * FROM (
		SELECT Customer_ID, c.username, Business_Acc, SUM(copies) total_copies_bought
			FROM orders o
			JOIN customers c
			ON c.CustomerID = o.Customer_ID 
		GROUP BY Customer_ID
		ORDER BY total_copies_bought DESC) 
	AS Customer_stats;

	# How much each customer has spent 

	SELECT * FROM(
		SELECT o.Customer_ID, c.username,  SUM((o.copies * a.Price_£)) Total_Revenue
			FROM orders o
			JOIN customers c
			ON c.CustomerID = o.Customer_ID
			JOIN art_stock a
			ON a.sale_id = o.sale_id
		GROUP BY o.Customer_ID
		ORDER BY Total_Revenue DESC)
	AS Customer_Revenue;

	# average revenue per customer
	SELECT AVG(Total_Revenue) Average_Revenue_Per_Customer FROM(
		SELECT SUM((o.copies * a.Price_£)) Total_Revenue
				FROM orders o
				JOIN customers c
				ON c.CustomerID = o.Customer_ID
				JOIN art_stock a
				ON a.sale_id = o.sale_id
				GROUP BY o.Customer_ID)
	AS Avg_Customer_Revenue;

	# most bought painting - link orders and art stock - group by art_id
	SELECT * FROM (
		SELECT a.Art_ID, ap.Name, SUM(Copies) Copies_Sold
			FROM art_stock a
			JOIN orders o
			ON o.sale_ID = a.sale_ID 
			JOIN art_pieces ap
			ON ap.art_id = a.art_ID
		GROUP BY a.Art_ID
		ORDER BY Copies_Sold DESC)
	AS Copies_Sold_ArtPiece;

END //

DELIMITER ; 

CALL stats();

-- Simulating a new sale using transaction! We either want all changes to take place or none
	-- Transaction is recorded on orders table
	-- use the inbuilt function curdate() to get the date of the transaction
    -- Stock of the item should go down in the art_stock table 
    -- If the stock goes below 0 this means item is out of stock and we must ROLLBACK
    -- The user must input their customer_ID, the number of copies they want, and the sale ID of the art when calling the sproc
    

-- DROP procedure Selling_transaction;
SET DELIMITER //

CREATE PROCEDURE Selling_Transaction (IN Customer_ID INT, IN No_of_Copies INT, IN Sale_ID_input INT)
BEGIN
	START TRANSACTION;
    
		-- building a select statement telling you which painting you are buying 
		SET @ArtName  = (SELECT Name FROM Art_pieces WHERE Art_Id IN 
						(SELECT Art_ID FROM Art_Stock WHERE Sale_ID = Sale_ID_input));
        
        SET @Print = (SELECT Print FROM Art_Stock WHERE Sale_ID = Sale_ID_input);
        IF @Print = 1 
			THEN SET @PrintOutput = 'prints';
        ELSE 
			SET @PrintOutput = 'the original artwork';
        END IF;
        
		SELECT(CONCAT("You are now buying ", No_of_Copies , " copy(ies) of the painting '", @ArtName, "' as ", @PrintOutput));
    
		-- Recording the transaction
		INSERT INTO orders
		(Order_time, Customer_ID, Copies, Sale_ID )
		VALUES
		(CURDATE(), Customer_ID, No_of_Copies, Sale_ID_input);
		
		-- Stock should go down from the inputted sale_id
		UPDATE art_stock
		SET
		Stock = Stock - No_of_Copies
		WHERE Sale_ID = Sale_ID_input;
        
        SET @temp_stock = (SELECT Stock from art_stock WHERE Sale_ID = Sale_ID_input);
        IF @temp_stock < 0 THEN
			SELECT('Transaction Failed - No stock left of piece');
            ROLLBACK;
		ELSE 
			COMMIT;
		END IF;
END //

DELIMITER ;


-- Finally creating a view for customers to browse the available art pieces

CREATE VIEW customer_browse_portal AS

	SELECT a.Sale_ID, ap.Name Listing, ap.Art_Style, ar.Name Artist, ap.Release_Date, a.print, a.Stock, a.Price_£ 
	FROM art_stock a 
		JOIN Art_Pieces ap 
		ON ap.Art_ID = a.Art_ID
        JOIN artists ar
        ON ap.Artist_ID = ar.Artist_ID
		WHERE a.Stock != 0
        ORDER BY print
        
WITH CHECK OPTION;

SELECT * FROM customer_browse_portal;