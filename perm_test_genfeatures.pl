#use: perl perm_test.pl <dhmr.nebula> <5hmc.nebula>
# please remove first header line of files
# please make sure file names do not have parentheses in them

## this portion gets the number of times each genomic structure is seen in DhMRs
$file2 = $ARGV[1];
open (IN1,$ARGV[0]);
while (<IN1>) {
    $l = $_;
    $l =~ s/\n//;
    $type = $l;
    $hash{$type}++;
    $count++;
}
close IN1;

open (OUT,">tmp.dhmr");
for $key (keys %hash) {
    print OUT "$key\t$hash{$key}\n";
}
close OUT;

## this portion takes 5hmC data and takes a random sample of it
## it then counts how many times a peak falls into each genomic structure
## it does this 100000 times
for (1..10000) {
#for (1..10) {
    $progress++;
    $out = "tmptmp";
    system "shuf $file2 | head -$count > $out";
#system "shuf $file2 | head -1039 > $out";
    open (IN2,"tmptmp");
    while (<IN2>) {
	$l2 = $_;
	$l2 =~ s/\n//g;
	$type = $l2;
	$hash2{$type}++;
    }
    close IN2;
    open (OUT2,">tmp2");
    for $key2 (keys %hash2) {
	print OUT2 "$key2\t$hash2{$key2}\n";
    }
    close OUT2;

## this portion checks if random samples have greater number of peaks falling in genomic structures than DhMRs do
## if so, it adds one to the number of times this occurs, this is to check over or under-representation of DhMRs in genomic structures
    open (IN3,"tmp2");
    while (<IN3>) {
	($t,$n) = split;
	open (IN4,"tmp.dhmr");
	while (<IN4>) {
	    ($oldt,$oldn) = split;
	    if ($oldt eq $t) {
		if ($n > $oldn) {
		    $permhash{$oldt}++;
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
    $div = $num/10000;
#    $div = $num/10;
    print "$key3\t$div\n";
}

#system "rm tmp.dhmr tmptmp tmp2";
