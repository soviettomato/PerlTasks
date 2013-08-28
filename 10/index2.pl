#!/usr/bin/perl -w

use strict;
use CGI;
use utf8;
use Encode;

my $cgi  = CGI->new();

my $html = <<HTML;
<!DOCTYPE html>
	<html>
	<head>
	<link href="css/bootstrap.min.css" rel="stylesheet" media="screen">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
		xmlhttp.open("GET",getUrl(),true);
		xmlhttp.send();
	}
	
	function getUrl(){
		var user = "userName=" + document.getElementById("user_name").value;
		var comment = "comment=" + document.getElementById("comment").value;
		var formatCurrentDate = new Date();
		var date = "date=" + 
			formatCurrentDate.getFullYear()+ "-" + 
			(formatCurrentDate.getMonth() + 1) + "-" +
			formatCurrentDate.getDate() + " " +
			formatCurrentDate.getHours() + ":" +
			formatCurrentDate.getMinutes() + ":" +
			formatCurrentDate.getSeconds();
		alert(date);
		var db_connect = "db_connect=" + document.getElementById("db_connect").value;
		var url = "script.pl?" + user + "&" + comment + "&" + date + "&" + db_connect;
		return url;
	}
	</script>
	</head>
	<body>
	<script src="http://code.jquery.com/jquery.js"></script>
	<script src="js/bootstrap.min.js"></script>
	
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
	<button class="btn btn-large btn-primary" type="button">Large button</button>
	<div id="myDiv"><h2>Let AJAX change this text</h2></div>
	</body>
	</html>
HTML

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
	);
	
#print encode('cp1251', $html);
print $html;



