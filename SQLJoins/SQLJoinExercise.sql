USE bestbuy;

/* joins: select all the computers from the products table:
using the products table and the categories table, return the product name and the category name */

SELECT p.Name AS 'Product Name',
	   c.Name AS 'Category Name'
  FROM products p
  JOIN categories c
    ON p.CategoryID = c.CategoryID;
 

/* joins: find all product names, product prices, and products ratings that have a rating of 5 */
SELECT p.Name AS 'Product Name', 
	   p.Price AS 'Product Price', 
       r.Rating
  FROM products p
  JOIN reviews r
    ON p.ProductID = r.ProductID
 WHERE r.Rating = 5;
 
 
/* joins: find the employee with the most total quantity sold.  use the sum() function and group by */

SELECT a.EmployeeName, 
	   a.TotalQuantitySold        
  FROM (
		  SELECT concat (e.FirstName, ' ', e.LastName) AS 'EmployeeName', 
				 SUM(s.Quantity)  AS 'TotalQuantitySold',
				 dense_rank() OVER(ORDER BY SUM(s.Quantity) DESC) AS row_rank
		    FROM employees e
		    JOIN sales s
		      ON e.EmployeeID = s.EmployeeID
	    GROUP BY e.EmployeeID
       ) as a
 WHERE a.row_rank = 1;

/********************************************************************************************************/
/* BELOW IS FOR MY KNOWLEDGE ONLY
--------------------------------------------------------- 
-- USING 'COMMON TABLE EXPRESSION' and 'GROUP BY' CLAUSE
---------------------------------------------------------

WITH CTE_TotalQtyByEmployee 
  AS (
		 SELECT concat (e.FirstName, ' ', e.LastName) AS 'EmployeeName', 
			    SUM(s.Quantity)  AS 'TotalQuantitySold',
				dense_rank() OVER(ORDER BY SUM(s.Quantity) DESC) AS row_rank		-- 'ORDER BY' FOR dense_rank()
		   FROM employees e
		   JOIN sales s
			 ON e.EmployeeID = s.EmployeeID
	   GROUP BY e.EmployeeID 
	  )  SELECT EmployeeName, 
			    TotalQuantitySold 
		   FROM CTE_TotalQtyByEmployee 
		  WHERE row_rank = 1;

----------------------
-- WITHOUT 'GROUP BY'
----------------------

SELECT EmployeeName, 
	   TotalQuantitySold
  FROM (
			SELECT DISTINCT a.EmployeeName, 
							a.TotalQuantitySold, 
							dense_rank() OVER(ORDER BY a.TotalQuantitySold DESC) AS denserank		-- COULD NOT BE REFERRED DIRECTLY INTO THE QUERY ITSELF WITH "PARTITION BY", "ORDER BY" for dense_rank
					   FROM (	-- NO "GROUP BY" USED FOR SUMMARY, [GENERATES MULTIPLE (DUPLICATE) ROWS WITH  SAME 'TotalQuantitySold' FOR EVERY RECORD OF EMPLOYEE]
								SELECT concat (e.FirstName, ' ', e.LastName) AS 'EmployeeName',
									   SUM(s.Quantity) OVER (PARTITION BY s.EmployeeID) AS 'TotalQuantitySold'		-- "PARTITION BY" for dense_rank as NO 'GROUP BY'
								  FROM employees e
								  JOIN sales s
									ON e.EmployeeID = s.EmployeeID
							) AS a
		) AS b
 WHERE b.denserank = 1;
*/
/********************************************************************************************************/		


/* joins: find the name of the department, and the name of the category for Appliances and Games */

SELECT d.Name as 'Department Name',
	   c.Name as 'Category Name'
  FROM categories c
  JOIN departments d
    ON c.DepartmentID = d.DepartmentID
 WHERE c.Name IN ('Appliances', 'Games');

	
/* joins: find the product name, total # sold, and total price sold,
 for Eagles: Hotel California --You may need to use SUM() */

  SELECT p.Name AS 'Product Name',
	     SUM(s.Quantity) AS 'Total Sold',
         SUM(s.Quantity * s.PricePerUnit) AS 'Total Price Sold'
    FROM products p
    JOIN sales s
      ON p.ProductID = s.ProductID
   WHERE p.Name = 'Eagles: Hotel California'
GROUP BY p.ProductID;


/* joins: find Product name, reviewer name, rating, and comment on the Visio TV. (only return for the lowest rating!) */

WITH CTE_ProductReviews 
  AS (
		  SELECT p.Name AS 'ProductName',
				 r.Reviewer AS 'ReviewerName',
				 r.Rating,
				 r.Comment
			FROM products p
			JOIN reviews r
			  ON p.ProductID = r.ProductID
		   WHERE p.Name = 'Visio TV'
	 )    SELECT ProductName AS 'Product Name', 
				 ReviewerName AS 'Reviewer Name', 
				  Rating, 
                  Comment  
			 FROM CTE_ProductReviews 
			WHERE Rating = (
							  SELECT MIN(Rating) 
								FROM CTE_ProductReviews
						   );


-- ------------------------------------------ Extra - May be difficult
/* Your goal is to write a query that serves as an employee sales report.
This query should return:
-  the employeeID
-  the employee's first and last name
-  the name of each product
-  and how many of that product they sold */
	
    -- RE-WRITTEN
    SELECT e.EmployeeID,
		   concat(e.FirstName, ' ', e.LastName) AS 'Employee_Name',
		   p.name AS 'Product_Name', 
           SUM(s.Quantity) AS 'TotalQuantitySold'
      FROM sales s
      JOIN employees e
        ON s.EmployeeID = e.EmployeeID
      JOIN products p
        ON s.ProductID = p.ProductID
  GROUP BY s.EmployeeID, 
		   Employee_Name,
           Product_Name;	-- s.ProductID or p.ProductID ==> GROUPS the 'p.name'

/* OTHER WAY
SELECT a.EmployeeID, 
	   concat(e.FirstName, ' ', e.LastName) AS 'Employee Name',
       p.Name AS 'Product Name',
	   a.TotalQuantitySold AS 'Total Quantity Sold'
  FROM (
		 SELECT s.EmployeeID,
				s.ProductID,
				SUM(s.Quantity) AS 'TotalQuantitySold'
		   FROM sales s
	   GROUP BY s.EmployeeID, 
				s.ProductID
       ) a
  JOIN employees e
    ON e.EmployeeID = a.EmployeeID
  JOIN products p
    ON p.ProductID = a.ProductID;
  */  
    
      
