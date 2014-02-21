#!/usr/bin/perl
use strict;
use warnings;
use Fap::StateMachine::Unit;
use Fap::StateMachine;
use Fap::Order;
use Fap::View::TT;
use Fap::Net::Email;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
    my ($package, $client, $input) = @_;
    my $fcs_schema = Fap::Model::Fcs->new();
    my $testmode = $client->options->{t} ? 'test' : undef;

    my $conf=Fap::ConfLoader->load("bu/verify_order");
    my $order = Fap::Order->new('order_id' => $input->{order_id}, 'fcs_schema' => $fcs_schema);
    my $orderDetails = $order->get_details();
    my $salesrep = $fcs_schema->table("NetsuiteSalesperson")->single({netsuite_id=>$orderDetails->{order}->{netsuite_salesperson_id}});

    # Validate our config.
    if (!validate_config($conf))
    {
        $client->displayfailure($@);
    }

    # Validate the order.
    if (!validate_order($order, $orderDetails, $fcs_schema, $input->{order_id}, $salesrep, $testmode))
    {
        $client->displayfailure($@);
    }

    # Change all approval columns to Pending status if currently Required.
    $orderDetails = set_required($order, $orderDetails);
    $client->displayfailure("Could not get order details: $@") if (!defined($orderDetails));

    # Use the override emails if we are in test mode.
    my $salesrep_email = (defined($conf->{sales_rep_override}) && (defined($testmode))) ? $conf->{sales_rep_override} : $salesrep->email;
    my $sales_manager_email = (defined($conf->{sales_manager_override}) && (defined($testmode))) ? $conf->{sales_manager_override} : $conf->{sales_manager_email};
    my $billing_email = (defined($conf->{billing_override}) && (defined($testmode))) ? $conf->{billing_override} : $conf->{billing_email};

    # Email sales rep when an order_status is NEW, then set it to "In Progress" and reload the details.
    if ($orderDetails->{order}->{order_status}->{name} eq 'New')
    {
        if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{order_submitted_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                              'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>$salesrep_email,
                                              'subject'=>'An order was submitted!')))
            { $client->displayfailure("Could not email."); }
        $client->displayfailure("Could not set order status: $@") if (!defined($order->set_status('In Progress')));
        $orderDetails = $order->get_details();
        $client->displayfailure("Could not get order details: $@") if (!defined($orderDetails));
    }
         
    if (defined($orderDetails->{order}->{credit_approval_status}->{name}))
    {
        # Does the credit check need to happen?
        if ($orderDetails->{order}->{credit_approval_status}->{name} eq 'Pending')
        {
            if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{credit_check_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                                  'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>join(",", $salesrep_email, $billing_email),
                                                  'subject'=>'An order needs credit check!')))
                { $client->displayfailure("Could not email."); }
            $client->displaysuccessHalt("Halting for credit check.");
        }

        # Did the credit check get rejected?
        if ($orderDetails->{order}->{credit_approval_status}->{name} eq 'Rejected')
        {
            if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{credit_rejected_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                                  'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>$salesrep_email,
                                                  'subject'=>'An order was halted due to credit approval!')))
                { $client->displayfailure("Could not email."); }
            $client->displaysuccessHalt("Halting due to credit rejection.");
        }

    }

    if (defined($orderDetails->{order}->{manager_approval_status}->{name}))
    {
        # Does the manager approval need to happen?
        if ($orderDetails->{order}->{manager_approval_status}->{name} eq 'Pending')
        {
            if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{manager_approval_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                                  'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>join(",", $salesrep_email, $sales_manager_email),
                                                  'subject'=>'An order needs manager approval!')))
                { $client->displayfailure("Could not email."); }
            $client->displaysuccessHalt("Halting for manager approval.");
        }

        # Did the manager reject?
        if ($orderDetails->{order}->{manager_approval_status}->{name} eq 'Rejected')
        {
            if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{manager_rejection_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                                  'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>$salesrep_email,
                                                  'subject'=>'An order was halted due to manager approval!')))
                { $client->displayfailure("Could not email."); }
            $client->displaysuccessHalt("Halting due to manager rejection.");
        }
    }

    if (defined($orderDetails->{order}->{billing_approval_status}->{name}))
    {
        # Does the billing approval need to happen?
        if ($orderDetails->{order}->{billing_approval_status}->{name} eq 'Pending')
        {
            if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{billing_approval_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                                  'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>join(",", $salesrep_email, $billing_email),
                                                  'subject'=>'An order needs billing approval!')))
                { $client->displayfailure("Could not email."); }
            $client->displaysuccessHalt("Halting for billing approval.");
        }

        # Did billing reject?
        if ($orderDetails->{order}->{billing_approval_status}->{name} eq 'Rejected')
        {
            if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{billing_rejected_template}, 'tt_paths'=>[$conf->{assets_dir}],
                                                  'vars'=>$orderDetails,'from'=>$conf->{from_address},'to'=>$salesrep_email,
                                                  'subject'=>'An order was halted due to billing rejection!')))
                { $client->displayfailure("Could not email."); }
            $client->displaysuccessHalt("Halting due to billing rejection.");
        }
    }
    # Still here?  Looks like we are good to go.
    return($input);
}

