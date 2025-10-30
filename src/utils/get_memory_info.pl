use strict;
use warnings;

sub get_memory_info {
  my %meminfo;
  
  open my $fh, '<', '/proc/meminfo' or die "Cannot open /proc/meminfo: $!\n";
    while (<$fh>) {
      if (/^(\w+):\s+(\d+)/) {
        $meminfo{$1} = $2;  # valores em KB
      }
    }
  close $fh;

  return {
    total_kb => $meminfo{'MemTotal'} // 0,
    free_kb  => $meminfo{'MemFree'}  // 0,
    available_kb => $meminfo{'MemAvailable'} // 0,
  };
}

1;
