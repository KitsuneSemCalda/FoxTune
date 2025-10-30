#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../utils";
require 'check_if_is_root.pl';
require 'get_memory_info.pl';

my $meminfo = get_memory_info();
my $total_mb = int($meminfo->{total_kb} / 1024);

my $swappiness;
my $dirty_ratio;
my $dirty_background_ratio;

if ($total_mb < 4096) {
  $swappiness = 50;
  $dirty_ratio = 15;
  $dirty_background_ratio = 5;
} elsif ($total_mb < 8192) {
  $swappiness = 20;
  $dirty_ratio = 8;
  $dirty_background_ratio = 2;
} else {
  $swappiness = 10;
  $dirty_ratio = 5;
  $dirty_background_ratio = 1;
}

my %params = (
  "vm.swappiness" => $swappiness,
  "vm.dirty_ratio" => $dirty_ratio,
  "vm.dirty_background_ratio" => $dirty_background_ratio,
);

# Aplicar ou dry-run
foreach my $param (keys %params) {
    my $value = $params{$param};
    my $sysctl_path = "/proc/sys/" . (join "/", split /\./, $param);

    if (is_root() && -w $sysctl_path) {
        open my $fh, '>', $sysctl_path or warn "Can't write $sysctl_path: $!\n";
        print $fh $value;
        close $fh;
        print "Applied $param = $value\n";
    } else {
        print "[Dry-Run]: Would apply $param = $value\n";
    }
}

# Persistência
my $rule_file = "/etc/sysctl.d/99-foxtune-ram.conf";
if (is_root()) {
    if (open my $rfh, '>', $rule_file) {
        foreach my $key (keys %params) {
            print $rfh "$key = $params{$key}\n";
        }
        close $rfh;
        print "Persisted RAM tuning in $rule_file\n";
    } else {
        warn "Can't write $rule_file: $!\n";
    }
} else {
    print "[Dry-Run]: Persist to $rule_file\n";
}
