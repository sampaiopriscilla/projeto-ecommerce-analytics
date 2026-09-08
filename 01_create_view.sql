-- =============================================================================
-- PROJETO: E-commerce Analytics (Olist Dataset)
-- OBJETIVO: View unificada para analise de vendas com dimensoes temporais
-- =============================================================================

USE PortfolioEcommerce;
GO

CREATE OR ALTER VIEW vw_ecommerce_analytics AS
SELECT 
    -- Identificadores e Status do Pedido
    o.order_id,
    o.order_status,
    
    -- Dimensoes Temporais Pre-calculadas
    CAST(o.order_purchase_timestamp AS DATE) AS data_dia,
    YEAR(o.order_purchase_timestamp) AS ano_compra,
    MONTH(o.order_purchase_timestamp) AS mes_compra,
    DAY(o.order_purchase_timestamp) AS dia_compra,
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS ano_mes_compra,
    
    -- Dimensao Geografica (Cliente)
    c.customer_city AS cidade_cliente,
    c.customer_state AS estado_cliente,
    
    -- Dimensao de Produto e Itens
    i.product_id,
    p.product_category_name AS categoria_produto,
    i.price AS valor_produto,
    i.freight_value AS valor_frete,
    
    -- Dimensao de Pagamento
    pay.payment_type AS tipo_pagamento,
    pay.payment_installments AS parcelas,
    pay.payment_value AS valor_pago_total

FROM olist_orders_dataset o
INNER JOIN olist_customers_dataset c 
    ON o.customer_id = c.customer_id
INNER JOIN olist_order_items_dataset i 
    ON o.order_id = i.order_id
LEFT JOIN olist_products_dataset p 
    ON i.product_id = p.product_id
LEFT JOIN olist_order_payments_dataset pay 
    ON o.order_id = pay.order_id;