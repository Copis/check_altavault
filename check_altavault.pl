#!/usr/bin/perl
use Getopt::Long;
use Net::SNMP;
use Socket;
use strict;
use Switch;
use warnings;

#Global vars
my $ava_ver = '0.1';
my $server;
my $community;

#NetApp Altavault OID's
my $netapp_altavault = ".1.3.6.1.4.1.789.8";
my $netapp_altavault_health = "$netapp_altavault.2.2.0";
my $netapp_altavault_health_integrity = "$netapp_altavault.2.3.0";

#Check Altavault Health
sub get_health{
	my $session = Net::SNMP->session( -hostname => $server, -community => $community, -version => '2' );
	if (!defined($session)){
		print "UNKNOWN: Cannot open SNMP session";
		exit(3);
	}
	my $result = $session->get_request( -varbindlist => [$netapp_altavault_health,$netapp_altavault_health_integrity] );
	$session->close;
	if (!defined($result)){
		print "UNKNOWN: No SNMP response from host";
		exit(3);
	}

	#Return current state
	switch ($result->{$netapp_altavault_health_integrity}){
		case (10000) {
			print "OK: System health is ".$result->{$netapp_altavault_health}."\n";
			exit(0);
		}
		case (30000){
			print "WARNING: System health is ".$result->{$netapp_altavault_health}."\n";
			exit (1);
		}
		case (50000){
			print "CRITICAL: System health is ".$result->{$netapp_altavault_health}."\n";
			exit (2);
		}
		else{
			print "UNKOWN response from host";
			exit(3);
		}
	}
}

#Print help
sub help{
	print "check_altavault version: $ava_ver\n";
	print "Usage: ./check_altavault.pl -H <hostname> -C <community>\n";
	exit(3);
}

## Main
GetOptions("H=s" => \$server, "C=s" => \$community);
if (!defined($server) || !defined($community)){
        help()
}
get_health();

