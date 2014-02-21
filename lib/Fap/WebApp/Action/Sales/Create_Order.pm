#!/usr/bin/perl
#

use strict;

# Fap modules
use Fap::Order::Shipping;
#use Fap::Order::EchoSign;
use Fap::Billing::CreditCard;
use Fap::Country;
use Fap::Bundle;
use Fap::Provision;
use Fap::Provider;

sub process_Create_Order
{
	my $self = shift;
	$self->title('Submit an order');

	my $action = $self->valid->param('action');
	my $order_id = $self->valid->param('order_id', 'numbers');
	my $order_group_id = $self->valid->param('order_group_id', 'numbers');

	# If we have an order ID, we should load it
	if($order_id)
	{
		my $order = $self->Sales_Create_Order_load_order($order_id);

		if($order)
		{
			$self->tt_append(var => 'order', val => $order);
			$self->tt_append(var => 'country_list', val => $Fap::Data::Countries::_country_list);
			$self->tt_append(var => 'state_list', val => $Fap::Data::Countries::_state_list->{'USA'});

			# If there is an order group, add it to the template
			if($order_group_id)
			{
				my $order_group = $self->Sales_Create_Order_order_group($order_group_id);

				if($order_group)
				{
					$self->tt_append(var => 'order_group', val => $order_group);
					$self->tt_append(var => 'order_group_id', val => $order_group_id);
				}
				else
				{
					$self->alert('Invalid order group');
				}
			}
		}
		else
		{
			$self->alert('Invalid order ID');
		}
	}

=head1 AJAX Methods

=over 4

	Documentation for getting and setting data via AJAX related to an order.

=back

=cut

=head2 order_details

=over 4

	Get details about an order id or order_group_id

	Params:

		mode		: Sales.Create_Order
		action		: order_details
		order_id	: int order_id number
		[order_group_id]: int order_group_id

	Returns:

		JSON Object:

		order_id only:

		{
			"type":"object",
			"$schema": "http://json-schema.org/draft-03/schema",
			"id": "#",
			"required":false,
			"properties":{
				"result": {
					"type":"object",
					"id": "result",
					"required":false,
					"properties":{
						"approval_comment": {
							"type":"string",
							"id": "approval_comment",
							"required":false
						},
						"balance": {
							"type":"string",
							"id": "balance",
							"required":false
						},
						"billing_approval_date": {
							"type":"string",
							"id": "billing_approval_date",
							"required":false
						},
						"billing_approval_status_id": {
							"type":"null",
							"id": "billing_approval_status_id",
							"required":false
						},
						"billing_interval_in_months": {
							"type":"string",
							"id": "billing_interval_in_months",
							"required":false
						},
						"billing_reviewer_id": {
							"type":"null",
							"id": "billing_reviewer_id",
							"required":false
						},
						"company_name": {
							"type":"string",
							"id": "company_name",
							"required":false
						},
						"contact_id": {
							"type":"string",
							"id": "contact_id",
							"required":false
						},
						"contact": {
							"type":"object",
							"id": "contact",
							"required":false,
							"properties":{
								"created": {
									"type":"string",
									"id": "created",
									"required":false
								},
								"email": {
									"type":"string",
									"id": "email",
									"required":false
								},
								"entity_contact_id": {
									"type":"string",
									"id": "entity_contact_id",
									"required":false
								},
								"extension": {
									"type":"null",
									"id": "extension",
									"required":false
								},
								"first_name": {
									"type":"string",
									"id": "first_name",
									"required":false
								},
								"last_name": {
									"type":"string",
									"id": "last_name",
									"required":false
								},
								"netsuite_id": {
									"type":"null",
									"id": "netsuite_id",
									"required":false
								},
								"phone": {
									"type":"string",
									"id": "phone",
									"required":false
								},
								"role": {
									"type":"string",
									"id": "role",
									"required":false
								},
								"updated": {
									"type":"string",
									"id": "updated",
									"required":false
								}
							}
						},
						"contract_start_date": {
							"type":"string",
							"id": "contract_start_date",
							"required":false
						},
						"created": {
							"type":"string",
							"id": "created",
							"required":false
						},
						"credit_approval_date": {
							"type":"string",
							"id": "credit_approval_date",
							"required":false
						},
						"credit_approval_status_id": {
							"type":"null",
							"id": "credit_approval_status_id",
							"required":false
						},
						"credit_card_id": {
							"type":"null",
							"id": "credit_card_id",
							"required":false
						},
						"credit_reviewer_id": {
							"type":"null",
							"id": "credit_reviewer_id",
							"required":false
						},
						"customer_id": {
							"type":"null",
							"id": "customer_id",
							"required":false
						},
						"discount_amount": {
							"type":"string",
							"id": "discount_amount",
							"required":false
						},
						"discount_percent": {
							"type":"string",
							"id": "discount_percent",
							"required":false
						},
						"first_payment": {
							"type":"string",
							"id": "first_payment",
							"required":false
						},
						"industry": {
							"type":"string",
							"id": "industry",
							"required":false
						},
						"manager_approval_date": {
							"type":"string",
							"id": "manager_approval_date",
							"required":false
						},
						"manager_approval_status_id": {
							"type":"string",
							"id": "manager_approval_status_id",
							"required":false
						},
						"manager_reviewer_id": {
							"type":"null",
							"id": "manager_reviewer_id",
							"required":false
						},
						"mrc_total": {
							"type":"string",
							"id": "mrc_total",
							"required":false
						},
						"netsuite_lead_id": {
							"type":"string",
							"id": "netsuite_lead_id",
							"required":false
						},
						"netsuite_salesperson_id": {
							"type":"string",
							"id": "netsuite_salesperson_id",
							"required":false
						},
						"note": {
							"type":"string",
							"id": "note",
							"required":false
						},
						"one_time_total": {
							"type":"string",
							"id": "one_time_total",
							"required":false
						},
						"order_creator_id": {
							"type":"null",
							"id": "order_creator_id",
							"required":false
						},
						"order_group": {
							"type":"array",
							"id": "order_group",
							"required":false,
							"items":
								{
									"type":"object",
									"id": "0",
									"required":false,
									"properties":{
										"billing_address_id": {
											"type":"null",
											"id": "billing_address_id",
											"required":false
										},
										"chosen_shipping_id": {
											"type":"null",
											"id": "chosen_shipping_id",
											"required":false
										},
										"discount_amount": {
											"type":"string",
											"id": "discount_amount",
											"required":false
										},
										"mrc_tax_total": {
											"type":"string",
											"id": "mrc_tax_total",
											"required":false
										},
										"mrc_total": {
											"type":"string",
											"id": "mrc_total",
											"required":false
										},
										"netsuite_echosign_id": {
											"type":"null",
											"id": "netsuite_echosign_id",
											"required":false
										},
										"netsuite_id": {
											"type":"string",
											"id": "netsuite_id",
											"required":false
										},
										"one_time_tax_total": {
											"type":"string",
											"id": "one_time_tax_total",
											"required":false
										},
										"one_time_total": {
											"type":"string",
											"id": "one_time_total",
											"required":false
										},
										"order_bundles": {
											"type":"array",
											"id": "order_bundles",
											"required":false,
											"items":
												{
													"type":"object",
													"id": "0",
													"required":false,
													"properties":{
														"bundle_id": {
															"type":"string",
															"id": "bundle_id",
															"required":false
														},
														"category_id": {
															"type":"string",
															"id": "category_id",
															"required":false
														},
														"category": {
															"type":"string",
															"id": "category",
															"required":false
														},
														"description": {
															"type":"string",
															"id": "description",
															"required":false
														},
														"discounted_price": {
															"type":"string",
															"id": "discounted_price",
															"required":false
														},
														"display_type": {
															"type":"string",
															"id": "display_type",
															"required":false
														},
														"mrc_total": {
															"type":"string",
															"id": "mrc_total",
															"required":false
														},
														"name": {
															"type":"string",
															"id": "name",
															"required":false
														},
														"one_time_total": {
															"type":"string",
															"id": "one_time_total",
															"required":false
														},
														"order_category_id": {
															"type":"string",
															"id": "order_category_id",
															"required":false
														},
														"priority": {
															"type":"string",
															"id": "priority",
															"required":false
														},
														"product_id": {
															"type":"string",
															"id": "product_id",
															"required":false
														},
														"quantity": {
															"type":"string",
															"id": "quantity",
															"required":false
														},
														"unit_price": {
															"type":"string",
															"id": "unit_price",
															"required":false
														}
													}
												}
											

										},
										"order_group_id": {
											"type":"string",
											"id": "order_group_id",
											"required":false
										},
										"order_id": {
											"type":"string",
											"id": "order_id",
											"required":false
										},
										"product_id": {
											"type":"string",
											"id": "product_id",
											"required":false
										},
										"reprovisioned_phones": {
											"type":"number",
											"id": "reprovisioned_phones",
											"required":false
										},
										"sales_tax_rate": {
											"type":"string",
											"id": "sales_tax_rate",
											"required":false
										},
										"server_id": {
											"type":"null",
											"id": "server_id",
											"required":false
										},
										"shipping_address_id": {
											"type":"string",
											"id": "shipping_address_id",
											"required":false
										},
										"shipping_address": {
											"type":"array",
											"id": "shipping_address",
											"required":false,
											"items":
												{
													"type":"object",
													"id": "0",
													"required":false,
													"properties":{
														"addr1": {
															"type":"string",
															"id": "addr1",
															"required":false
														},
														"addr2": {
															"type":"string",
															"id": "addr2",
															"required":false
														},
														"city": {
															"type":"string",
															"id": "city",
															"required":false
														},
														"country": {
															"type":"string",
															"id": "country",
															"required":false
														},
														"created": {
															"type":"string",
															"id": "created",
															"required":false
														},
														"entity_address_id": {
															"type":"string",
															"id": "entity_address_id",
															"required":false
														},
														"label": {
															"type":"string",
															"id": "label",
															"required":false
														},
														"postal": {
															"type":"string",
															"id": "postal",
															"required":false
														},
														"state_prov": {
															"type":"string",
															"id": "state_prov",
															"required":false
														},
														"type": {
															"type":"string",
															"id": "type",
															"required":false
														},
														"updated": {
															"type":"string",
															"id": "updated",
															"required":false
														}
													}
												}
											

										},
										"shipping_rates": {
											"type":"array",
											"id": "shipping_rates",
											"required":false,
											"items":
												{
													"type":"object",
													"id": "0",
													"required":false,
													"properties":{
														"order_group_id": {
															"type":"string",
															"id": "order_group_id",
															"required":false
														},
														"order_shipping_id": {
															"type":"string",
															"id": "order_shipping_id",
															"required":false
														},
														"shipping_rate": {
															"type":"string",
															"id": "shipping_rate",
															"required":false
														},
														"shipping_text": {
															"type":"string",
															"id": "shipping_text",
															"required":false
														}
													}
												}
											

										}
									}
								}
							

						},
						"order_id": {
							"type":"string",
							"id": "order_id",
							"required":false
						},
						"order_status_id": {
							"type":"string",
							"id": "order_status_id",
							"required":false
						},
						"order_type": {
							"type":"string",
							"id": "order_type",
							"required":false
						},
						"payment_method_id": {
							"type":"string",
							"id": "payment_method_id",
							"required":false
						},
						"prepay_amount": {
							"type":"string",
							"id": "prepay_amount",
							"required":false
						},
						"product_id": {
							"type":"string",
							"id": "product_id",
							"required":false
						},
						"proposal_pdf": {
							"type":"string",
							"id": "proposal_pdf",
							"required":false
						},
						"provisioning_status_id": {
							"type":"null",
							"id": "provisioning_status_id",
							"required":false
						},
						"quote_expiry": {
							"type":"string",
							"id": "quote_expiry",
							"required":false
						},
						"record_type": {
							"type":"string",
							"id": "record_type",
							"required":false
						},
						"reseller_id": {
							"type":"null",
							"id": "reseller_id",
							"required":false
						},
						"term_in_months": {
							"type":"string",
							"id": "term_in_months",
							"required":false
						},
						"transaction_submit_id": {
							"type":"null",
							"id": "transaction_submit_id",
							"required":false
						},
						"updated": {
							"type":"string",
							"id": "updated",
							"required":false
						},
						"website": {
							"type":"string",
							"id": "website",
							"required":false
						}
					}
				},
				"status": {
					"type":"number",
					"id": "status",
					"required":false
				}
			}
		}

		Get order_group_id:

		{
			"type":"object",
			"$schema": "http://json-schema.org/draft-03/schema",
			"id": "#",
			"required":false,
			"properties":{
				"result": {
					"type":"object",
					"id": "result",
					"required":false,
					"properties":{
						"billing_address_id": {
							"type":"null",
							"id": "billing_address_id",
							"required":false
						},
						"chosen_shipping_id": {
							"type":"null",
							"id": "chosen_shipping_id",
							"required":false
						},
						"discount_amount": {
							"type":"string",
							"id": "discount_amount",
							"required":false
						},
						"mrc_tax_total": {
							"type":"string",
							"id": "mrc_tax_total",
							"required":false
						},
						"mrc_total": {
							"type":"string",
							"id": "mrc_total",
							"required":false
						},
						"netsuite_echosign_id": {
							"type":"null",
							"id": "netsuite_echosign_id",
							"required":false
						},
						"netsuite_id": {
							"type":"string",
							"id": "netsuite_id",
							"required":false
						},
						"one_time_tax_total": {
							"type":"string",
							"id": "one_time_tax_total",
							"required":false
						},
						"one_time_total": {
							"type":"string",
							"id": "one_time_total",
							"required":false
						},
						"order_bundles": {
							"type":"array",
							"id": "order_bundles",
							"required":false,
							"items":
								{
									"type":"object",
									"id": "0",
									"required":false,
									"properties":{
										"bundle_id": {
											"type":"string",
											"id": "bundle_id",
											"required":false
										},
										"category_id": {
											"type":"string",
											"id": "category_id",
											"required":false
										},
										"category": {
											"type":"string",
											"id": "category",
											"required":false
										},
										"description": {
											"type":"string",
											"id": "description",
											"required":false
										},
										"discounted_price": {
											"type":"string",
											"id": "discounted_price",
											"required":false
										},
										"display_type": {
											"type":"string",
											"id": "display_type",
											"required":false
										},
										"mrc_total": {
											"type":"string",
											"id": "mrc_total",
											"required":false
										},
										"name": {
											"type":"string",
											"id": "name",
											"required":false
										},
										"one_time_total": {
											"type":"string",
											"id": "one_time_total",
											"required":false
										},
										"order_category_id": {
											"type":"string",
											"id": "order_category_id",
											"required":false
										},
										"priority": {
											"type":"string",
											"id": "priority",
											"required":false
										},
										"product_id": {
											"type":"string",
											"id": "product_id",
											"required":false
										},
										"quantity": {
											"type":"string",
											"id": "quantity",
											"required":false
										},
										"unit_price": {
											"type":"string",
											"id": "unit_price",
											"required":false
										}
									}
								}
							

						},
						"order_group_id": {
							"type":"string",
							"id": "order_group_id",
							"required":false
						},
						"order_id": {
							"type":"string",
							"id": "order_id",
							"required":false
						},
						"product_id": {
							"type":"string",
							"id": "product_id",
							"required":false
						},
						"reprovisioned_phones": {
							"type":"number",
							"id": "reprovisioned_phones",
							"required":false
						},
						"sales_tax_rate": {
							"type":"string",
							"id": "sales_tax_rate",
							"required":false
						},
						"server_id": {
							"type":"null",
							"id": "server_id",
							"required":false
						},
						"shipping_address_id": {
							"type":"string",
							"id": "shipping_address_id",
							"required":false
						},
						"shipping_address": {
							"type":"array",
							"id": "shipping_address",
							"required":false,
							"items":
								{
									"type":"object",
									"id": "0",
									"required":false,
									"properties":{
										"addr1": {
											"type":"string",
											"id": "addr1",
											"required":false
										},
										"addr2": {
											"type":"string",
											"id": "addr2",
											"required":false
										},
										"city": {
											"type":"string",
											"id": "city",
											"required":false
										},
										"country": {
											"type":"string",
											"id": "country",
											"required":false
										},
										"created": {
											"type":"string",
											"id": "created",
											"required":false
										},
										"entity_address_id": {
											"type":"string",
											"id": "entity_address_id",
											"required":false
										},
										"label": {
											"type":"string",
											"id": "label",
											"required":false
										},
										"postal": {
											"type":"string",
											"id": "postal",
											"required":false
										},
										"state_prov": {
											"type":"string",
											"id": "state_prov",
											"required":false
										},
										"type": {
											"type":"string",
											"id": "type",
											"required":false
										},
										"updated": {
											"type":"string",
											"id": "updated",
											"required":false
										}
									}
								}
							

						},
						"shipping_rates": {
							"type":"array",
							"id": "shipping_rates",
							"required":false,
							"items":
								{
									"type":"object",
									"id": "0",
									"required":false,
									"properties":{
										"order_group_id": {
											"type":"string",
											"id": "order_group_id",
											"required":false
										},
										"order_shipping_id": {
											"type":"string",
											"id": "order_shipping_id",
											"required":false
										},
										"shipping_rate": {
											"type":"string",
											"id": "shipping_rate",
											"required":false
										},
										"shipping_text": {
											"type":"string",
											"id": "shipping_text",
											"required":false
										}
									}
								}
							

						}
					}
				},
				"status": {
					"type":"number",
					"id": "status",
					"required":false
				}
			}
		}

	

=back

=cut
	if($action eq 'order_details')
	{
		if($self->Sales_Create_Order_order_is_loaded())
		{
			if($self->valid->param('order_group_id'))
			{
				if(my $order_group = $self->Sales_Create_Order_order_group($order_group_id))
				{
					return $self->json_process({ status => 1, result => $order_group });
				}
				else
				{
					return $self->json_process({ status => undef, error => 'Invalid order group ID' });
				}
			}
			else
			{
				return $self->json_process({ status => 1, result => $self->{Sales_Create_Order_order_details} });
			}
		}
		else
		{
			return $self->json_process({ status => undef, error => 'Invalid order ID' });
		}
	}

=head2 state_prov_list

=over 4

	Get a list of states or provinces for a given country code.

	Params:

		mode		: Sales.Create_Order
		action		: state_prov_list
		country		: string 3 character country code ( e.g. USA )

	Returns:

		JSON Object:

		{
		   "status" : 1,
		   "state_prov_list" : {
		      "LA" : "Louisiana",
		      "SC" : "South Carolina",
		      "MS" : "Mississippi",
		      "NC" : "North Carolina",
		      "GU" : "Guam",
		      ...
		   }
		}

=back

=cut	

	elsif($action eq 'state_prov_list')
	{
		my $ret;# = $self->db->cache->get("state_prov_list-".$self->valid->param('country'));
		if (!$ret) {
			if(my $country = $self->valid->param('country', 'form_postal_code')) {
				if(length($country) == 2) {
					($country) = grep { $Fap::Data::Countries::_country_list->{$_}->{'code2'} eq $country } keys %{$Fap::Data::Countries::_country_list} ;
				}
				$ret = {
					status => 1,
					state_prov_list => $Fap::Data::Countries::_state_list->{$country}
				};
			} else {
				$ret = {
					status => undef,
					error => "Invalid country code"
				};
			}
		}
		$self->db->cache->set("state_prov_list-".$self->valid->param('country'),$ret,7200);
		return $self->json_process($ret);
	}

=head2 country_list

=over 4

	Get a list of countries for shipping and other forms

	Params:

		mode		: Sales.Create_Order
		action		: country_list

	Returns:

		JSON Object:

		{
		   "status" : 1,
		   "country_list" : {
		      "NER" : {
			 "loadzone" : "us",
			 "code2" : "NE",
			 "country_code" : "227",
			 "dialing_code" : [
			    "00"
			 ],
			 "full_name" : "Niger",
			 "opermode" : null,
			 "national_prefix" : [
			    "0"
			 ],
			 "netsuite_name" : "_niger"
		      },
		      "BMU" : {
			 "loadzone" : "us",
			 "code2" : "BM",
			 "country_code" : null,
			 "dialing_code" : [
			    "011"
			 ],
			 "full_name" : "Bermuda",
			 "opermode" : null,
			 "national_prefix" : [
			    "1"
			 ],
			 "netsuite_name" : "_bermuda"
		      },
		      ...
		}	
	      }

	Note:

		If a country has a state / province list ( see state_prov ), it will have the property:

			“state_prov”: “1”

		If a country requires a postal code, it will have the property:

			“postal_code”: “1”

=back

=cut

	elsif($action eq 'country_list')
	{
		return $self->json_process({
			status => 1,
			country_list => $Fap::Data::Countries::_country_list
		});
	}

=head2 shipping

=over 4

	Get or set shipping data.

	By default, this will return a JSON object containing a list of shipping options for an order_id and order_group_id.

	If the address needs to be updated, provide a JSON object in the address parameter in the following format:

	{
		 'country': 'US',
		 'postal': '48072',
		 'addr1': '3214 Cumberland Rd',
		 'addr2': 'Suite 5000',
		 'city': 'Berkley',
		 'state_prov': 'MI'
	}

	Params:

		mode		: Sales.Create_Order
		action		: shipping
		order_id	: $order_id
		order_group_id	: $order_group_id
		[address]	: $shipping_address_json

	Returns:

		JSON Object:

		{
			"type":"object",
			"$schema": "http://json-schema.org/draft-03/schema",
			"id": "#",
			"required":false,
			"properties":{
				"error": {
					"type":"string",
					"id": "error",
					"required":false
				},
				"result": {
					"type":"array",
					"id": "result",
					"required":false,
					"items":
						{
							"type":"object",
							"id": "0",
							"required":false,
							"properties":{
								"order_group_id": {
									"type":"string",
									"id": "order_group_id",
									"required":false
								},
								"order_shipping_id": {
									"type":"string",
									"id": "order_shipping_id",
									"required":false
								},
								"shipping_rate": {
									"type":"string",
									"id": "shipping_rate",
									"required":false
								},
								"shipping_text": {
									"type":"string",
									"id": "shipping_text",
									"required":false
								}
							}
						}
					

				},
				"status": {
					"type":"number",
					"id": "status",
					"required":false
				}
			}
		}

		Example:

			{
			   "status" : 1,
			   "result" : [
			      {
				 "order_group_id" : "31368",
				 "shipping_text" : "UPS Ground",
				 "shipping_rate" : "100.00",
				 "order_shipping_id" : "834"
			      },
			      {
				 "order_group_id" : "31368",
				 "shipping_text" : "UPS 3 Day Select",
				 "shipping_rate" : "100.00",
				 "order_shipping_id" : "835"
			      },
			}

=back

=cut
	elsif($action eq 'shipping')
	{
		if(!$order_id || !$order_group_id)
		{
			return $self->json_process({ status => undef, error => "Order ID and group ID are required" });
		}

		my $address = $self->query->param('address');

		if($address)
		{
			if($address = $self->json_decode($address))
			{
				# Update address
				if($self->Sales_Create_Order_update_shipping_address($order_group_id, $address))
				{
					$self->write_log(level => 'VERBOSE', log => [ "Updated shipping address for order $order_id ( group $order_group_id )", $address ]);
				}
				else
				{
					return $self->json_process({ status => undef, error => "Could not update shipping address ( $@ )" });
				}
			}
			else
			{
				return $self->json_process({ status => undef, error => "Invalid address format" });
			}
		}

		# Get shipping options for this order_group_id
		my $shipping_options = $self->Sales_Create_Order_get_shipping_options($order_group_id);

		if($shipping_options)
		{
			return $self->json_process({ status => 1, result => $shipping_options });
		}
		else
		{
			$self->write_log(level => 'ERROR', log => $@);
			return $self->json_process({ status => undef, error => "Could not retrieve shipping options" });
		}
	}

=head2 did_regions

=over 4

	Get a list of regions ( state / provinces ) for getting avialable area codes.

	Params:

		mode		: Sales.Create_Order
		action		: did_regions
		order_group_id	: $order_group_id

	Returns:

		JSON Object:

		{
			"status": "1",
			"result": [
				"AL":"Alabama",
				"AK":"Alaska",
				...
			]
		}

=back

=cut

	elsif($action eq 'did_regions')
	{
		my $key = "did_regions_".$self->valid->param('country_code');
		my $country_code = $self->valid->param('country_code');

		if(my $regions = $self->Sales_Create_Order_get_available_did_regions($country_code))
		{
			return $self->json_process({ status => 1, result => $regions });
		}
		else
		{
			return $self->json_process({ status => undef, error => "Could not get DID regions" });
		}
	}

=head2 area_codes

=over 4

	Get a list of avialable area codes for a given order_group_id and region ( provided by did_regions )

	Params:

		mode		: Sales.Create_Order
		action		: area_codes
		order_group_id	: $order_group_id
		region		: $region

	Returns:

		JSON Object

		{
			"status": "1",
			"result": {
				"310":"Los Angeles",
				"213":"Los Angeles",
				"818":"Burbank",
				...
			}
		}
		
=back

=cut

	elsif($action eq 'area_codes')
	{
		my $country_code = $self->valid->param('country_code');
		my $region = $self->valid->param('region');
		
		my $area_codes = $self->Sales_Create_Order_get_available_area_codes($country_code, $region);

		if($area_codes)
		{
			return $self->json_process({
				status => 1,
				result => $area_codes,
			});
		}
		else
		{
			return $self->json_process({
				status => undef,
				error => $@,
			});
		}
	}

=head2 did_list

=over 4

	Retrieve a list of DID numbers available for the given order id and order_group

=back

=cut

	elsif($action eq 'did_list')
	{
		my $country_code = $self->valid->param('country_code');
		my $region = $self->valid->param('region');
		my $area_code = $self->valid->param('area_code', 'numbers');
		my $order_group_id = $self->valid->param('order_group_id', 'numbers');

		my $limit = $self->valid->param('limit', 'numbers') || 100;

		if(my $did_list = $self->Sales_Create_Order_get_available_dids($order_group_id, $country_code, $region, $area_code, $limit))
		{
			return $self->json_process({
				status => 1,
				result => $did_list
			});
		}
		else
		{
			return $self->json_process({
				status => undef,
				error => $@
			});
		}
	}

=head2 reserve_did

=over 4

	Reserve a DID number for a given order_group_id

	This is not yet available from the Inphonex provider.

=back

=cut

	elsif($action eq 'reserve_did')
	{
		# Reserve a DID number ( not yet available )
	}


=head2 phone_models

=over 4

	Retrieve a list of phone models for reprovisioned phones.

	Params:

		mode		: Sales.Create_Order
		action		: phone_models

	Returns:

		JSON Object:

		{
			"type":"object",
			"$schema": "http://json-schema.org/draft-03/schema",
			"id": "#",
			"required":false,
			"properties":{
				"result": {
					"type":"array",
					"id": "result",
					"required":false,
					"items":
						{
							"type":"object",
							"id": "0",
							"required":false,
							"properties":{
								"description": {
									"type":"string",
									"id": "description",
									"required":false
								},
								"display_name": {
									"type":"string",
									"id": "display_name",
									"required":false
								},
								"manufacturer": {
									"type":"string",
									"id": "manufacturer",
									"required":false
								},
								"model": {
									"type":"string",
									"id": "model",
									"required":false
								}
							}
						}
					

				},
				"status": {
					"type":"number",
					"id": "status",
					"required":false
				}
			}
		}

=back

=cut

	elsif($action eq 'phone_models')
	{
		# This is the category for IP phones
		my $category_id = $self->db->options("BundleCategory")->{'phone'};

		my @phones = $self->db->table('Bundle')->search(
			{
				category_id => $category_id,
				is_inventory => 1,
			}
		);

		@phones = $self->db->strip(@phones);

		# Filter result - Can't seem to use DBIx helpers 
		my @wanted = qw/model display_name description manufacturer/;

		foreach my $phone ( @phones )
		{
			foreach my $key ( keys %{$phone} )
			{
				delete $phone->{$key} if !grep { $_ eq $key } @wanted;
			}
		}

		return $self->json_process({ status => 1, result => \@phones });
	}

=head2 send_echosign

=over 4

	Send an EchoSign agreement.

	Will populate the orders table with the EchoSign id.


	Params:

		mode		: Sales.Create_Order
		action		: send_echosign
		order_id	: int order_id

	Returns:

		JSON Object:

		{
			"status": 1,
			"result": {
				"echosign_id":"555555"
			}			
		}

=back

=cut

	elsif($action eq 'send_echosign')
	{
		if(my $echo_sign = $self->Sales_Create_Order_send_echosign())
		{
			return $self->json_process({
				status => 1,
				result => $echo_sign
			});
		}
		else
		{
			return $self->json_process({
				status => undef,
				error => $@,
			});
		}
	}

=head2  check_echosign

=over 4

	Check the status of a sent EchoSign agreement for an order_id and echosign_id.

	Params:

		mode		: Sales.Create_Order
		action		: check_echosign
		order_id	: int order_id

	Returns:

		JSON Object:

		{
			"status":"1",
			"result":......to be defined
		}

=back

=cut

	elsif($action eq 'check_echosign')
	{
		if(my $echo_sign = $self->Sales_Create_Order_get_echosign())
		{
			return $self->json_process({
				status => 1,
				result => $echo_sign,
			});
		}
		else
		{
			return $self->json_process({
				status => undef,
				result => $echo_sign,
			});
		}
	}

=head2 charge_credit_card

=over 4

	Charge a credit card.

	On success, the transaction ID will be stored in the database and the transaction ID returned.

=back

=cut

	elsif($action eq 'charge_credit_card')
	{

	}
	elsif($action eq 'confirmation')
	{
		$self->tt_append(var => 'order_complete', val => 1);
	}
=head2 order_complete

=over 4

	Send order details to the database.

	Save order information.

	Params:

		mode		: Sales.Create_Order
		action		: order_complete
		order_id	: $order_id
		order_data	: $json_object

	Returns:

		JSON Object:

		{
			"status": "1",
			"redirect": "path_to_confirmation_page.html"
		}

		OR

		{
			"status": undef,
			"error": "Error message",
			"component": "What Section Failed",
			"order_group_id": [ "order_group_id" ]
		}				

	Example "order_data":

		{
			"billing": {
				"payment_method_id": "8",
				"netsuite_transaction_id": "23451",
				"billing_address": {
				  "country": "US",
				  "addr2": "Suite 500",
				  "city": "Berkley",
				  "postal": "48072",
				  "addr1": "3214 Cumberland Rd",
				  "state_prov": "MI"
				}
			},
			"order_groups": [
				{
					"order_group_id":"1234",
					"order_shipping_id":"834",
					"provider_dids": {
						"lnp": [
							"5555551212",
							"5555551213",
						],
						"local": [
							"3108613",
							"3108613",
							"21326845",
							"21326845",
							"21326845",
							"469",
							"288",
							"248",
						],
						"international": [
							"44837",
						],
						"tollfree": [
							"888",
							"888",
							"800",
							"877",
						],
					},
					"reprovision_phone": {
						"Polycom": {
							"IP330": [
								"0004F2B7286F",
								"0004F2B63C4A",
							],
							"IP550": [
								"0004F2B7781B",
							]
						},
						"Aastra": {
							"9143i": [
								"00085D76142C",
							],
						}
					},
				},
			]
		}

=back

=cut

	elsif($action eq 'order_complete')
	{
		# TEMP
		return $self->json({
			status => 1,
			redirect => '/?m=Sales.Create_Order&action=confirmation',
		});

		my $input = $self->query->param('order_json');

		if(my $decoded = $self->json_decode($input))
		{
			# Validate all of our data
			
			# Billing address should be valid
			if(my $billing_address = $decoded->{'billing_address'})
			{
				if(!$self->Sales_Create_Order_validate_address($billing_address))
				{
					return $self->json_process({
						status => undef,
						error => $@,
						component => "payment",
					});
				}
			}
			else
			{
				# Billing address is missing
				return $self->json_process({
					status => undef,
					error => "Billing address is required",
					component => "payment",
				});
					
			}

			# Make sure we have some order groups
			if(my $order_groups = $decoded->{'order_groups'})
			{
				# We expect order groups to be an array
				$order_groups = [ $order_groups ] if ref($order_groups) ne 'ARRAY';

				foreach my $group ( @{$order_groups} )
				{
					# validate order group
					my $group_validation = $self->Sales_Create_Order_validate_order_group($group);

					if($group_validation->{'error'})
					{
						return $self->json_process({
							status => undef,
							error => $group_validation->{'error'},
							component => $group_validation->{'component'},
						});
					}
				}
			}
			else
			{
				# Order groups are missing
				return $self->json_process({
					status => undef,
					error => "Order group details are required",
					component => "general",
				});
			}
		}
		else
		{
			# Invalid JSON
			return $self->json_process({
				status => undef,
				error => "Invalid order data format",
				component => "general",
			});
		}
	}


=head2 lnp_check

=over 4

	Determine if a particular phone number can be ported to this location's provider.

	Params:

		mode		: Sales.Create_Order
		action		: lnp_check
		order_id	: $order_id
		order_group_id	: $order_group_id
		phone_number	: $phone_number

	Returns:

		JSON Object:

		See examples.

	Examples:

		IS Portable:

		{
			"status": "1",
			"result": "1",
		}	

		NOT Portable:

		{
			"status": "1",
			"result": null,
		}	

=back

=cut

	elsif($action eq 'lnp_check')
	{
		# Check if a phone number can be ported

		# Must have order and order group ids
		if(!$order_id | !$order_group_id)
		{
			return $self->json_process({ status => undef, error => "Order ID and group ID are required" });
		}

		# Need a phone number
		my $phone_number = $self->valid->param('phone_number', 'numbers');

		if($phone_number)
		{
			# Check with provider to see if this number is portable
			my $can_port = $self->Sales_Create_Order_did_is_portable($order_group_id, $phone_number);

			return $self->json_process({ status => 1, result => $can_port });
		}
		else
		{
			return $self->jsonn_process({ status => undef, error => "Phone number is required" });
		}
	}

=head2 validate_mac_address

=over 4

	Validate a MAC address

	Params:

		mode		: Sales.Create_Order
		action		: validate_mac_address
		mac_address	: $mac_addr_string

	Returns:

		JSON Object

	Examples:

		Valid MAC address:

		{
			"status": "1",
			"result": "1",
		}

		Invalid MAC address:

		{
			"status": null,
			"error": "Invalid MAC Address",
		}

=back

=cut
	elsif($action eq 'validate_mac_address')
	{
		# Validate the format of a MAC address
		my $mac_address = $self->valid->param('mac_address');

		if($mac_address)
		{
			if($self->Sales_Create_Order_validate_mac_address($mac_address))
			{
				return $self->json_process({ status => 1, result => $mac_address });
			}
			else
			{
				return $self->json_process({ status => undef, error => "Invalid MAC address" });
			}
		}
		else
		{
			return $self->json_process({ status => undef, error => "Invalid MAC address" });
		}
	}

=head2 requires_credit_approval

=over 4

	Check to see if an order requires credit approval.

	Params:

		mode		: Sales.Create_Order
		action		: requires_credit_approval
		order_id	: $order_id

	Returns:

		JSON Object


	Examples:

		Credit check required:

			{
				"status": "1",
				"result": "1",
			}

		NO Credit check required:

			{
				"status": "1",
				"result": null,
			}

		ERROR

			{
				"status": null,
				"error": "Error message",
			}

=back

=cut

	elsif($action eq 'requires_credit_approval')
	{
		# Check to see if an order requires credit approval

		# Do we have an order to look up?
		if($order_id)
		{
			my $requires_approval = $self->Sales_Create_Order_requires_credit_approval();

			return $self->json_process({ status => 1, result => $requires_approval });			
		}
		else
		{
			return $self->json_process({ status => undef, error => "Order ID is required" });
		}

	}

=head2 payment_options

=over 4

	Get a list of alternate payment methods.

	Params:

		mode		: Sales.Create_Order
		action		: payment_options

	Returns:

		JSON Object:

		{
		   "status" : 1,
		   "result" : [
		      {
			 "payment_method_id" : "2",
			 "name" : "ACH"
		      },
		      {
			 "payment_method_id" : "4",
			 "name" : "Check"
		      },
		      {
			 "payment_method_id" : "1",
			 "name" : "Credit card"
		      },
		      {
			 "payment_method_id" : "5",
			 "name" : "Paypal"
		      },
		      {
			 "payment_method_id" : "3",
			 "name" : "Wire Transfer"
		      }
		   ]
		}

=back

=cut

	elsif($action eq 'payment_options')
	{
		# Get available payment options
		my $payment_options = $self->Sales_Create_Order_get_payment_methods();

		if($payment_options)
		{
			return $self->json_process({ status => 1, result => $payment_options });
		}
		else
		{
			$self->write_log(level => 'ERROR', log => $@);
			return $self->json_process({ status => undef, error => "Could not find any payment options" });
		}
	}

	# Show the template
	return $self->tt_process('Sales/Create_Order.tt');
}

=head1 Application Methods

=over 4

	Documentation for application methods used to pefrorm order related actions for the UI.

=back

=cut


=head2 Sales_Create_Order_load_order

=over 4

	Load all quote information for a given order

	Args   : $order_id
	Returns: $order_info or undef on failure

=back

=cut
sub Sales_Create_Order_load_order
{
	my ($self, $quote_id) = @_;

	# Remove any stored order details
	delete $self->{Sales_Create_Order_order_details} if $self->{Sales_Create_Order_order_details};

	# We definitely need an order id
	if(!$quote_id)
	{
		return $self->trace_error("Quote id is required");
	}

	# Load order details
	my @res = $self->db->table('Order')->search({order_id => $quote_id}, { prefetch => 'contact' });

	if(@res)
	{
		my @res = $self->db->strip(@res);
		my $order = $res[0];

		# Get order groups
		my @groups = $self->db->table('OrderGroup')->search({order_id => $order->{'order_id'}}, { prefetch => [ 'shipping_address'] });
		@groups = $self->db->strip(@groups);

		# Add the groups to our order
		$order->{'order_group'} = \@groups;

		# We will need the product ID at some point
		$order->{'product_id'} = $groups[0]->{'product_id'};

		# Populate reprovisioned phone count, shipping rates, etc.. for each order group
		foreach my $group ( @groups )
		{
			$group->{'shipping_rates'} = $self->Sales_Create_Order_get_shipping_options($group->{'order_group_id'});

			my @bundles = $self->db->table("OrderCategory")->search(
				{
					'order_group.order_group_id' => $group->{'order_group_id'} ,
					'me.product_id' => { "="=>\'order_group.product_id' },
					'order_bundles.order_group_id' => { "="=>\'order_group.order_group_id' },
				},
				{
					'+select' => [
						'me.name',
						'me.category_id',
						'label.name',
						'order_bundles.bundle_id',
						'order_bundles.quantity',
						'order_bundles.discounted_price',
						'order_bundles.one_time_total',
						'order_bundles.mrc_total',
						'order_bundles.list_price',
						'bundles.category_id',
					],
					'+as' => [
						'category',
						'order_category_id',
						'name',
						'bundle_id',
						'quantity',
						'discounted_price',
						'one_time_total',
						'mrc_total',
						'unit_price',
						'category_id',
					],
					join => 
					{
						label_xref => 
						{
							label => 
							{
								"bundles" => { "order_bundles" =>  "order_group"  }
							}
						}
					},
				}
			);

			# Get me just the data
			@bundles = $self->db->strip(@bundles);

			# Add these bundles to the group
			$group->{'order_bundles'} = \@bundles;

		}
		
		# Store this data
		$self->{Sales_Create_Order_order_details} = $order;

		# We need to go back through and get reprovisioned phone count if any
		foreach my $group ( @{$order->{'order_group'}} )
		{
			# Now we can get reprovisioned phone counts
			$group->{'reprovisioned_phones'} = $self->Sales_Create_Order_phone_reprovision_list($group->{'order_group_id'});
		}

		return $order;
	}
	else
	{
		return $self->trace_error("Invalid quote ID");
	}
}

=head2 Sales_Create_Order_order_is_loaded

=over 4

	Check to see if an order has been loaded and is available

	Args   : none
	Returns: true or undef

=back

=cut
sub Sales_Create_Order_order_is_loaded
{
	my $self = shift;

	if($self->{Sales_Create_Order_order_details})
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 Sales_Create_Order_order_info

=over 4

	Get stored order details property

	Args   : property
	Returns: value of order details property

=back

=cut
sub Sales_Create_Order_order_info
{
	my ($self, $prop) = @_;

	if(!$prop)
	{
		return undef;
	}

	return $self->{Sales_Create_Order_order_details}->{$prop};
}

=head2 Sales_Create_Order_order_group

=over 4

	Get an order group from a loaded order

	Args   : $order_group_id
	Returns: $order_group

=back

=cut
sub Sales_Create_Order_order_group
{
	my ($self, $order_group_id) = @_;

	if($self->Sales_Create_Order_order_is_loaded)
	{
		my @group =  grep { $_->{'order_group_id'} == $order_group_id } @{$self->{Sales_Create_Order_order_details}->{order_group}};
		my $g = $group[0];
		return $g;
	}
	else
	{
		return $self->trace_error("Order is not loaded");
	}
}

=head2 Sales_Create_Order_update_shipping_address

=over 4

	Update the address for a given order_id and entity_id and then recalculate the shipping rates.

	Args   : $order_id, $entity_id, $shipping_information_hash_ref
	Returns: true of undef on failure

=back


TODO:

	1. Save address to db
	2. Update stored order data
	3. Get new shipping rates?

=cut
sub Sales_Create_Order_update_shipping_address
{
	my ($self, $order_group_id, $shipping_address) = @_;

	# Make sure that an order has been loaded
	if(!$self->Sales_Create_Order_order_is_loaded)
	{
		return $self->trace_error("Order is not loaded");
	}

	# We need the order group ID
	if(!$order_group_id)
	{
		return $self->trace_error("Order group is required");
	}

	if(!$shipping_address || ref($shipping_address) ne 'HASH')
	{
		return $self->trace_error("Invalid shipping address format");
	}

	# Get the country from the new address info
	my $country = $shipping_address->{'country'};

	if(!$country)
	{
		return $self->trace_error("Country is required");
	}

	# Get a code3 for the country if we only have 2
        if(length($country) == 2)
	{
		($country) = grep { $Fap::Data::Countries::_country_list->{$_}->{'code2'} eq $country } keys %{$Fap::Data::Countries::_country_list} ;
	}

	# Validate the address info
	my @required_keys = qw/addr1 city country/;

	if(my $country_info = $Fap::Data::Countries::_country_list->{$country})
	{
		if($country_info->{'state_prov'})
		{
			# Check for a valid state/prov
			if(!$Fap::Data::Countries::_state_list->{$country}->{$shipping_address->{'state_prov'}})
			{
				return $self->trace_error("Invalid State/Prov");
			}

			push @required_keys, 'state_prov';
		}

		if($country_info->{'postal_code'})
		{
			push @required_keys, 'postal';
		}
	}
	else
	{
		return $self->trace_error("Invalid country code");
	}

	# Make sure our required address fields are filled out
	map {
		if(!$shipping_address->{$_})
		{
			my $key_str = $_;
			$key_str = join('/', map { ucfirst($_) } split('_', $key_str));
			return $self->trace_error("$key_str is required");
		}
	} @required_keys;

	# Get the order group info
	my $order_group = $self->Sales_Create_Order_order_group($order_group_id);

	if($order_group)
	{
		# We will locate this record by entity id
		my $entity_address_id = $order_group->{'shipping_address_id'};

		if($entity_address_id)
		{
			# Get and update the record
			my $record = $self->db->table('EntityAddress')->search({ 'entity_address_id' => $entity_address_id  }, { 'limit' => 1 });

			if($record && $record->first)
			{
				if($record->first->set_columns($shipping_address))
				{
					$self->write_log(level => 'DEBUG', log => [ "NEW COLS:", $record->first->get_columns ]);

					my $shipping = Fap::Order::Shipping->new();

					#$self->write_log(level => 'DEBUG', log => [ "SHIPPING NEW CALC", $c, $@ ]);
					#if($record->first->update($shipping_address))
					#{
					#	$self->write_log(level => 'VERBOSE', log => "Updated shipping address for group $order_group_id, entity $entity_address_id $@");
					#}
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not update shipping address for group $order_group_id, entity $entity_address_id: $@");
					return $self->trace_error("Could not update shipping address");
				}
			}
		}
		else
		{
			return $self->trace_error("Order group has no shipping address ID");
		}
	}
	else
	{
		return $self->trace_error("Could not find order group");
	}

	# After updating a shipping address, we need to recalculate shipping rates using Fap::Order::Shipping::calculate
	my $shipping = Fap::Order::Shipping->new();

	# 	
	if($shipping->calculate($self->Sales_Create_Order_order_info('order_id')))
	{
		if($self->Sales_Create_Order_load_order($self->Sales_Create_Order_order_info('order_id')))
		{
			return 1;
		}

		return $self->trace_error("Could not reload order details");
	}
	else
	{
		$self->write_log(level => 'ERROR', log => "Could not update shipping rates: $@");
		return $self->trace_error("Could not recalculate shipping rates");
	}
}

=head2 Sales_Create_Order_get_shipping_options

=over 4

	Retrieve shipping options from the database for a given order_group_id.

	This is useful if you have just updated an order_group's shipping info.

	Args   : $order_group_id
	Returns: $shipping_rates_array_ref

=back

=cut
sub Sales_Create_Order_get_shipping_options
{
	my($self, $order_group_id) = @_;

	if(!$order_group_id)
	{
		return $self->trace_error("Order group ID is required");
	}

	my @rates = $self->db->table('OrderShipping')->search({ order_group_id => $order_group_id }, { order_by => { -asc => 'shipping_rate' } })->all();
	
	if(@rates)
	{
		@rates = $self->db->strip(@rates);
		return \@rates;
	}
	else
	{
		return $self->trace_error("No shipping rates found");
	}	
}

=head2 Sales_Create_Order_validate_address

=over 4

	Validate an shipping or billing address

	TODO: This is just a stub that returns true

=back

=cut

sub Sales_Create_Order_validate_address
{
	my ($self, $address) = @_;

	if(!$address)
	{
		$@ = "Address is required";
		return undef;
	}

	# validate here

	return 1;
}

=head2 Sales_Create_Order_validate_order_group

=over 4

	Validate an order group's data before sending data to convert the quote to an order.

	Args   : $order_group_hash
	Returns: true or undef on failure

=back

=cut

sub Sales_Create_Order_validate_order_group
{
	my ($self, $order_group) = @_;

	return 1;
}


sub Sales_Create_Order_get_ordered_dids
{

}

=head2 Sales_Create_Order_get_available_did_regions

=over 4

	Get a list of regions available for DID numbers ( i.e. State / Province ).

	Args   : $country_code
	Returns: hashref of regions and names

	Example:

	{
		'AL' => 'Alabama',
		'AK' => 'Alaska',
		'AZ' => 'Arizona',
		'AK' => 'Arkansas',
		'CA' => 'California',
		...
		...
	}

=back

=cut

sub Sales_Create_Order_get_available_did_regions
{
	my ($self, $country_code) = @_;

	# Need an order group id
	if(!$country_code)
	{
		$self->write_log( level => 'ERROR' ,log => "Country code not provided");
		return $self->trace_error("Country code is required");
	}

	# Normalize country code to code3
	if(length($country_code) == 2)
	{
		($country_code) = grep { $Fap::Data::Countries::_country_list->{$_}->{'code2'} eq $country_code } keys %{$Fap::Data::Countries::_country_list} ;
	}

	my $regions =  $Fap::Data::Countries::_state_list->{$country_code};

	if(!$regions)
	{
		$regions = {
			'All' => "All Regions",
		};
	}

	return $regions;
	# THIS IS TODO
	#if(my $country_obj = Fap::Country->new(alpha_code => $country))
	#{
	#	if(my $regions = $country_obj->get_provider_regions())
	#	{
	#		return $regions;
	#	}
	#	else
	#	{
	#		return $self->trace_error("No regions avialable");
	#	}
	#}
	#else
	#{
	#	return $self->trace_error("Invalid country code");
	#}
}

=head2 Sales_Create_Order_get_available_area_codes

=over 4

	Get a list of available area codes for a particular country and region

	Args   : $country_code, $region
	Returns: hashref of stuff.....TODO ( States/Provinces -> [ area codes ]? )

	{
		'310' => 'Los Angeles',
		'213' => 'Los Angeles',
		'818' => 'Burbank',
	}

=back

=cut

sub Sales_Create_Order_get_available_area_codes
{
	my($self, $country_code, $region) = @_;

	if(!$country_code)
	{
		return $self->trace_error("Country code is required");
	}

	if(!$region)
	{
		return $self->trace_error("Region is required");
	}

	# Normalize country code to code3
	if(length($country_code) == 2)
	{
		($country_code) = grep { $Fap::Data::Countries::_country_list->{$_}->{'code2'} eq $country_code } keys %{$Fap::Data::Countries::_country_list} ;
	}

	# TODO - get actual area codes ( probably from database table )
	# This sample data assumes: Country code US and Region CA
	my $res = {
		"209" => "Lodi",
		"213" => "Los Angeles",
		"310" => "Cmtn Grdn",
		"323" => "Los Angeles",
		"408" => "Snjs West",
		"415" => "San Francisc",
		"424" => "Hawthorne",
		"442" => "Calexico",
		"510" => "Hayward",
		"530" => "Losmolinos",
		"559" => "Coarsegold",
		"562" => "Long Beach",
		"619" => "Sndg Sndg",
		"626" => "Psdn Psdn",
		"650" => "San Mateo",
		"657" => "Westminstr",
		"661" => "Snca Nhcs",
		"669" => "",
		"707" => "St Helena",
		"714" => "Santa Ana",
		"747" => "Brbn Brbn",
		"760" => "Palmdesert",
		"805" => "Oxnard",
		"818" => "No Hollywd",
		"831" => "Salinas",
		"858" => "La Jolla",
		"909" => "Fontana",
		"916" => "Fair Oaks",
		"925" => "Pleasanton",
		"949" => "Newportbch",
		"951" => "Murrieta",
	};

	return $res;

}

=head2 Sales_Create_Order_get_avialable_exchanges

=over 4

	Get available exchanges for given order_group_id and area code ( if supported )

	Args   : $order_group_id, $area_code
	Returns: hashref of exchanges....TODO ( City/Region -> [ exchanges ] )???

=back

=cut

sub Sales_Create_Order_get_available_exchanges
{
	my($self, $order_group_id, $area_code) = @_;

	# Need an order group id
	if(!$order_group_id)
	{
		return $self->trace_error("Order group is required");
	}

	if(!$area_code)
	{
		return $self->trace_error("Area code is required");
	}

	my $provider_string = $self->Sales_Create_Order_get_voip_provider($order_group_id);

	if(!$provider_string)
	{
		return $self->trace_error("Unable to determine VoIP provider for order group $order_group_id");
	}

	# Get a provider object
	my $provider = Fap::Provider->new(provider => $provider_string, mode => $self->config('provider.Mode'));

	# If we have a valid provider instance, then let's test to see if we can port this number
	if($provider)
	{
		# Is this feature available?
		if($provider->can('available_exchanges'))
		{
			my $exchanges = $provider->available_exchanges();

			if($exchanges)
			{
				return $exchanges;
			}
			else
			{
				return $self->trace_error("Could not retrieve exchange list from provider");
			}
		}
		else
		{
			return $self->trace_error("Unable to list available exchanges");
		}
	}
	else
	{
		return $self->trace_error("Could not initialize VoIP provider");
	}
}

=head2 Sales_Create_Order_get_available_dids

=over 4

	Get a list of avialable DID numbers for a given order_group_id, area code [ and exchange if available ].

	Args   : $order_group_id, $country_code, $region, $area_code, $start, $limit
	Reutrns: list of dids

=back

=cut
sub Sales_Create_Order_get_available_dids
{
	my($self, $order_group_id, $country_code, $region, $area_code, $start, $limit) = @_;

	if(!$order_group_id)
	{
		return $self->trace_error("Order group ID is required");
	}

	if(!$country_code)
	{
		return $self->trace_error("Country code is required");
	}

	if(!$region)
	{
		return $self->trace_error("Region is required");
	}

	if(!$area_code)
	{
		return $self->trace_error("Area code is required");
	}

	# Define default start / end criterea
	$start ||= 0;
	$limit ||= 100;

	# Normalize country code to code3
	if(length($country_code) == 2)
	{
		($country_code) = grep { $Fap::Data::Countries::_country_list->{$_}->{'code2'} eq $country_code } keys %{$Fap::Data::Countries::_country_list} ;
	}

	# Get the provider
	my $provider_string = $self->Sales_Create_Order_get_voip_provider($order_group_id);

	if(!$provider_string)
	{
		return $self->trace_error("Unable to determine VoIP provider for order group $order_group_id");
	}

	my $ret = [
		'131086143XXX',
		'131086143XXX',
		'131086143XXX',
		'131086143XXX',
		'131086145XXX',
		'131086145XXX',
		'131086147XXX',
		'131086147XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		'131086149XXX',
		];

	return $ret;

	# Get a provider object
	my $provider = Fap::Provider->new(provider => $provider_string, mode => $self->config('provider.Mode'));

	# If we have a valid provider instance, then let's test to see if we can port this number
	if($provider)
	{
		# Is this feature available?
		if($provider->can('get_available_dids'))
		{
			my $did_list = $provider->get_available_dids($country_code, $region, $area_code);

			if($did_list)
			{
				return $did_list;
			}
			else
			{
				return $self->trace_error("Could not retrieve DID list from provider");
			}
		}
		else
		{
			return $self->trace_error("Unable to list available DIDs");
		}
	}
	else
	{
		return $self->trace_error("Could not initialize VoIP provider");
	}
}

=head2 Sales_Create_Order_did_is_portable

=over 4

	Check to see if a given DID can be ported.

	This aims to be a provider independent mechanism, although this needs to be clarified.

=back

=cut
sub Sales_Create_Order_did_is_portable
{
	my($self, $order_group_id, $phone_number) = @_;

	if(!$order_group_id)
	{
		return $self->trace_error("Order group is required");
	}

	if(!$phone_number)
	{
		return $self->trace_error("Phone number is required");
	}

	my $provider_string = $self->Sales_Create_Order_get_voip_provider($order_group_id);

	if(!$provider_string)
	{
		return $self->trace_error("Unable to determine VoIP provider for order group $order_group_id");
	}

	# Get a provider object
	my $provider = Fap::Provider->new(provider => $provider_string, mode => $self->config('provider.Mode'));

	# If we have a valid provider instance, then let's test to see if we can port this number
	if($provider)
	{
		# Is this feature available?
		if($provider->can('lnp_isportable'))
		{
			# Can we port it?
			if($provider->lnp_isportable($phone_number))
			{
				# Yes we can
				return 1;
			}

			# Nope, can't port this number
			return undef;
		}
		else
		{
			# We just return true and assume we can port it
			return 1;
		}
	}
	else
	{
		return $self->trace_error("Could not initialize VoIP provider");
	}

}

=head2 Sales_Create_Order_phone_reprovision_list

=over 4

	Get number of reprovisioned phones if any for an order group

	Args   : $order_group_id
	Returns: arrayref of reprov phone bundles

=back

=cut
sub Sales_Create_Order_phone_reprovision_list
{
	my ($self, $order_group_id) = @_;

	my $order_group = $self->Sales_Create_Order_order_group($order_group_id);

	if($order_group)
	{
		my $order_bundles = $order_group->{'order_bundles'};

		my $phone_count = 0;

		foreach my $order_bundle ( @{$order_bundles} )
		{
			my $bundle = Fap::Bundle->new(
				bundle_id => $order_bundle->{'bundle_id'},
				fcs_schema => $self->db,
			);

			if (defined($bundle) && $bundle->is_reprovisioned_phone_bundle()) {
				$phone_count += $order_bundle->{'quantity'};
			}
		}

		return $phone_count;
	}
	else
	{
		return undef;
	}

}

=head2 Sales_Create_Order_requires_credit_approval

=over 4

	Test to see if the quote requires a credit check

	Args   : $order_id
	Returns: true if required or undef if approval is not required

=back

=cut
sub Sales_Create_Order_requires_credit_approval
{
	my $self = shift;

	if($self->Sales_Create_Order_order_is_loaded)
	{
		my $status = $self->Sales_Create_Order_order_info->('credit_approval_status_id');

		if($status)
		{
			my $status_detail = $self->db->table('OrderStatus')->find({ order_status_id => $status });

			if($status_detail)
			{
				if(uc($status_detail->name) eq 'NOT REQUIRED' || uc($status_detail->name) eq 'APPROVED')
				{
					return undef;
				}

				return 1;
			}

			return 1;
		}
		else
		{
			return 1;
		}
	}

	return 1;
	
}

=head2 Sales_Create_Order_validation_mac_address

=over 4

	Validate a given MAC address

	Args   : $mac_address
	Returns: true or undef on failure

=back

=cut
sub Sales_Create_Order_validate_mac_address
{
	my($self, $mac_address) = @_;

	if(!$mac_address)
	{
		return $self->trace_error("MAC address is required");
	}

	if($mac_address =~ /^[A-F0-9]{12}$/)
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 Sales_Create_Order_send_echosign

=over 4

	Send an EchoSign agreement for a loaded order

	Args   : none
	Returns: true or undef on failure

=back

=cut
sub Sales_Create_Order_send_echosign
{
	my $self = shift;

	if(my $order_group_id = $self->Sales_Create_Order_get_primary_order_group_id())
	{
		$self->write_log(level => 'DEBUG', log => "Found primary order group ID $order_group_id");	

		my $echosign = Fap::Order::EchoSign->send($order_group_id);

		$self->write_log(level => 'DEBUG', log => [ "Send EchoSign response: ", $echosign ]);

		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 Sales_Create_Order_get_echosign

=over 4

	Get the details about a sent echo sign for an order

	Args   : none
	Returns: hashref of echosign data

=back

=cut
sub Sales_Create_Order_get_echosign
{
	my $self = shift;


}

=head2 Sales_Create_Order_get_primary_order_group_id

=over 4

	Get the primary order group ID for a loaded order

	Args   : none
	Returns: order_group_id or undef on failure

=back

=cut
sub Sales_Create_Order_get_primary_order_group_id
{
	my $self = shift;

	if($self->Sales_Create_Order_order_is_loaded())
	{
		if(my $order_groups = $self->Sales_Create_Order_order_info('order_group'))
		{
			if(my $first_order_group = $$order_groups[0])
			{
				return $first_order_group->{'order_group_id'};
			}
			else
			{
				return $self->trace_error("Could not find primary order group");
			}
		}
		else
		{
			return $self->trace_error("Order does not contain any order group entries");
		}
	}
	else
	{
		return $self->trace_error("Order ID must be loaded");
	}
}

# This one too - although there is a Fap::Billing;:CreditCard module that appears to do what is needed.
sub Create_Order_charge_credit_card
{
	
}

=head2 Sales_Create_Order_get_payment_methods

=over 4

	Retrieve list of payment methods and id numbers.

	Args   : none
	Returns: arrayref of payment method hashes

=back

=cut
sub Sales_Create_Order_get_payment_methods
{
	my $self = shift;
	my @payment_methods = $self->db->table('PaymentMethod')->all();
	@payment_methods = $self->db->strip(@payment_methods);
	return \@payment_methods;
}

=head2 Sales_Create_Order_get_voip_provider

=over 4

	Retrieve the VoIP provider for the given order group id

	Args   : $order_group_id
	Returns: $provider_name_str

=back

=cut
sub Sales_Create_Order_get_voip_provider
{
	my($self, $order_group_id) = @_;

	if($order_group_id)
	{
		my $order_group = $self->Sales_Create_Order_order_group($order_group_id);

		if($order_group)
		{
			my $country_code = $order_group->{'shipping_address'}[0]->{'country'};

			my $country = Fap::Country->new('alpha_code' => $country_code);

			if($country)
			{
				my $providers = $country->get_voip_provider();

				if($providers)
				{
					foreach my $voip ( @{$providers} )
					{
						my $voip_bundle = Fap::Bundle::get_bundle_with_name($voip);

						if(grep {$_->{'bundle_id'} == $voip_bundle->{'bundle_id'}} @{$order_group->{'order_bundles'}})
						{
							# Return lower case provider string
							return lc($voip);
						}
					}

					# Default to first provider??
					my $provider = $$providers[0];

					return lc($provider);
				}
				else
				{
					return $self->trace_error("No VoIP provider available");
				}
			}
			else
			{
				return $self->trace_error("No VoIP data available for country");
			}
		}
		else
		{
			return $self->trace_error('Order group not found');
		}
	}
}

sub Sales_Create_Order_init_permissions
{
	my $self = shift;

	my $perm = {
		GLOBAL => 1,
		GUEST => 1,
		DESC => 'Order Tool',
		PERMISSIONS => # Application Permissoins
		{
			'send_echosign' =>
			{
				LEVELS => 'w',
				NAME => 'Send EchoSign Agreement',
				DESC => 'This allows the user to send an EchoSign agreement for the order.',
			},
		},
		LEVELS => 'r',
		VERSION => 2
	};


	return $perm;
}


1;
