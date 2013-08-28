#!/usr/bin/perl -w

use strict;
use utf8;
use DBI;
use CGI qw/:standard/;
use CGI::Cookie;

my $cgi  = CGI->new();

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
);

#my $dbh = &getDBH;

eval {
#print ">" . $cgi->param("action") . "<br>";

&createTables
	if(!&isExistsTables);

if($cgi->param("action") eq "check_autorization"){
	eval {
		my $userName = $cgi->param("user_name");
		my $password = $cgi->param("password");
		&autorization($userName, $password);
	};
	if($@){
		print "false";
	} else {
		print "true";
	}
}

if($cgi->param("action") eq "autorization"){
	my $userName = $cgi->param("user_name");
	my $session_choose = $cgi->param("session_choose");
	my $url = self_url();
	$url =~ s/script\.pl.+//;
	$url .= "user_page.pl";
	if($session_choose eq "cookie"){
		&setCookie($userName);
		&setSessionCookie("undef");
	} else {
		&setSessionCookie($userName);
	}
	print $url;
}

if($cgi->param("action") eq "registration"){
	my $userName = $cgi->param("reg_user_name");
	my $password = $cgi->param("reg_password");
	my $repeat_password = $cgi->param("repeat_reg_password");
	eval {
		die "Пароли не совпадают!\n"
			if($password ne $repeat_password);
		&registration($userName, $password);
	};
	if($@){
		print $@;
	}
}

if($cgi->param("action") eq "delete"){
	&deleteSession;
}

if($cgi->param("action") eq "get_session_metod"){
	my $cookies = $cgi->cookie("session_cookie");
	print $cookies;
}

#!
if($cgi->param("action") eq "get_user_info"){
	&next;
}


###########!
if($cgi->param("action") eq "see_cookie"){
	eval {
		&TESTgetCookie;
	};
	if($@){
		print $@;
	}
}
sub TESTgetCookie {
	my $cookies = $cgi->cookie("user_id");
	print "v->", $cookies, "<br>";
}

#$dbh->disconnect;
};
if($@){
	print $@;
}

sub autorization {
	my $userName = shift;
	my $password = shift;
	die "Имя пользователя или пароль не верны!\n"
		if(!&checkUserNameExist($userName, $password));
}

sub deleteSession {
	my $hidden_field_session = &getUserNameFromSessionInfo;
	if($hidden_field_session eq "undef"){
		&deleteCookie;
	}
	my $url = self_url();
	$url =~ s/script\.pl.+//;
	$url .= "autorization.pl";
	$url;
}

sub deleteCookie {
	my $cookies = CGI::Cookie->fetch;
	$cookies->{"user_id"}->value("");
	$cookies->{"user_id"}->expires("now");
	print $cgi->header(-cookie => $cookies->{"user_id"});
}

sub setCookie {
	my $userName = shift;
	my $userNameCookie = cookie(
		-name=>"user_id",
		-value=>"$userName",
		-expires=>"+1M"
	);
	print header(-cookie=>$userNameCookie);
}

sub setSessionCookie {
	my $value = shift;
	my $sessionCookie = cookie(
		-name=>"session_cookie",
		-value=>"$value",
		-expires=>"+1M"
	);
	print header(-cookie=>$sessionCookie);
}


sub checkUserNameExist {
	my $dbh = &getDBH;
	my $userName = shift;
	my $password = shift;
	my $getUserData = "
		select user_id
		from user_names
		where user_name = '$userName' and password = '$password'
	";
	my $sth = $dbh->prepare($getUserData);
	$sth->execute();
	my $defined_name = $sth->fetchrow_arrayref;
	$sth->finish;
	$dbh->disconnect;
	defined $defined_name;
}


sub registration {
	my $dbh = &getDBH;
	my $userName = shift;
	my $password = shift;
	my $regUser = "
		insert into user_names(user_name, password, number_of_readable_quotes)
			values('$userName', '$password', 0)
	";
	eval{
		$dbh->do($regUser);
	};
	$dbh->disconnect;
	die "Пользователь с таким именем уже существует!\n"
		if($@);
}

sub getUserData {
	my $dbh = &getDBH;
	my $userName = shift;
	my $quoteNumber = shift;
	my $getUserData = "
		select number_of_readable_quotes
		from user_names
		where user_name = '$userName'
	";
	my $sth = $dbh->prepare($getUserData);
	$sth->execute();
	my $number_of_readable_quotes = $sth->fetchrow_arrayref->[0];
	print "<table>";
	print "	<tr>
				<td><b>Пользователь :</b> $userName</td>
			</tr>
			<tr>
				<td><b>Количество прочитанных цитат :</b> $number_of_readable_quotes</td>
			</tr>
	</table>
	<br>";
	&getQuote($number_of_readable_quotes);

	$sth->finish;
	$dbh->disconnect;
}

