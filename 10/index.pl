#!/usr/bin/perl -w

use strict;
use CGI;
#use utf8;
#use Encode;

my $cgi  = CGI->new();

my $html = <<HTML;
<!DOCTYPE html>
	<html>
	<head>
	<!-- <link href="https://raw.github.com/twbs/bootstrap/master/dist/css/bootstrap.min.css" rel="stylesheet" media="screen" /> -->
	<!-- <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen" /> -->
	<!-- <meta name="viewport" content="width=device-width, initial-scale=1.0"> -->
	<script>
	function writeComments(){
		var xmlhttp;
		if (window.XMLHttpRequest){
			xmlhttp=new XMLHttpRequest();
		}
		else{
			xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
		
		xmlhttp.onreadystatechange=function(){
		if (xmlhttp.readyState==4 && xmlhttp.status==200){
			document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
		}
		}
		var url = getUrl();
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
		alert(url);
	}
	
	function getUrl(){
		var userName = document.getElementById("user_name").value;
		if(userName == ""){
			alert("Введите имя");
			abort();
		}
		var user = "userName=" + userName;
		var comment = "comment=" + document.getElementById("comment").value;
		var formatCurrentDate = new Date();
		var date = "date=" + 
			formatCurrentDate.getFullYear()+ "-" + 
			(formatCurrentDate.getMonth() + 1) + "-" +
			formatCurrentDate.getDate() + " " +
			formatCurrentDate.getHours() + ":" +
			formatCurrentDate.getMinutes() + ":" +
			formatCurrentDate.getSeconds();
		var db_connect = "db_connect=" + document.getElementById("db_connect").value;
		var url = "script.pl?" + user + "&" + comment + "&" + date + "&" + db_connect;
		return url;
	}
	
	</script>
	<!-- <script src="http://code.jquery.com/jquery.js"></script> -->
	<!-- <script src="bootstrap/js/bootstrap.min.js"></script> -->
	</head>
	<body>
	<p>Введите имя пользователя :</p> 
	<input id="user_name" type = "text">
	<button type="button" onclick="writeComments()">Записать</button>
	<p>Комментарий:</p>
	<textarea rows="4" cols="50" id="comment" placeholder="Ваш комментарий"></textarea>
	<br>
	<textarea rows="5" cols="25" id="db_connect" placeholder="Ваш комментарий">
localhostX
3306X
testX
rootX
PerlStudentX
	</textarea>
	<div id="myDiv"></div>
	</body>
	</html>
HTML

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
	);
	
#print encode('cp1251', $html);
print $html;



