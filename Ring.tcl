set ns [new Simulator]


# To Create The Trace Files We Write

set tf [open new.tr w]
$ns trace-all $tf


# To Create the nam files we write

set nf [open new.nam w]
$ns namtrace-all $nf


# Defining the 'finish' procedure

proc finish {} {
	global ns nf tf
	$ns flush-trace
	close $nf
	close $tf
	exec nam new.nam &
	exit 0
}


# Create Node

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]


# Create Link between two nodes

$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n4 2Mb 10ms DropTail
$ns duplex-link $n4 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n0 2Mb 10ms DropTail

# Set queue-size of the link (n1-n2) to 10


$ns queue-limit $n0 $n1 10


# Give position to the nodes in NAM

$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient up
$ns duplex-link-op $n4 $n1 orient left
$ns duplex-link-op $n1 $n0 orient down

# setting a tcp connection


set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink

$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_Size 552



# Initiating FTP over TCP


set ftp [new Application/FTP]
$ftp attach-agent $tcp



# Setting up a UDP connection


set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set null [new Agent/Null]
$ns attach-agent $n4 $null

$ns connect $udp0 $null
$udp0 set fid_ 2



# Setup cbr over udp


set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0

$cbr0 set packet_size 1000
$cbr0 set rate 0.01Mb
$cbr0 set random false


set null0 [new Agent/Null]
$ns attach-agent $n3 $null0
$ns connect $udp0 $null0



# Scheduling the Events

$ns at 0.1 "$cbr0 start"

#$ns at 1.0 "$ftp start"

#$ns at 124.0 "$ftp stop start"

$ns at 124.5 "$cbr0 stop"


# Making the flows

$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green


$ns at 0.1 "$cbr0 start"
#$ns at 0.1 "$ftp start"
$ns at 1.0 "finish"


$ns run
