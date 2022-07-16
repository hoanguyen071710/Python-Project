USE OlistEcommerce;

-- Check states of customer
SELECT DISTINCT customer_state
FROM olist_customers_dataset

-- Sort most common customer states
SELECT customer_state, COUNT(customer_state) AS customer_state_count
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY customer_state_count DESC


-- View all olist_order_payments_dataset
SELECT * 
FROM olist_order_payments_dataset


-- Count each payment type
SELECT payment_type, COUNT(payment_type)
FROM olist_order_payments_dataset
GROUP BY payment_type


-- Average payment value for each type for payment type
SELECT payment_type, AVG(payment_value) AS avg_payment_value
FROM olist_order_payments_dataset
GROUP BY payment_type


-- Average payment sequential for each payment type
SELECT payment_type, AVG(payment_sequential) AS avg_payment_sequential
FROM olist_order_payments_dataset
GROUP BY payment_type


-- Order review dataset
SELECT *
FROM olist_order_reviews_dataset


-- Average review score of all orders
SELECT AVG(review_score) AS avg_review_score
FROM olist_order_reviews_dataset


-- Comment message count of each review score
SELECT review_score, COUNT(review_comment_message)
FROM olist_order_reviews_dataset
WHERE review_comment_message IS NOT NULL
GROUP BY review_score
ORDER BY review_score


-- Products dataset with name translation
SELECT *
FROM olist_products_dataset p
JOIN product_category_name_translation t
ON p.product_category_name = t.product_category_name


-- Sort order_id based on average payment value
SELECT oi.order_id, AVG(payment_value) AS average_payment_value
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
JOIN olist_order_payments_dataset op
ON oi.order_id = op.order_id
GROUP BY oi.order_id
ORDER BY average_payment_value DESC


-- Sort average payment value by state
SELECT customer_state, AVG(payment_value) AS average_payment_value_by_state
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset op
ON o.order_id = op.order_id
GROUP BY customer_state
ORDER BY average_payment_value_by_state DESC

-- Count each payment types of each state
SELECT c.customer_state, op.payment_type, COUNT(*) AS total_payment_type_per_state
FROM olist_order_payments_dataset op
JOIN olist_orders_dataset o
ON op.order_id = o.order_id
JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state, op.payment_type
ORDER BY c.customer_state, op.payment_type

-- Seller database
SELECT *
FROM olist_sellers_dataset

-- Sort number of sellers based on state
SELECT seller_state, COUNT(seller_id) AS seller_counts
FROM olist_sellers_dataset
GROUP BY seller_state
ORDER BY COUNT(seller_id) DESC


-- Average Payment Value Based on Seller State
DECLARE @SellerState NVARCHAR(MAX)
SET @SellerState = ''
DECLARE @SQL NVARCHAR(MAX)
SELECT @SellerState = @SellerState + QUOTENAME(st.seller_state) + ','
FROM
	(SELECT s.seller_state, COUNT(seller_state) AS state_count
	FROM olist_sellers_dataset s
	GROUP BY s.seller_state) st
SET @SellerState = LEFT(@SellerState, LEN(@SellerState) - 1)
SET @SQL = 
'SELECT *
FROM
	(SELECT s.seller_state, oi.price
	FROM olist_order_items_dataset oi
	LEFT JOIN olist_sellers_dataset s
	ON oi.seller_id = s.seller_id) pivotData
PIVOT
(
	AVG(price)
	FOR seller_state
	IN (' + @SellerState + ')) AS PivotTable'

EXECUTE sp_executesql @SQL

-- Average freight value by seller state

DECLARE @SellerStateName NVARCHAR(MAX)
SET @SellerStateName = ''
DECLARE @freight_value_by_state NVARCHAR(MAX)
SELECT @SellerStateName += QUOTENAME(st.seller_state) + ','
FROM
(SELECT s.seller_state, COUNT(seller_state) AS state_count
FROM olist_sellers_dataset s
GROUP BY s.seller_state) st
SET @SellerStateName = LEFT(@SellerStateName, LEN(@SellerStateName) - 1)
SET	@freight_value_by_state = 
'SELECT *
FROM
	(SELECT s.seller_state, oi.freight_value
	FROM olist_order_items_dataset oi
	LEFT JOIN olist_sellers_dataset s
	ON oi.seller_id = s.seller_id) pivotData
PIVOT
(
	AVG(freight_value)
	FOR seller_state
	IN (' + @SellerStateName + ')) AS PivotTable'

EXECUTE sp_executesql @freight_value_by_state