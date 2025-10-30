#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../utils";
require 'check_if_is_root.pl';

my %net_params = (
    "net.core.rmem_max"        => 16777216,
    "net.core.wmem_max"        => 16777216,
    "net.ipv4.tcp_rmem"        => "4096 87380 16777216",
    "net.ipv4.tcp_wmem"        => "4096 65536 16777216",
    "net.ipv4.tcp_congestion_control" => "bbr",
    "net.ipv4.tcp_slow_start_after_idle" => 0,
);

foreach my $param (keys %net_params) {
    my $value = $net_params{$param};
    my $sysctl_path = "/proc/sys/" . (join "/", split /\./, $param);

    if (is_root() && -w $sysctl_path) {
        open my $fh, '>', $sysctl_path or warn "Can't write $sysctl_path: $!\n";
        print $fh "$value\n";
        close $fh;
        print "Applied $param = $value\n";
    } else {
        print "[Dry-Run]: Would apply $param = $value\n";
    }
}

my $rule_file = "/etc/sysctl.d/99-foxtune-net.conf";
if (is_root()) {
    if (open my $rfh, '>', $rule_file) {
        foreach my $key (keys %net_params) {
            print $rfh "$key = $net_params{$key}\n";
        }
        close $rfh;
        print "Persisted NET tuning in $rule_file\n";
        system("sysctl -p $rule_file");
    } else {
        warn "Can't write $rule_file: $!\n";
    }
} else {
    print "[Dry-Run]: Persist to $rule_file\n";
}
