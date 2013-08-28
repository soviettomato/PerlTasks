#!/usr/bin/env perl

use strict;
use warnings;
use CGI;

my $cgi = CGI->new;

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
);

if($cgi->param("action") eq "spam_def"){
	my $responce;
	if(int(rand(2))){
		$responce = <<HTML
			<p>Я не спам-бот :
			<input id="check" type = "checkbox">
			</p>
			<input id="isBot" type="hidden" name="must" value="yes">
HTML
	} else {
		$responce = <<HTML
			<p>Я спам-бот : 
			<input id="check" type = "checkbox">
			</p>
			<input id="isBot" type="hidden" name="must" value="no">
HTML
	}
	print $responce;
}

if($cgi->param("action") eq "send"){
	my $parametrs = $cgi->Vars;
	if(&checkValues($parametrs)){
		&sendMail($parametrs);
	}
}

sub checkValues {
	my $parametrs = shift;
	my $recipient = $parametrs->{'recipient'};
	my $reverse_email = $parametrs->{'reverse_email'};
	my $checked = $parametrs->{'check'};
	my $isBot = $parametrs->{'isBot'};
	if($recipient !~ /^[a-zA-Z][a-zA-Z1-9.-]*@[a-zA-Z1-9].[a-zA-Z1-9.-]*[a-zA-Z1-9]$/){
		print "Неверный email получателя";
		return 0;
	}
	if($reverse_email !~ /^[a-zA-Z][a-zA-Z1-9.-]*@[a-zA-Z1-9].[a-zA-Z1-9.-]*[a-zA-Z1-9]$/){
		print "Неверный обратный email";
		return 0;
	}
	if(($checked eq "false") && ($isBot eq "yes")){
		print "Хватит спамить!";
		return 0;
	}
	if(($checked eq "true") && ($isBot eq "no")){
		print "Хватит спамить!";
		return 0;
	}
	
	1;
}

sub sendMail {
	my $parametrs = shift;
	my $recipient = $parametrs->{'recipient'};
	my $reverse_email = $parametrs->{'reverse_email'};
	$recipient =~ s/@/\@/;
	$reverse_email =~ s/@/\@/;
	eval{
		open (SENDMAIL, "|/usr/sbin/sendmail -t")
			or die "sendmail not ready";
		print SENDMAIL "From: <root\@perlstudent.tm.local>\n";
		print SENDMAIL "To: <$recipient>\n";
		print SENDMAIL "Reply-To: <$reverse_email>\n";
		print SENDMAIL "Subject: $parametrs->{'theme'}\n\n";
		print SENDMAIL "$parametrs->{'main_text'}";
		close (SENDMAIL) 
			or die "sendmail didn't close nicely";
	};
	if($@){
		print $@;
	} else {
		print "Отправлено";
	}
}
