
-- SELECT-FROM -- 
SELECT custid,
custlastname
FROM customer;

-- WHERE --
SELECT *
FROM OrderItem
WHERE discountlevel = 'b'
AND price > 50;

-- ORDER BY --
SELECT *
FROM product
ORDER BY prodcost DESC;

SELECT *
FROM product
ORDER BY prodfabcode, prodcost;

-- JOIN --
SELECT custlastname,
custfirstname,
ordnum,
orddate
FROM customer
    JOIN orders
        ON customer.custid = orders.ordcustid
ORDER BY custlastname;