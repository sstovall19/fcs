
-- ekelly: cleaning up transaction_step
delete from transaction_step where id > 0;

-- ekelly: expanding these columns that were too small to big with.
alter table transaction_step modify objectname varchar(255) default NULL;
alter table transaction_step modify objectargs varchar(255) default NULL;
alter table transaction_job modify objectname varchar(255) default NULL;
alter table transaction_job modify objectargs varchar(255) default NULL;

-- ekelly: Adding steps for QUOTE family.
insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations)
values ('QUOTE','A','Create Quote','B','Z','/usr/local/fonality/BU/quote/fcs_create_quote.pl',3);

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations)
values ('QUOTE','B','Discount Approval','C','Z','/usr/local/fonality/BU/quote/fcs_discount_approval.pl',3);

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations,objectargs)
values ('QUOTE','C','Tax Calculator','D','Z','/usr/local/fonality/BU/quote/java/tax-calculator.jar',3,'com.fonality.bu.quote.TaxCalculator');

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations)
values ('QUOTE','D','Calculate Shipping','E','Z','/usr/local/fonality/BU/quote/fcs_shipping_calculator.pl',3);

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations)
values ('QUOTE','E','Check NS Lead','F','Z','/usr/local/fonality/BU/quote/fcs_create_netsuite_customer.pl',3);

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations)
values ('QUOTE','F','Create NS Opportunity','G','Z','/usr/local/fonality/BU/quote/fcs_create_netsuite_opportunity.pl',3);

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations)
values ('QUOTE','G','Create PDF & Email','','Z','/usr/local/fonality/BU/quote/fcs_email_pdf/fcs_email_pdf',3);

insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations,objectargs)
values ('QUOTE','Z','Failure Notification','','','/usr/local/fonality/BU/quote/java/email-notification.jar',1,'com.fonality.bu.quote.EmailNotification');

-- ekelly: Adding steps for ORDER family.
insert into transaction_step (familyname,sequence_name,objectname,sequence_success,sequence_failure,objectlocation,iterations,objectargs)
values ('ORDER','A','Order Manager Approval','','','/usr/local/fonality/BU/order/java/order-manager-approval.jar',3,'com.fonality.bu.order.OrderManagerApproval');

