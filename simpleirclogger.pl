	##################Simple IRC Logger######################
	#  Written by Householdutensils for Root{SEC}   #
	# Based on the Trivia bot: Triviatron ( RIP :( )
	######################

	###INSTRUCTIONS:
	###Turn the $debugvar variable to 0 if you would like to run the script in normal mode
	###Change the server variables to determine what channel, server, and nick the BOT uses.


	###########################Includes###########################
	#Use the the strict package so I don't write messy as fuck code.
	use strict;
	#Include the socket functions of PERL
	use IO::Socket;
	#Include threading package and threading shared variable package
	use threads;
	#use threads::shared;
	use threads::shared;
	######################END OF INCLUDES###########################


	# Server info and Nick infor. the server var can either be an cmd line arg or a set value 
	    my $server = shift || "irc.servercentral.net";
	    my $nick = "simplebot";
	    my $login = "simplebot";
	    my $channel = "#testchannel";
	# End of server info and nick info. 
	
	
	#$| = 1; #Buffer that mofo

	#Boolean token
	our $debugvar = 1;  #Debug var. This variable determines if all the debug statments get used 

	if ($debugvar) { print "CAUTION: Debug Mode Active\r\n\r\n"; } #Determine whether or not debug mode is one, if it is, display a warning.
	#End of header debug module





	#Sub to get the nick form the IRC Line
	sub get_irc_nick {
	    
	    my $input_string = shift;
	    
	    my @item_array = split(/!/, $input_string);

	my $user_nick_var = @item_array[0];
	$user_nick_var = substr($user_nick_var, 1);
	    


	    return $user_nick_var;
	    
	    
	}
	#End of sub to get the nick from the IRC line


	#sub to get ident
	sub get_ident {
		
		my $input_string = shift;
		my @item_array = split(/@/, $input_string);
		my @twoitem_array = split(/ /, @item_array[1]);
		return @twoitem_array[0];
	}
	#sub to get ident

	#sub to get channel
	sub get_channel {
		
		my $input_string = shift;
		my @item_array = split(/ /, $input_string);
		return @item_array[2];
		
	}
	#sub to get channel

	#sub to get chat text
	sub get_chat_text {
		my $input_string = shift;
		my @item_array = split(/:/, $input_string);
		return @item_array[2];
		
		
	}


	#sub parse_and_store {
	#get arg
	#my $txtline = shift;
	#get users nick
	#my $txtnick = &get_irc_nick($txtline);
	#get ident
	#my $txtident = &get_ident($txtline);
	#get channel
	#my $txtchannel = &get_channel($txtline);
	#get chat text
	#my $txtchattext = &get_chat_text($txtline);
	#
	#Connect to the database
	#my $dbh = DBI->connect ("DBI:mysql:rootsec_irc_db:localhost","root","Password1") or die "COuld not connect to database"; 
	#query
	#my $sql_query = "INSERT INTO ircchat (irctext, ircnick, ircident, ircchannel, ircchattext, ircdate) VALUES ('$txtline', '$txtnick', '$txtident', '$txtchannel', '$txtchattext', NOW())";
	#Prepare the SQL Query for execution
	#my $s_query = $dbh->prepare($sql_query); 
	#Execute the Query, get the question
	#my $return_query = $s_query->execute() or die "Could not execute"; 
	#Disconnect
	#$dbh->disconnect;
	#}


	sub parse_and_store {
		
		my $txtline = shift;

		my $txtnick = &get_irc_nick($txtline);

		my $txtchannel = &get_channel($txtline);
		
		my $txtident = &get_ident($txtline);

		my $txtchattext = &get_chat_text($txtline);
		
		my $chatlog = "chatlog.log";
		open(DAT,">>$chatlog") or die("Cannot open file");	
		
		(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst)=localtime(time);
		my $datetime = "$hour:$min:$sec";
		
		
		print DAT "[$datetime]$txtnick: $txtchattext";
		
		close DAT;

	}






	#####################################CONNECTION SEGMENT################################################3


	# Open TCP Socket to connect to the IRC Server
	my $sock = IO::Socket::INET->new(PeerAddr => $server,
					PeerPort => 6667,
					Proto => 'tcp') or
						die "Can't Connect \n";
	# End of block to open TCP Socket to connect to IRC Server

	my $derp = 0;
	my $herp = 0;
	while (my $input = <$sock>) {
			
		if ($derp != 1) {
			
			if ($herp != 1) {
				#Send NICK command to IRC server
				print $sock "NICK $nick\r\n";
				if ($debugvar) { print "Sent NICK \r\n"; } 
				$herp = 1;
			} else {
				#Send USER command to IRC Server
				print $sock "USER $login 0 * :Perl IRC BOT\r\n";
				if ($debugvar) { print "Sent Login \r\n"; } 
				$derp = 1;
			}
			
			
		}
		#while (my $input = <$sock>) {
			
		

	    print $input; #Output the recieved strings from the server
		

		if ($input =~ /PING/) { #If the string recived is the ping from the IRC Server, then we send back a PONG
			print "Found PING: $input";	
			if ($input =~ /:/) {
				my @digits = split(/:/, $input);
				print "Reply: PONG :@digits[1]\r\n";
				print $sock "PONG :@digits[1]\r\n";
			}
		}


	   
		
	    if ($input =~ /376/) { #If the string recieved is marked as the end of the MOTD, then we send the join command to join a chan
		
		if ($debugvar) { print "\r\n preJoin \r\n"; }
		    print $sock "JOIN $channel\r\n"; #Send command to join the channel
		if ($debugvar) { print "\r\n postJoin \r\n"; }
	    
	    }
	    
	    
	    if ($input =~ /366/) { #If the string recieved is the end of the /names list when you've joined a channel, we say HAI LOL
		
		if ($debugvar) { print "\r\npreMessage\r\n"; }
		if ($debugvar) { print "\r\npostMessage\r\n"; }

	    }
	   
	   
	   if ($input =~ / PRIVMSG /) {
	   
		my $inputstring = $input;
		#$inputstring =~ s/\'/\\\'/g;
		
		if ($debugvar) { print "$inputstring\r\n"; }
		
		&parse_and_store($inputstring);
		
		}

	   
		  
	    if ($debugvar) { print "Working:->"; } #Debuging Token that prints "Working :-> as long as this loop still runs

	    
	    # Debug command.
	    


	} #End of the entire chat loop


