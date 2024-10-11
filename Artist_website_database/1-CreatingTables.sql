# SCENARIO
-- There are 2 artists that sometimes work collaboratively and I wish to make a website for both of them to sell their work
-- One is called Nadeem, the other is called Sacho and when they make a piece together they go by the alias Nacho!
-- The artists either collaborate on a piece or they output their indivudual work 
-- There is a table of the artists and one for the artwork they have produced along with the dates  
-- Whenever an art piece is sold either the original is sold (only ever one copy of this) or prints of the artwork is sold (multiple copies)
-- The prints are priced at 60% of the original piece
-- Users can search by art type and price

---
-- Used appropriate datatypes for columns 
-- Used AutoIncrement for most of the the ID's 
-- Made use of NOT NULL (such as IDs) and UNIQUE (such as for Usernames) 
-- Every table has a primary key and a foreign key (see DatabaseSchematic.png)
----------------------------------------------------------------------------------------------------------------------------------------

-- DROP database artist_website;
CREATE DATABASE artist_website; 
USE artist_website; 
---
-- Creating a table of the artists
CREATE TABLE Artists
	(Artist_ID INT NOT NULL PRIMARY KEY, Name VARCHAR(30) NOT NULL); 

INSERT INTO Artists
	(Artist_ID, Name)
VALUES 
	(1, "Nadeem Banka"),
    (2, "Sacho Samson"),
    (12, "Nacho");
--- 

-- Creating a table of the art pieces that have been created for sale
CREATE TABLE Art_pieces
	(Art_ID INT NOT NULL AUTO_INCREMENT, Name VARCHAR(100) UNIQUE, Art_Style VARCHAR(50), Artist_ID INT NOT NULL, Release_Date DATE,
    PRIMARY KEY (Art_ID),
    FOREIGN KEY (Artist_ID) REFERENCES Artists(Artist_ID) );
    
INSERT INTO Art_pieces
	(Name, Art_Style, Artist_ID)
VALUES 
	("Thoughts", "Abstract" , 1),
    ("Flowing River", "Realism", 2),
    ("Kerela Houseboat", "Realism", 2),
    ("Bhuta", "Post-Impressionism", 2), 
    ("Liar", "Abstract", 1), 
    ("New York City", "Cubism", 12), 
    ("Lovers and Betrayal", "Abstract", 12),
    ("Sleep Tight", "Minimalism", 12 ), 
    ("But Why?", "Abstract", 1);
    
-- SELECT * FROM art_pieces;

---

-- Creating table for the stock of art peices (includes prints and non-prints). 
-- Sale ID (PK) takes the art_ID and adds a 0 at the end if it's the original work and a 1 if it is a print
-- Made use of views to update the columns

CREATE Table Art_stock 
	(Sale_ID INT, Art_ID INT NOT NULL,  Print BOOLEAN , Stock INT, Release_Date DATE, Price_£ FLOAT,
    FOREIGN KEY (Art_ID) REFERENCES Art_pieces(Art_ID) );
-- need to update the constraints of sale ID after 

INSERT INTO Art_Stock
	(Art_ID, Print, Stock, Release_Date, Price_£ )
VALUES
	(1, 0, 0, '2023-01-01', 600),
    (1, 1, 1, '2023-02-01', 200),
    (2, 0, 0, '2023-04-03', 2000),
    (2, 1, 10, '2023-05-03', 1200), 
    (3, 0, 0, '2023-06-03', 2000), 
    (3, 1, 3,'2023-07-03', 1500), 
    (4, 0, 1, '2023-07-01', 600), 
    (4, 1, 20, '2023-08-01', 500), 
    (5, 0, 1, '2023-08-01', 3000), 
    (5, 1, 20, '2023-09-01', 1000), 
    (6, 0, 1, '2023-10-01', 3000), 
    (6, 1, 20, '2023-11-01', 1000), 
    (7, 0, 1,'2024-01-01', 6000 ),
    (7, 1, 20, '2024-02-01', 2000 ),
    (8, 0, 1, '2024-02-01', 8000 ), 
    (8, 1, 20, '2024-03-01', 2000), 
    (9, 0, 1, '2024-05-01', 2000), 
    (9, 1, 20, '2024-06-01', 500);

