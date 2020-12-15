#use: perl perm_test.pl <dhmr.nebula> <5hmc.nebula>
# please remove first header line of files
# please make sure file names do not have parentheses in them


## this portion gets the number of times each chromosome is seen in DhMRs
$file2 = $ARGV[1];
open (IN1,$ARGV[0]);
while (<IN1>) {
    $l1 = $_;
    $l1 =~ s/\n//g;
    $chr = $l1;
    $hash{$chr}++;
    $count++;
}
close IN1;

open (OUT,">chr.tmp.dhmr");
for $key (keys %hash) {
    $actual_num = $hash{$key}/$count;
    print OUT "$key\t$actual_num\n";
}
close OUT;

## this portion takes 5hmC data and takes a random sample of it
## it then counts how many times a peak falls into each chromosome
## it does this 100000 times
#for (1..100000) {
for (1..10000) {
    $progress++;
    $out = "chrtmptmp";
    system "gshuf $file2 | head -$count > $out";
    open (IN2,"chrtmptmp");
    while (<IN2>) {
	$l2 = $_;
	$l2 =~ s/\n//g;
	$chr2 = $l2;
	$hash2{$chr2}++;
    }
    close IN2;
    open (OUT2,">chrtmp2");
    for $key2 (keys %hash2) {
	$perm_num = $hash2{$key2}/$count;
	print OUT2 "$key2\t$perm_num\n";
    }
    close OUT2;

## this portion checks if random samples have greater number of peaks falling in each chromosome than DhMRs do
## if so, it adds one to the number of times this occurs, this is to check over or under-representation of DhMRs in each chromosome
## in order to correct for multiple testing hypotheses, it compares each chromosome to each other, not just if the chromsome numbers match
    open (IN3,"chr.tmp.dhmr");
    while (<IN3>) {
	($t,$n) = split;
	open (IN4,"chrtmp2");
	while (<IN4>) {
	    ($oldt,$oldn) = split;
	    if ($oldt eq $t) {
		if ($n < $oldn) {
		    $permhash{$t}++;
		}
	    }
	}
    }
    %hash2 = ();
    print "$progress\n";
}

## this portion divides the number of times a random sample is more extreme than the DhMRs in genomic structures
## it then divides it by 100000 to give the p-value
for $key3 (keys %permhash) {
    $num = $permhash{$key3};
#    $div = $num/100000;
    $div = $num/10000;
    print "$key3\t$div\n";
}
system "rm chr.tmp.dhmr";
system "rm chrtmptmp";
system "rm chrtmp2";
