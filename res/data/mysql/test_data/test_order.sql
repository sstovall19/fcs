USE fcstest;
-- Creates a test order without discounts or promotions. Affects the following tables:
--  -billing_schedule
--  -entity_address
--  -order_bundle
--  -order_group
--  -orders
--  -order_shipping

SET foreign_key_checks = 0;

DELETE FROM orders WHERE netsuite_salesperson_id = 712 AND customer_id = 34129 AND netsuite_lead_id = 1097985 AND company_name LIKE 'TEST%' LIMIT 1;
INSERT INTO orders 
    (one_time_total, mrc_total, term_in_months, balance, customer_id, company_name, netsuite_lead_id, netsuite_salesperson_id, order_status_id, provisioning_status_id, manager_approval_status_id, billing_approval_status_id, credit_approval_status_id, order_type, record_type, created)
    VALUES ('0.00', '513.00', 60, '30780.00', 34129, 'TEST1: WTG : V2 Systems, Inc. : Creating Results', 1097985, 712, 10, 7, 2, 2, 2, 'NEW', 'ORDER', null);

DELETE FROM entity_address WHERE label = 'TEST1' AND addr1 = '14000 Crown Court' LIMIT 1;
INSERT INTO entity_address
    (label, type, addr1, addr2, city, state_prov, postal, country)
    VALUES ('TEST1', 'shipping', '14000 Crown Court', 'Suite 211', 'Woodbridge', 'VA', 22193, 'United States');

SET @order_id = (SELECT order_id FROM orders WHERE netsuite_salesperson_id = 712 AND customer_id = 34129 AND netsuite_lead_id = 1097985 AND company_name LIKE 'TEST%' LIMIT 1); 
SET @address_id = (SELECT entity_address_id FROM entity_address WHERE label = 'TEST1' AND addr1 = '14000 Crown Court' LIMIT 1);
INSERT INTO order_group 
    (order_id, server_id, shipping_address_id, billing_address_id, product_id, netsuite_opportunity_id, one_time_total, mrc_total)
    VALUES (@order_id, 18319, @address_id, @address_id, 7, 968323, '0.00', '513.00');

SET @order_group_id = (SELECT order_group_id FROM order_group WHERE order_id = @order_id LIMIT 1);
INSERT INTO order_shipping
    (order_group_id, shipping_text, shipping_rate)
    VALUES (@order_group_id, 'TEST1 UPS Ground', '173.00');

SET @shipping_id = (SELECT order_shipping_id FROM order_shipping WHERE order_group_id = @order_group_id LIMIT 1);
UPDATE order_group SET chosen_shipping_id = @shipping_id WHERE order_group_id = @order_group_id LIMIT 1;

INSERT INTO billing_schedule
    (server_id, customer_id, order_group_id, date, amount)
    VALUES (18319, 34129, @order_group_id, '2013-2-14', '513.00'), (18319, 34129, @order_group_id, '2013-3-14', '513.00'), (18319, 34129, @order_group_id, '2013-4-14', '513.00');

INSERT INTO order_bundle
    (bundle_id, order_group_id, quantity, list_price, unit_price, one_time_total, mrc_total, tax_mapping_id, is_rented)
    VALUES (42, @order_group_id, 12, '9.00', '9.00', '0.00', '108.00', 8, 1), (45, @order_group_id, 3, '27.00', '27.00', '0.00', '81.00', 8, 1);

SET foreign_key_checks = 1;
