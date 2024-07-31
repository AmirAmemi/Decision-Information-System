With productline_sales AS (
SELECT productline
,

year
(orderDate) order_year,
ROUND(SUM(quantityOrdered * priceEach),0) order_value
FROM orders
INNER JOIN orderdetails USING (orderNumber
)
INNER JOIN products USING (productCode
)

GROUP BY productline, order_year
)
SELECT
productline,
order_year,
order_value
,
NTILE(3) OVER (
PARTITION BY order_year
ORDER BY order_value DESC
) product_line_group
FROM
productline_sales
;