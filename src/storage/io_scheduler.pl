#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../utils";
require 'check_if_is_root.pl';

my @devices = glob("/sys/block/*");

# NOTE: In another cases, we maybe prefer another IO Schedulers but we talking in responsiviness
# mq-deadline is a good io-scheduling because we combines multiqueue with time limit by process
# bfq is classic scheduling to rotative disk because he have a fair division between process

foreach my $device ( @devices ) {
  # Ignore if is a loop, logical or ram device;
  next if $device =~ /loop|ram|dm/; 

  my ($dev_name) = $device =~ m{/sys/block/(.*)};
  my $scheduler = "";
  
  if ($dev_name =~ /^nvme/) {
    $scheduler = "mq-deadline";
  }else {
    $scheduler = "bfq";
  }

  my $sched_file = "$device/queue/scheduler";

  # NOTE: When we not running this script as a root, we dont need to worry in change the modifications on system
  # The is_root checking + permission write checking garantee the security on dev
  if (is_root() && -w $sched_file) {
    open my $scheduler_file, '>', $sched_file or warn "Can't write $sched_file: $!\n";
    print $scheduler_file "$scheduler\n";
    close $scheduler_file;
    print "Applied $scheduler to $dev_name\n";
  }else{
    # Print the dry run when we not change the modification
    print "[Dry-Run]: Applied $scheduler to $dev_name\n";
  }

  # Apply a persistency by udev rule
  my $udev_file = "/etc/udev/rules.d/60-foxtune-$dev_name.rules";
  my $udev_rule = qq(ACTION=="add|change", KERNEL=="$dev_name", ATTR{queue/scheduler}="$scheduler");
  
  if (is_root() && -w "$udev_file") {
    open my $ufh, '>', $udev_file or warn "Cannot write $udev_file: $!\n";
    print $ufh "$udev_rule\n";
    close $ufh;
    print "Created udev rule for $dev_name\n";
  }else{
    print "[Dry-Run]: Would create udev rule:\n$udev_rule\n on $udev_file";
  }
}