sub next {
	my $userName = &getUserNameFromSessionInfo;
#
#	print "--$userName<br>";#
	my $quoteNumber = &getQuoteNumber($userName);
	
	$quoteNumber++;
	eval {
		&updateUserData($userName, $quoteNumber);
	};
	if($@){
		print $@;
	}
	&getUserData($userName, $quoteNumber);
}

sub getUserNameFromSessionInfo {
	use Time::HiRes qw(usleep);
	my $userName;
	my $hidden_field_session = $cgi->param("hidden_field_session");
	if(!defined $hidden_field_session){
		print "Ошибка запроса<br>";
		exit 1;
	}
#!!!
#	while(!defined $hidden_field_session ){
#		$hidden_field_session = $cgi->param("hidden_field_session");
#		usleep(500);
#	}
	#
	
	if($hidden_field_session eq "undef"){
		$userName = $cgi->cookie("user_id");
	} else {
		$userName = $hidden_field_session;
	}
	$userName;
}

sub getQuote {
	my $quoteNumber = shift;
	use LWP::UserAgent;
	my $ua = LWP::UserAgent->new;
	$ua->agent("$0/0.1 " . $ua->agent);
	my $req = HTTP::Request->new(
	   GET => "http://bash.im/quote/$quoteNumber");
	$req->header('Accept' => 'text/html');
	my $res = $ua->request($req);
	if ($res->is_success) {
		my $content = $res->decoded_content;
		$content =~ s/.*<div class="text">//s;
		$content =~ s/<\/div>.*//s;
	    print $content;
	}
	else {
	   print "Error: " . $res->status_line . "\n";
	}
}

sub getQuoteNumber {
	my $dbh = &getDBH;
	my $userName = shift;
#	print "->>>>" . $userName . "<br>";############
	my $getUserData = "
		select number_of_readable_quotes
		from user_names
		where user_name = '$userName'
	";
	my $sth = $dbh->prepare($getUserData);
	$sth->execute();
	my $number_of_readable_quotes = $sth->fetchrow_arrayref->[0];
	$sth->finish;
	$dbh->disconnect;
	$number_of_readable_quotes;
}

sub updateUserData {
	my $dbh = &getDBH;
	my $userName = shift;
	my $readable_quote_id = shift;
	my $updateUserInfo = "
		update user_names
		set number_of_readable_quotes = $readable_quote_id
		where user_name = '$userName'
	";
	my $insertQuotesInfo = "
		insert into quotes (user_id, readable_quote_id)
		values((select user_id from user_names where user_name = '$userName'), $readable_quote_id)
	";
	$dbh->do($updateUserInfo);
	$dbh->do($insertQuotesInfo);
	$dbh->disconnect;
}

sub isExistsTables {
	my $dbh = &getDBH;
	my $sth = $dbh->prepare("show tables");
	my $tablesName = "";
	$sth->execute();
	while (my $tableName = $sth->fetchrow_arrayref) {
		$tablesName .= $tableName->[0];
	}
	$sth->finish;
	$dbh->disconnect;
	($tablesName =~ /user_names/) && ($tablesName =~ /quotes/);
}

sub createTables {
	my $dbh = &getDBH;
	my $dropTables = "drop table if exists quotes, user_names";
	my $createTableUser = "
		create table user_names (
			user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
			user_name VARCHAR(40) NOT NULL,
			number_of_readable_quotes INT,
			password VARCHAR(40) NOT NULL,
			UNIQUE(user_name)
		)
	";
	my $createTableQuotes = "
		create table quotes (
			quote_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
			user_id INT NOT NULL,
			readable_quote_id INT NOT NULL, 
			FOREIGN KEY(user_id)
				REFERENCES user_names(user_id)
		)
	";
	$dbh->do($dropTables);
	$dbh->do($createTableUser);
	$dbh->do($createTableQuotes);
	$dbh->disconnect;
}

sub getDBH {
	my($host_name, $port, $database_name, $user_name, $password) = qw(localhost 3306 test root PerlStudent);
	my $dsn = "DBI:mysql:database=$database_name;host=$host_name;port=$port";
	my $dbh = DBI->connect($dsn, $user_name, $password,
		{
			RaiseError => 1,
			PrintError => 0,
		}
	) or die $DBI::errstr;
	$dbh;
}