-- Updating the Sale_ID column and changing it's constraints so it is now a primary key
 
	UPDATE Art_Stock a
	SET a.Sale_ID = CONCAT(Art_ID, Print);

	ALTER TABLE Art_Stock 
	MODIFY COLUMN Sale_ID INT NOT NULL PRIMARY KEY;

-- Realized that the release date is more associated with the art pieces rather than stock 
-- So moving the column from art_stock to art_pieces to ensure the tables are normalised:

	UPDATE art_pieces p
	JOIN art_stock s
	ON 
	p.art_ID = s.art_ID
	SET p.Release_Date = s.Release_Date;

	ALTER TABLE art_stock
	DROP Release_Date;

-- Creating views for the print/non prints from the stock table and using this to 
-- update the price of the prints so that they are always 60% of the original price. 

	CREATE VIEW art_stock_print
	AS 
	SELECT Sale_ID, Art_ID, Stock, Price_£ 
	FROM art_stock
	WHERE print = 1
	WITH CHECK OPTION;
		
	CREATE VIEW art_stock_not_print
	AS 
	SELECT Sale_ID, Art_ID, Stock, Price_£ 
	FROM art_stock
	WHERE print = 0
	WITH CHECK OPTION;

-- SELECT * FROM art_stock_print;
-- SELECT * FROM art_stock_not_print;

	UPDATE art_stock_print p
	JOIN art_stock_not_print np
	ON np.Art_ID = p.Art_ID
	SET p.Price_£ = np.Price_£ * 0.6;

-- SELECT * FROM art_stock_print;
-- SELECT * FROM art_stock_not_print;

---
-- Creating a table for the customers
-- Might introduce a discount for businesses that bulk buy prints

CREATE TABLE Customers
	(CustomerID INT NOT NULL AUTO_INCREMENT, Username VARCHAR(50) UNIQUE, Email VARCHAR(200), Business_Acc Boolean, 
    PRIMARY KEY (CustomerID));
    
INSERT INTO Customers
(Username, Email, Business_Acc)
VALUES
('CoolCats', 'emily.l@gmail.com', 0), 
('HarryStyles', 'harrystyles@gmail.com', 0), 
('Lola', 'll@gmail.com', 0), 
('Sam566', 'sam2020@gmail.com', 0),
('ArtStudioLabs', 'artstudiolabs.ltd.com' , 1);

-- SELECT * FROM Customers;

---

-- Creating a table for the orders and populating with mock orders taking care to make sure they match with previous data I've inputted into the stock. 

CREATE TABLE Orders
	(Order_ID INT NOT NULL AUTO_INCREMENT , Order_time DATE NOT NULL, Customer_ID INT NOT NULL, Copies INT, Sale_ID INT NOT NULL, 
    PRIMARY KEY (Order_ID),
	FOREIGN KEY (Customer_ID) REFERENCES Customers(CustomerID), 
	FOREIGN KEY (Sale_ID) REFERENCES Art_stock(Sale_ID));
    
    INSERT INTO Orders 
    (Order_time, Customer_ID, Copies, Sale_ID )
    VALUES 
    ('2023-01-29', 1, 1, 10), 
    ('2023-02-01', 5, 19, 11), 
    ('2023-04-20', 2, 1, 20), 
    ('2023-04-20', 3, 1, 21),
    ('2023-06-09', 1, 2 ,21),
    ('2023-06-15', 4, 1, 30), 
    ('2023-07-15', 5, 7, 21),
    ('2023-10-15', 5, 10, 31), 
    ('2023-10-15', 1, 6, 31), 
    ('2023-10-20', 3, 1, 31);
    
    SELECT * FROM artists;
    SELECT * FROM orders;
    SELECT * FROM art_stock;
    SELECT * FROM art_pieces;
    SELECT * FROM customers;



