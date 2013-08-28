#!/usr/bin/perl -w

use strict;
use CGI;
use utf8;
use DBI;

my $cgi  = CGI->new();

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
);

my $dbh = &getDBH;

&createTables
	if(!&isExistsTables);

eval{
	&setUserData;
	&getUserData;
};

$dbh->disconnect;

sub setUserData {
	my $userName = $cgi->url_param("userName");
	my $comment = $cgi->url_param("comment");
	my $date = $cgi->url_param("date");
	
#	my $parametrs = $cgi->Vars;
#	print "userName->", $parametrs->{"userName"}, "<br>";
#	print "comment->", $parametrs->{"comment"}, "<br>";
#	print "date->", $parametrs->{"date"}, "<br>";
#	print "userName->", $userName, "<br>";
#	print "comment->", $comment, "<br>";
#	print "date->", $date, "<br>";
	
	my $insertUserName = "
		insert into user(user_name)
			values('$userName')
	";
	my $insertCommentAndDate = "
		insert into comments(user_id, date_when_add, comment)
			values(
				( select user_id from user where user_name = '$userName' ),
				'$date',
				'$comment')
	";
#	print "->", $insertUserName, "<br>";
#	print "->", $insertCommentAndDate, "<br>";
	eval{
		$dbh->do($insertUserName);
	};
	$dbh->do($insertCommentAndDate);
	#$dbh->commit;
}

sub getUserData {
	my $getUserData = "
		select date_when_add, user_name, comment
		from user left join comments
		on user.user_id = comments.user_id
		order by user_name
	";
	my $sth = $dbh->prepare($getUserData);
	$sth->execute();
	print "<table border='1'>";
	print "<tr>
		<td><b>Дата</b></td>
		<td><b>Имя пользователя</b></td>
		<td><b>Комментарий</b></td>
	</tr>";
	while(my $user_info = $sth->fetchrow_arrayref){
		print "<tr>";
		print "<td>" , $user_info->[0], "</td><td>", $user_info->[1] , "</td><td>", $user_info->[2], "</td>";
		print "</tr>";
	}
	print "</table>";
	$sth->finish;
}

sub isExistsTables {
	my $sth = $dbh->prepare("show tables");
	my $tablesName = "";
	$sth->execute();
	while (my $tableName = $sth->fetchrow_arrayref) {
		$tablesName .= $tableName->[0];
	}
	$sth->finish;
	($tablesName =~ /comments/) && ($tablesName =~ /user/);
}

sub createTables {
	my $dropTables = "drop table if exists comments, user";
	my $createTableUser = "
		create table user (
			user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
			user_name VARCHAR(40) NOT NULL,
			UNIQUE(user_name)
		)
	";
	my $createTableComments = "
		create table comments (
			comm_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
			user_id INT NOT NULL, 
			date_when_add DATETIME,
			comment VARCHAR(200),
			FOREIGN KEY(user_id)
				REFERENCES user(user_id)
		)
	";
	$dbh->do($dropTables);
	$dbh->do($createTableUser);
	$dbh->do($createTableComments);
}


sub getDBH {
	my($host_name, $port, $database_name, $user_name, $password) = split "X", $cgi->param("db_connect");
	my $dsn = "DBI:mysql:database=$database_name;host=$host_name;port=$port";
	my $dbh = DBI->connect($dsn, $user_name, $password,
		{
			RaiseError => 1,
			PrintError => 0,
		}
	) or die $DBI::errstr;
	$dbh;
}