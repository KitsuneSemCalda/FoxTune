#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/utils";
require 'check_if_is_root.pl';

my @modules = (
    "$FindBin::Bin/ram/ram_tuning.pl",
    "$FindBin::Bin/storage/io_scheduler.pl",
    "$FindBin::Bin/cpu/cpu_tuning.pl",
    "$FindBin::Bin/network/net_tuning.pl",
    "$FindBin::Bin/power_rule/power_tuning.pl",
);

my $is_root = is_root();

print "=== FoxTune System Tuning ===\n";
print $is_root ? "Running as root: changes will be applied\n" 
               : "[Dry-Run] Running without root: no changes will be made\n";

foreach my $module (@modules) {
    print "\n--- Executing $module ---\n";
    my $cmd = $is_root ? "perl $module" : "perl $module --dry-run";
    system($cmd) == 0 or warn "Module $module exited with error\n";
}

if ($is_root) {
    print "\nApplying sysctl rules...\n";
    foreach my $file (glob("/etc/sysctl.d/99-foxtune-*.conf")) {
        print "Loading $file...\n";
        system("sysctl -p $file");
    }
} else {
    print "\n[Dry-Run] Would apply sysctl rules\n";
}

if ($is_root) {
    print "Reloading udev rules...\n";
    system("udevadm control --reload-rules");
    system("udevadm trigger");
} else {
    print "[Dry-Run] Would reload udev rules\n";
}

print "\n=== FoxTune Finished ===\n";
