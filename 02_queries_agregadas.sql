-- =============================================================================
-- PROJETO: E-commerce Analytics (Olist Dataset)
-- OBJETIVO: Extração completa sem perda de dados para alimentacao do Dashboard
-- =============================================================================

USE PortfolioEcommerce;
GO

SELECT 
    -- 1. Dados do Pedido
    o.order_id,
    o.order_status,
    
    -- 2. Colunas Temporais (Sem horario bruto)
    CAST(o.order_purchase_timestamp AS DATE) AS data_dia,
    YEAR(o.order_purchase_timestamp) AS ano_compra,
    MONTH(o.order_purchase_timestamp) AS mes_compra,
    DAY(o.order_purchase_timestamp) AS dia_compra,
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS ano_mes_compra,
    
    -- 3. Dados do Cliente (Localizacao)
    c.customer_city AS cidade_cliente,
    c.customer_state AS estado_cliente,
    
    -- 4. Dados do Item e Produto
    i.product_id,
    COALESCE(p.product_category_name, 'Outros') AS categoria_produto,
    i.price AS valor_produto,
    i.freight_value AS valor_frete,
    (i.price + i.freight_value) AS valor_total_item,
    
    -- 5. Dados do Pagamento Consolidados por Pedido
    COALESCE(pay.tipo_pagamento_principal, 'Nao Informado') AS tipo_pagamento,
    COALESCE(pay.max_parcelas, 1) AS parcelas,
    COALESCE(pay.valor_pago_total, (i.price + i.freight_value)) AS valor_pago_total

FROM olist_orders_dataset o
INNER JOIN olist_customers_dataset c 
    ON o.customer_id = c.customer_id
INNER JOIN olist_order_items_dataset i 
    ON o.order_id = i.order_id
LEFT JOIN olist_products_dataset p 
    ON i.product_id = p.product_id

-- Subconsulta para agrupar pagamentos por pedido (evita linhas duplicadas de pagamentos fracionados)
LEFT JOIN (
    SELECT 
        order_id,
        MAX(payment_type) AS tipo_pagamento_principal,
        MAX(payment_installments) AS max_parcelas,
        SUM(payment_value) AS valor_pago_total
    FROM olist_order_payments_dataset
    GROUP BY order_id
) pay ON o.order_id = pay.order_id

ORDER BY o.order_purchase_timestamp DESC;
GO