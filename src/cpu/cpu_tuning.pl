#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../utils";
require 'check_if_is_root.pl';

my @cpus = glob("/sys/devices/system/cpu/cpu[0-9]*");

foreach my $cpu (@cpus) {
    my $gov_file = "$cpu/cpufreq/scaling_governor";
    my $energy_perf_file = "$cpu/power/energy_perf_bias";

    my $governor = "schedutil";
    my $bias = 6;  # 0 = performance, 15 = power saving

    if (-r "$cpu/topology/core_cpus_list") {
        my $cores = `cat $cpu/topology/core_cpus_list`;
        chomp($cores);
        if ($cores =~ /,/) {
            $governor = "performance";
            $bias = 2;
        }
    }

    if (is_root() && -w $gov_file) {
        open my $fh, '>', $gov_file or warn "Can't write $gov_file: $!\n";
        print $fh "$governor\n";
        close $fh;
        print "Applied $governor to $cpu\n";
    } else {
        print "[Dry-Run]: Would apply governor '$governor' to $cpu\n";
    }

    if (is_root() && -w $energy_perf_file) {
        open my $fh, '>', $energy_perf_file or warn "Can't write $energy_perf_file: $!\n";
        print $fh "$bias\n";
        close $fh;
        print "Set energy bias $bias for $cpu\n";
    } else {
        print "[Dry-Run]: Would set energy bias $bias for $cpu\n";
    }

    my $udev_rule = qq(ACTION=="add|change", KERNEL=="$cpu", ATTR{cpufreq/scaling_governor}="$governor");
    my $udev_file = "/etc/udev/rules.d/60-foxtune-cpu.rules";

    if (is_root()) {
        open my $ufh, '>>', $udev_file or warn "Cannot write $udev_file: $!\n";
        print $ufh "$udev_rule\n";
        close $ufh;
    } else {
        print "[Dry-Run]: Would persist rule in $udev_file\n";
    }
}
