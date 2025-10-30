#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../utils";
require 'check_if_is_root.pl';

# Detecta o adaptador AC (seja ADP1, AC, AC0, ACAD, etc.)
my $ac_path;
foreach my $p (glob("/sys/class/power_supply/*/online")) {
    next if $p =~ /BAT|usb|UC|typec/i;
    if (-f $p) {
        $ac_path = $p;
        last;
    }
}

die "No power adapter detected in /sys/class/power_supply/*/online\n" 
unless $ac_path;

open my $ac_fh, '<', $ac_path or die "Cannot read $ac_path: $!\n";
my $on_ac = <$ac_fh>;
close $ac_fh;
chomp($on_ac);

my $mode = $on_ac ? "performance" : "powersave";
print "Detected adapter at $ac_path — running in $mode mode\n";

my @cpus = glob("/sys/devices/system/cpu/cpu[0-9]*");

foreach my $cpu (@cpus) {
    my $gov_file = "$cpu/cpufreq/scaling_governor";

    if (is_root() && -w $gov_file) {
        open my $fh, '>', $gov_file or warn "Can't write $gov_file: $!\n";
        print $fh "$mode\n";
        close $fh;
        print "Set $cpu governor to $mode\n";
    } else {
        print "[Dry-Run]: Would set $cpu governor to $mode\n";
    }
}

my $udev_file = "/etc/udev/rules.d/70-foxtune-power.rules";
my $script_path = "$FindBin::Bin/foxtune_power.pl";

my $udev_rule = <<RULE;
# Foxtune Power Governor Rule
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="$script_path"
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="$script_path"
RULE

if (is_root()) {
    open my $ufh, '>', $udev_file or warn "Cannot write $udev_file: $!\n";
    print $ufh $udev_rule;
    close $ufh;
    print "Created Udev rule for power state switching in $udev_file\n";

    system("udevadm control --reload-rules");
    system("udevadm trigger --subsystem-match=power_supply");
} else {
    print "[Dry-Run]: Would create udev rule in $udev_file\n";
}