sub validate_order
{
    my ($order) = shift;
    my ($orderDetails) = shift;
    my ($fcs_schema) = shift;
    my ($order_id) = shift;
    my ($salesrep) = shift;
    my ($testmode) = shift;

    if ( (!$testmode) && (! Fap::Order::validate_prov_order($fcs_schema, $order_id, { skip_server_id=>1 })) )
    {
        return(undef);
    }

    # Do we have a salesperson?
    if ( (!defined($salesrep)) || (!defined($salesrep->email)) )
    {
        Fap->trace_error("No salesrep!");
        return(undef);
    }

    # Do we have a PDF for the quote?
    if (!defined($orderDetails->{order}->{proposal_pdf}))
    {
        Fap->trace_error("Proposal PDF is not set!");
        return(undef);
    }

    # Is the order something we shouldn't be playing with?
    if (defined($orderDetails->{order}->{order_status}->{name}))
    {
        foreach my $state ('Not Required','Cancelled','Closed','In Provisioning','Partially Provisioned','Provisioned','Rejected')
        {
            if ($orderDetails->{order}->{order_status}->{name} eq $state)
            {
                Fap->trace_error("Aborting due to order_status of $state");
                return(undef);
            }
        }
    }
    else {
        Fap->trace_error("Unable to determine order status.");
        return(undef);
    }
    return(1);
}

sub validate_config
{
    my ($config) = shift;

    foreach my $item ('from_address','assets_dir','sales_manager_email','billing_email','order_submitted_template',
                      'credit_check_template','credit_rejected_template','manager_approval_template','manager_rejected_template',
                      'billing_approval_template','billing_rejected_template')
    {
        if (!defined($config->{$item}))
        {
            Fap->trace_error("Missing configuration directive: $item");
            return(undef);
        }
    }
    return(1);
}

sub set_required
{
    my ($order) = shift;
    my ($orderDetails) = shift;
    my $reload=0;

    foreach my $item ('billing_approval_status','manager_approval_status','credit_approval_status')
    {
        if ( (defined($orderDetails->{order}->{$item}->{name})) && ($orderDetails->{order}->{$item}->{name} eq 'Required') )
        {
            my $method = "set_".$item;
            $order->$method('Pending');
            $reload++;
        }
    }

    if ($reload)
    {
        return($order->get_details());
    }
    else {
        return($orderDetails);
    }
}

sub rollback
{
    my ($package, $client, $input) = @_;
    my $fcs_schema = Fap::Model::Fcs->new();
    my $testmode = $client->options->{t} ? 'test' : undef;

    my $order = Fap::Order->new('order_id' => $input->{order_id}, 'fcs_schema' => $fcs_schema);
    $order->set_billing_approval_status('Required');
    $order->set_manager_approval_status('Required');
    $order->set_credit_approval_status('Required');

    return($input);
}
