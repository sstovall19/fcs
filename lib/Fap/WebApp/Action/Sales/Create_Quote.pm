#!/usr/bin/perl

use strict;

# Fap namespace libs
use Fap::Bundle::Relationships;
use Fap::Data::Countries;
use Fap::StateMachine::Client;
use Fap::Order::Discounts;

# 3rd party libs
use Try::Tiny;
use LWP::UserAgent;
use Data::Dumper;

sub process_Create_Quote
{
	my $self = shift;

	$self->title('Create a quote');

	my $action = $self->valid->param('action');

	if($action eq 'reset_quote')
	{
		$self->reset_quote;
		return $self->redirect('/?m=Sales.Create_Quote');
	}
	elsif($action eq 'retrieve_quote')
	{
		my $quote_id = $self->valid->param('quote_id', 'numbers');

		if($quote_id)
		{
			print STDERR "RESET\n";
			$self->reset_quote;
			print STDERR "LOAD";
			my $quote = $self->load_quote($quote_id);
			  print STDERR "DEPLOY";
			$self->server_quote_deployment($quote->{'product_id'});	
		                        print STDERR "REDIRECT";

		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Attempt to retrieve quote without quote_id");
			$self->alert('Invalid quote ID');
		}

		return $self->redirect('/?m=Sales.Create_Quote');
	}
	elsif($action eq 'calculate_discounts')
	{
		# Get and set prepay and term data - this may already be populated, but may have changed
		my $prepay_amount = $self->valid->param('prepay_amount');
		my $term_in_months = $self->valid->param('term_in_months');

		# If we have new values for prepay and terms, let's set them in the session
		$self->quote_prepay_amount($prepay_amount) if defined($prepay_amount);
		$self->quote_term_in_months($term_in_months) if defined($term_in_months);

		# Get json data from the AJAX request - if no "form_data" is present, it will automatically use the stored session data
		my $quote_json = $self->query->param('form_data') || $self->Create_Quote_build_quote_json();
		my $quote_data = $self->json_decode($quote_json);

		# Get discounts from DB
		my $res = $self->Create_Quote_get_discounts($quote_data);

		# Check status	
		if($res)
		{
			$self->write_log(level => 'DEBUG', log => [ "RECEIVED DISCOUNT INFO:", $res ]);
			return $self->json_process({ status => 1, results => $res });
		}
		else
		{
			return $self->json_process({ 'error' => 'Invalid server response' });
		}
	}
	elsif($action eq 'bundle_list')
	{
		my $key = "deployment_bundle_list-".($self->valid->param('deployment_id', 'numbers')||$self->server_quote_deployment());
		my $ret = $self->db->cache->get($key);
		if (!$ret) {
			my $deployment = $self->valid->param('deployment_id', 'numbers') || $self->server_quote_deployment();
	
			if($deployment)
			{
                		$self->server_quote_deployment($deployment);
                		$self->write_log(level => 'VERBOSE', log => "Chose deployment ID $deployment");

				# Get bundles and dependencies from REST api
				my $data = $self->Create_Quote_get_categories($deployment);

	                	my $bundle_relationships = Fap::Bundle::Relationships->new();
	
				$ret = {
					status => 1, 
					bundles => { 
						'categories', => $data, 
						'bundle_relationships' => [ $bundle_relationships->get_relationships ] 
					}
				};
				$self->db->cache->set($key,$ret,7200);
			}
			else
			{
				$ret = { 'error' => 'Deployment is required' };
			}
		}
		return $self->json_process($ret);
	}
	elsif($action eq 'state_prov_list')
	{
		  my $ret = $self->db->cache->get("state_prov_list-".$self->valid->param('country'));
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

	# Default to the select product screen if one hasn't been selected yet
	if($action ne 'select_deployment' && !$self->server_quote_deployment)
	{
		$action = 'display_deployment_form';
	}

	# Display deployment ( Product ) screen
	if($action eq 'display_deployment_form')
	{
		my @res = $self->db->table("Product")->all();
        	my @stripped = $self->db->strip(@res);
		$self->tt_append(var => 'deployments', val => \@stripped);
	}
	elsif($action eq 'save_progress')
	{
		# Save progress always sends the prepay and term values, so save these to the session for later retrieval
		my $prepay_amount = $self->valid->param('prepay_amount');
		my $term_in_months = $self->valid->param('term_in_months');

		$self->quote_prepay_amount($prepay_amount) if defined($prepay_amount);
		$self->quote_term_in_months($term_in_months) if defined($term_in_months);

		# Get / Set current server
		my $server = $self->quote_server_number;

		# Bundle / Shipping / Contact data
		my $data = $self->query->param('form_data');

		# Save data to the session
		$self->write_log(level => 'DEBUG', log => [ 'QUOTE DATA RECEIVED FOR PROGRESS UPDATE:', $data] )	;
		$self->server_quote($server, $data);

		return $self->json_process({ success => 1 });
	}
	elsif($action eq 'save_pre_form_category')
	{
		# Pre form categories are displayed one by one before displaying the item category list

		# Get / Set current server
		my $server = $self->quote_server_number;

		# Get form data
		my $data = $self->query->param('form_data');

		# What category are we saving?
		my $category = $self->query->param('category');

		$self->write_log(level => 'DEBUG', log => [ "RECIEVED UPDATE FOR PRE_FORM_CATEGORY: $category", $data ] );
	
		# Save pre-form category data
		$self->pre_form_category($category, $data);

		return $self->json_process({ success => 1 });
	}
	elsif($action eq 'change_server')
	{
		my $server_number = $self->valid->param('server');
		$self->quote_server_number($server_number);
	}
	elsif($action eq 'select_deployment')
	{
		my $deployment = $self->valid->param('deployment_id', 'numbers');
		$self->server_quote_deployment($deployment);
		$self->write_log(level => 'VERBOSE', log => "Chose deployment ID $deployment");
		return $self->redirect('/?m=Sales.Create_Quote');
	}
	elsif($action eq 'complete')
	{
		my $quote = $self->server_quote;


		# Clear the quote session info
		$self->reset_quote;

		$self->tt_append(var => 'GUID', val => 1);
		$self->tt_append(var => 'QUOTE',  val => $self->Create_Quote_build_quote_hash );

		return $self->tt_process('Sales/Create_Quote.tt');
	}
	elsif($action eq 'apply_discount')
	{
		# Apply a discount - for use by sales

		# Make sure the user has permission
		if($self->has_permission('manager_discount', 'w'))
		{
			# Get discount value
			my $discount = $self->valid->param('discount', 'price');

			if(defined $discount)
			{
				# Set discount
				if($self->quote_manager_discount($discount))
				{
					$self->audit(customer_id => '', server_id => '', log => "Applied manager discount of $discount% to quote");

					$self->write_log(level => 'VERBOSE', log => "Applied manager discount of $discount% to quote");
					return $self->json_process({
						success => 1
					});
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Failed to apply discount to quote: $@");

					return $self->json_process({
						error => $@
					});
				}
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Invalid discount amount: $discount");

				return $self->json_process({
					error => 'Invalid discount amount.  Please enter a valid number.'
				});
			}
		}
		else
		{
			$self->write_log(level => 'DEBUG', log => "No permission to add discount");
			return $self->json_process({
				error => 'You do not have the appropriate permissions to apply discounts.'
			});
		}
	}
	elsif($action eq 'calculate_shipping')
	{
		# Get server number
		my $server = $self->quote_server_number;

		# Get quote data
		my $quote = $self->server_quote($server);

		my $j_items = $self->json_decode($quote);
		my $items = [];

		map {
			push(@{$items}, $j_items->{$_});
		} keys %{$j_items};

		my $shipping = $self->json_decode($self->server_shipping($server));

		$self->write_log(level => 'DEBUG', log => [ "QUOTE INFO", $quote, "SHIPPING INFO", $shipping ] );

		#my $shipping_calculator = Fap::Shipping->new();
		#my $rates = $shipping_calculator->_GetUPSRate($shipping, $items);
		my $rates = {};
		return $self->json_process({
			services => $rates
		});
	}
	elsif($action eq 'save_shipping')
	{
		# Get server number
		my $server = $self->quote_server_number;

		# Get form data
		my $data = $self->query->param('form_data');

		$self->write_log(level => 'DEBUG', log => [ "Got shipping info for server $server:", $data]);

		# Save form data
		$self->server_shipping($server, $data);

		return $self->json_process({ success => 1 });
	}
	elsif($action eq 'save_contact')
	{
		# Get server number
		my $server = $self->quote_server_number;

		# Get form data
		my $data = $self->query->param('form_data');

		$self->write_log(level => 'DEBUG', log => [ "Got contact information for server $server:", $data ]);

		# Save contact info
		$self->quote_contact($data);

		return $self->json_process({ success => 1 });
	}
	elsif($action eq 'submit_quote')
	{
		# Step 1 - Save data to session
		# Step 2 - Load data from session
		# Step 3 - Re-format data
		# Step 4 - validate data
		# Step 5 - Insert into SM
		# Step 6 - Provide feedback

		# Get form data
		my $contact_data = $self->query->param('contact');
		my $shipping_data = $self->query->param('shipping');
		my $bundles = $self->query->param('bundles');
		
		my $prepay_amount = $self->valid->param('prepay_amount');
		my $term_in_months = $self->valid->param('term_in_months');

		# Save contact information
		if($self->json_decode($contact_data))
		{
			$self->quote_contact($contact_data);
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Contact information not provided");
			return $self->json_process({ success => undef, error_msg => 'Contact information was not provided' });
		}

		# Save shipping data
		if($self->json_decode($shipping_data))
		{
			$self->server_shipping($self->quote_server_number, $shipping_data);
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Shipping information not provided");
			return $self->json_process({ success => undef, error_msg => 'Shipping information was not provided' });
		}

		# Save bundles
		if($self->json_decode($bundles))
		{
			# Save data to the session
			$self->server_quote($self->quote_server_number, $bundles);
		}

		# Apply discount(s)
		$self->quote_prepay_amount($prepay_amount) if defined($prepay_amount);
		$self->quote_term_in_months($term_in_months) if defined($term_in_months);

		
		# Submit the quote to the SM
		my $res = $self->Create_Quote_submit_quote();
	
		if ($res)
		{
			if($res->{'status'} == 1)
			{
				return $self->json_process({ success => $res->{'status'} });
			}
			else
			{
				return $self->json_process({ error_msg => $@ });
			}
		}
		else
		{
		    return $self->json_process({ error_msg => $@ });
		}

	}

	# If the deployment is set, we're ready to display the form ( or at least pre-form categories )
	if(my $deployment = $self->server_quote_deployment)
	{
		# Get items for the selected deployment ( this is a product now ).
		my $data = $self->Create_Quote_get_categories($deployment);

		# Build pre form category list from the retrieved data - pre_form_category checks to see if each category has already been completed
		my @pre_form_categories = grep { $_->{'display_type'} eq 'pre_panel' && !$self->pre_form_category($_->{'category_id'})} @{$data};
	
		$self->write_log(level => 'DEBUG', log => [ "PRE PANEL CATEGORIES", \@pre_form_categories ]);	

		# Add the preform categories to the template
		if(@pre_form_categories)
		{
			$self->tt_append(var => 'pre_form_categories', val => \@pre_form_categories);
		}
		elsif(!$self->pre_form_categories_complete()) # Populate the session with any pre form category data that we have
		{
			my %pre_data;

			map {
				my $json = $self->pre_form_category($_->{'category_id'});

				$self->write_log(level => 'DEBUG', log => [ "PRE FORM DATA RETRIEVED FOR CAT: ".$_->{'category_id'}, $json ]);

				if($json)
				{
					$json = $self->json_decode($json);
					$pre_data{$_} = $json->{$_} for keys %{$json};
					$self->write_log(level => 'DEBUG', log => [ "JSON DATA:", $json ]);
				}

			} @{$data};

			$self->write_log(level => 'DEBUG', log => [ "PRE FORM DATA TO POPULATE SESSION WITH", \%pre_data ]);

			if(keys %pre_data)
			{
				my $pre_json = $self->json_encode(\%pre_data);
				my $server = $self->session->param('current_server') || 1;
				$self->session->param('current_server', $server);

				$self->write_log(level => 'DEBUG', log => [ 'GOING TO INSERT THIS PRE FORM JSON INTO THE SESSION', $pre_json ] );
				$self->server_quote($server, $pre_json);
			}

			$self->pre_form_categories_complete(1);
		}

		# These things are only needed if we are showing the category form - when all pre-form categories are complete
		if($self->pre_form_categories_complete)
		{
			# We need to pull all of this data from the collector for the template - which can be time consuming, but necessary
			$self->tt_append(var => 'state_list', val => $Fap::Data::Countries::_state_list->{'USA'});
			$self->tt_append(var => 'country_list', val => $Fap::Data::Countries::_country_list);
			$self->tt_append(var => 'discounts', val => $self->Create_Quote_get_discounts);
		}

		# Get all bundle relationships for the UI to handle
		my $bundle_relationships = Fap::Bundle::Relationships->new();

		# Add deployment, categories and the bundle relationships to the template vars
		$self->tt_append(var => 'categories', val => $data);
		$self->tt_append(var => 'categories_json', val => $self->json_encode($data,1));
		$self->tt_append(var => 'bundle_relationships', val => $bundle_relationships->get_relationships);
		$self->tt_append(var => 'bundle_relationships_json', val => $self->json_encode($bundle_relationships->get_relationships,1));
		$self->tt_append(var => 'selected_deployment', val => $deployment);

		# We need to possibly pre-populate pre-pay and term fields
		$self->tt_append(var => 'prepay_amount', val => $self->quote_prepay_amount);
		$self->tt_append(var => 'term_in_monts', val => $self->quote_term_in_months);
	}

	if($self->valid->param('to_json'))
	{
		return $self->json_process;
	}

	return $self->tt_process('Sales/Create_Quote.tt');
}

=head2 quote_server_number

=over 4

	Get or set the current server ID being worked on

	Args   : [ $server_number ]
	Returns: $server_number

=back

=cut
sub quote_server_number
{
	my $self = shift;
	my $server = shift;

	if($server)
	{
		$self->session->param('current_server', $server);
	}
	else
	{
		$server = $self->session->param('current_server');
		
		if(!$server)
		{
			$server = 1;
			$self->session->param('current_server', $server);
		}
	}
	
	return $server;
}

=head2 Create_Quote_get_discounts

=over 4

	Get discount data from the collector

	Args   : [ $quote_json ]
	Returns: $discount_data

=back

=cut
sub Create_Quote_get_discounts
{
	my($self, %params) = @_;

	my $bundles = $params{'bundles'};
	my $quote_id = $params{'quote_id'};

	my $discount;

	if($quote_id)
	{
		$discount = Fap::Order::Discounts->license_discount(order_id => $quote_id);
	}
	else
	{
		$discount = Fap::Order::Discounts->license_discount(input => $bundles);
	}

	if($discount && ref($discount) eq 'HASH')
	{
		return $discount;
	}
	else
	{
		return $self->trace_error($@);
	}
}

=head2 pre_form_category

=over 4

	Get or set pre form category block data

	Args   : $category, $json_data
	Returns: $category_json_data

=back

=cut
sub pre_form_category
{
	my ($self, $category, $data) = @_;

	if(!$category)
	{
		$@ = "No category provided";
		return undef;
	}

	$self->write_log(level => 'DEBUG', log => "REQUEST FOR PRE FORM CATEGORY DATA: $category");
	$self->{'QUOTE_INFO'} ||= $self->session->param('server_quote');

	if($data)
	{
		$self->{'QUOTE_INFO'}->{'PRE_FORM_CATEGORY'}->{$category} = $data;
		$self->save_quote_session;
		$self->write_log(level => 'DEBUG', log => "Marked pre-form category $category as complete.");
	}

	return $self->{'QUOTE_INFO'}->{'PRE_FORM_CATEGORY'}->{$category};
}

=head2 pre_form_categories_complete

=over 4

	Get or set complete flag for pre form categories

	Args   : [ $complete ]
	Returns: $complete_flag

=back

=cut 
sub pre_form_categories_complete
{
	my($self, $complete) = @_;

	$self->{'QUOTE_INFO'} ||= $self->session->param('server_quote');

	if($complete)
	{
		$self->{'QUOTE_INFO'}->{'PRE_FORM_CATEGORY_COMPLETE'} = $complete;
		$self->save_quote_session;
		$self->write_log(level => 'DEBUG', log => "Marked pre form categories complete");
	}

	return $self->{'QUOTE_INFO'}->{'PRE_FORM_CATEGORY_COMPLETE'};
}

=head2 build_quote_json

=over 4

	Build JSON structure to be sent to the collector from the user's session

	Args   : none
	Returns: $json_quote_data

=back

=cut
sub Create_Quote_build_quote_json
{
	my $self = shift;

	# Get quote hash
	my $quote_hash = $self->Create_Quote_build_quote_hash();

	# Convert to JSON
	my $quote_json = $self->json_encode($quote_hash, 1);

	return $quote_json;
}

=head2 Create_Quote_build_quote_hash

=over 4

	Build HASH structure from the user's session

	Args   : none
	Returns: $quote_data_hash

=back

=cut
sub Create_Quote_build_quote_hash
{
	my $self = shift;
	my $quote_submit = {};

	my $quote = $self->session->param('server_quote');

	# Get product and order ids
	my $product_id = $self->server_quote_deployment;
	my $order_id = $self->order_id;

	# Define order_group as an arrayref.  We'll store each server's info here
	$quote_submit->{order_group} = [];

	# Loop through servers
	foreach my $server ( keys %{$quote->{'SERVERS'}} )
	{
		# Grap items
		my $items = $quote->{'SERVERS'}->{$server};

		if($items)
		{
			# Convert from JSON
			$items = $self->json_decode($items);
		}

		my $tmp = [];

		map {
			push(@{$tmp}, $items->{$_});
		} keys %{$items};

		# Get shipping info for server
		my $shipping = $self->server_shipping($server);

		if($shipping)
		{
			$shipping = $self->json_decode($shipping);
		}

		# Add data to the quote ( product, bundle and shipping )
		push(@{$quote_submit->{order_group}}, { 
			product_id => $product_id, 
			bundle => $tmp, 
			shipping => $shipping, 
		});
	}

	# Add contact info
	my $contact = $quote->{'CONTACT'};

	if($contact)
	{
		$quote_submit->{'contact'} = $self->json_decode($contact);
	}

	# Add order id
	$quote_submit->{'order_id'} = $order_id || '';

	# Add discount
	$quote_submit->{'discount_percent'} = $self->quote_manager_discount();
	$quote_submit->{'max_discount_percent'} = $self->max_discount_percentage();

	# Add term
	$quote_submit->{'term_in_months'} = $self->quote_term_in_months || 12;

	# Add prepay amount
	$quote_submit->{'prepay_amount'} = $self->quote_prepay_amount || 0;

	return $quote_submit;
}

sub max_discount_percentage
{
	my $self = shift;
	return 20;
}

sub max_discount_percentage
{
	my $self = shift;
	return 20;
}

=head2 load_quote

=over 4

	Load an existing quote from the collector

	Args   : $quote_id
	Returns: $json_quote_data

=back

=cut
sub load_quote
{
	my $self = shift;
	my $quote_id = shift;

	#my $data = $self->collector_api_get($uri);
	my $data;

	if($data)
	{
		my $location_number = 0;
		my $res = $data->{'results'};
		foreach my $location ( @{$res->{'order_group'}} )
		{
			$location_number++;

			my %bundles;

			map {
				$bundles{$_->{'bundle_id'}}{'value'} = $_->{'quantity'};
				$bundles{$_->{'bundle_id'}}{'id'} = $_->{'bundle_id'};
			} @{$location->{order_bundles}};

			my $order_bundles = $self->json_encode(\%bundles);
			my $shipping = $self->json_encode($location->{'address'}[0]);

			$self->server_quote($location_number, $order_bundles);
			$self->server_shipping($location_number, $shipping);
		}

		my $contact = $self->json_encode($res->{'contact'});
		$self->quote_contact($contact);

		$self->session->param('current_server', 1);
		$self->order_id($res->{'order_id'});
		return $data->{'results'};
	}
	else
	{
		$@ = "API Call failed";
		return undef;
	}
	
}

sub is_reseller
{
	my $self = shift;

	return undef;
}

sub server_quote
{
	my $self = shift;
	my $server = shift;
	my $data = shift;

	if(!$server)
	{
		return undef;
	}

	$self->{QUOTE_INFO} ||= $self->session->param('server_quote');

	if($data)
	{
		$self->{QUOTE_INFO}->{SERVERS}->{$server} = $data;
		$self->save_quote_session;
		$self->write_log(level => 'DEBUG', log => [ "Saved quote info for server $server", $data ]);
	}

	return $self->{QUOTE_INFO}->{SERVERS}->{$server};
}

sub server_shipping
{
	my ($self, $server, $data) = @_;

	if(!$server)
	{
		$@ = "Current server is required";
		return undef;
	}

	$self->{QUOTE_INFO} ||= $self->session->param('server_quote');

	if($data)
	{
		$self->{QUOTE_INFO}->{SHIPPING}->{$server} = $data;
		$self->save_quote_session;
	}

	return $self->{QUOTE_INFO}->{SHIPPING}->{$server};
}

sub order_id
{
	my($self, $order_id) = @_;

	$self->{QUOTE_INFO} ||= $self->session->param('server_quote');

	if($order_id)
	{
		$self->{QUOTE_INFO}->{ORDER_ID} = $order_id;
		$self->save_quote_session;
	}

	return $self->{QUOTE_INFO}->{ORDER_ID};
}

=head2 quote_prepay_amount

=over 4

	Get or set the prepay amount in the session

	Args   : [ $prepay_amount_in_percentage ]
	Returns: $prepay_percentage

=back

=cut
sub quote_prepay_amount
{
	my($self, $prepay_amount) = @_;

	$self->{'QUOTE_INFO'} ||= $self->session->param('server_quote');

	if(defined $prepay_amount)
	{
		$self->write_log(level => 'DEBUG', log => "Setting prepay amount to $prepay_amount");
		$self->{'QUOTE_INFO'}->{'PREPAY_AMOUNT'} = $prepay_amount;
		$self->save_quote_session;
	}

	return $self->{'QUOTE_INFO'}->{'PREPAY_AMOUNT'};
	
}

=head2 quote_term_in_months

=over 4

	Get or set the term in the session

	Args   : [ $term_in_monts ]
	Returns: $term_in_monts

=back

=cut
sub quote_term_in_months
{
	my($self, $term_in_months) = @_;

	$self->{'QUOTE_INFO'} ||= $self->session->param('server_quote');

	if($term_in_months)
	{
		$self->write_log(level => 'DEBUG', log => "Setting term in months to $term_in_months");
		$self->{'QUOTE_INFO'}->{'TERM_IN_MONTHS'} = $term_in_months;
		$self->save_quote_session;
	}

	return $self->{'QUOTE_INFO'}->{'TERM_IN_MONTHS'};
}

=head2 quote_manager_discount

=over 4

	Apply / Retrieve a manager discount

	Args   : [ $discount_percentage ]
	Returns: $discount_percentage

=back

=cut
sub quote_manager_discount
{
	my($self, $discount) = @_;

	$self->{'QUOTE_INFO'} ||= $self->session->param('server_quote');

	if(defined $discount)
	{
		$self->{'QUOTE_INFO'}->{'DISCOUNT'} = $discount;
		$self->save_quote_session;
	}
	else
	{
		$self->write_log(level => 'DEBUG', log => "RETURNING QUOTE_INFO DISCOUNT: " . $self->{'QUOTE_INFO'}->{'DISCOUNT'});
	}

	$self->{'QUOTE_INFO'}->{'DISCOUNT'} ||= 0;

	return $self->{'QUOTE_INFO'}->{'DISCOUNT'};
}

=head2 quote_contact

=over 4

	Set the contact information for the order

	Args   : $contact_json

=back

=cut
sub quote_contact
{
	my ($self, $data) = @_;

	if(!$data)
	{
		$@ = "No contact information provided";
		return undef;
	}

	$self->{QUOTE_INFO} ||= $self->session->param('server_quote');

	if($data)
	{
		$self->{QUOTE_INFO}->{CONTACT} = $data;
		$self->write_log(level => 'DEBUG', log => [ "GOT NEW CONTACT DATA:", $self->{QUOTE_INFO}->{CONTACT} ]);
		$self->save_quote_session;
	}

	return $self->{QUOTE_INFO}->{CONTACT};
}

sub save_quote_session
{
	my $self = shift;
	return $self->session->param('server_quote', $self->{'QUOTE_INFO'});
}

sub server_quote_category
{
	my $self = shift;
	my $server = shift;
	my $category = shift;

	
}

=head2 reset_quote

=over 4

	Reset the quote session

=back

=cut
sub reset_quote
{
	my $self = shift;
	$self->session->clear('server_quote');
	$self->session->clear('dev');
}

sub server_quote_product
{
	my $self = shift;
	my $product = shift;

	$self->{QUOTE_INFO} ||= $self->session->param('server_quote');

	if($product)
	{
		$self->{QUOTE_INFO}->{PRODUCT} = $product;
		$self->session->param('server_quote', $self->{QUOTE_INFO});
	}
	else
	{
		$product = $self->{QUOTE_INFO}->{PRODUCT};
	}

	return $product;
}

=head2 server_quote_deployment

=over 4

	Get / Set the deployment for the quote

	Args   : [ $deployment ]
	Returns: $deployment

=back

=cut
sub server_quote_deployment
{
	my $self = shift;
	my $deployment = shift;

	$self->{QUOTE_INFO} ||= $self->session->param('server_quote');

	if($deployment)
	{
		$self->{QUOTE_INFO}->{DEPLOYMENT} = $deployment;
		$self->session->param('server_quote', $self->{QUOTE_INFO});
	}
	else
	{
		$deployment = $self->{QUOTE_INFO}->{DEPLOYMENT};
	}

	$self->write_log(level => 'DEBUG', log => "DEPLOYMENT IS : $deployment");
	return $deployment;
}

sub Sales_Create_Quote_init_permissions
{
	my $perm = {
		GLOBAL => 1,
		GUEST => 1,
		DESC => 'Quote and Order Tool',
		PERMISSIONS => # Application Permissoins
		{
			'mix_and_match' =>
			{
				LEVELS => 'w',
				NAME => 'Mix and Match License Options',
				DESC => 'This allows the user to select multiple license types per server.',
			},
			'manager_discount' =>
			{
				LEVELS => 'w',
				NAME => 'Manager Discounts',
				DESC => 'Apply manager discounts to quotes / orders.',
			},
		},
		LEVELS => 'r',
		VERSION => 18
	};


	return $perm;
}


=head2 Create_Quote_get_categories

=over 4

	Retrieve a list of items.for a product

	Args   : $product_id
	Returns: arrayref of categories and items
	
=back

=cut
sub Create_Quote_get_categories
{
	my($self, $product_id) = @_;

	if(!$product_id)
	{
		return $self->trace_error("Product ID is required");
	}

	my @res = $self->db->table("OrderCategory")->search(
		{
			product_id => $product_id
		},
		{
			prefetch => [
				{
					label_xref=>{label=>{"bundles"=>{"bundle_price_models"=>"price_model"}}}	
				},
			],
		}
	);

	my @categories = $self->db->strip(@res);

	return \@categories;
}

=head2 Create_Quote_submit_quote

=over 4

	Submit a quote to the State Machine

	Args   : none
	Returns: true or undef on failure

=back

=cut
sub Create_Quote_submit_quote
{
	my $self = shift;

	my $data = $self->Create_Quote_build_quote_json();

	if($data)
	{
		# Get state machine ip and port or use defaults
		my $host = $self->config('statemachine.host') || '127.0.0.1';
		my $port = $self->config('statemachine.port') || '50005';

		my $sm = Fap::StateMachine::Client->new(host => $host, port => $port);

		if($sm)
		{
			my $ping = $sm->ping();

			if($ping->{'status'} == 1)
			{
				my $transaction = $sm->submit_and_run_transaction('QUOTE',$data);

				$self->write_log(level => 'DEBUG', log => [ "SM Response", $transaction, "DATA", $data ] );

				if($transaction && $transaction->{'status'} == 1)
				{
					return $transaction;
				}
				else
				{
					return $self->trace_error("Could not create collection");
				}
			}
			else
			{
				return $self->trace_error('Could not establish connection');
			}
		}
		else
		{
			return $self->trace_error('Could not create transaction instance');
		}
	}
	else
	{
		return $self->trace_error("No quote information has been selected");
	}
}

1;
