#!/usr/bin/env perl

use strict;
use warnings;
use CGI;

my $cgi = CGI->new;

my $html = <<HTML;
<!DOCTYPE html>
	<html>
		<head>
			<script>
			
			function isGoodRequest(request){
				if((request.readyState == 4) && (request.status == 200)){
					return true;
				} else {
					return false;
				}
			}
			
			function getXmlHttpObject(){
				var xmlHttp;
				if(window.XMLHttpRequest){
					xmlHttp = new XMLHttpRequest();
				} else{
					xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
				}
				return xmlHttp;
			}
			
			function gen_spam_defence(){
				var xmlHttp = getXmlHttpObject();
				var url = "sendmail.pl?action=spam_def";
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						document.getElementById("check_spambot").innerHTML=xmlHttp.responseText;
					}
				}
				xmlHttp.open("GET", url, true);
				xmlHttp.send();
				
			}
			
			function gen_spam_defence(){
				var xmlHttp = getXmlHttpObject();
				var url = "sendmail.pl?action=spam_def";
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						document.getElementById("check_spambot").innerHTML=xmlHttp.responseText;
					}
				}
				xmlHttp.open("GET", url, true);
				xmlHttp.send();
				
			}
			
			function send(){
				var recipient = document.getElementById("recipient").value;
				var reverse_email = document.getElementById("reverse_email").value;
				var theme = document.getElementById("theme").value;
				var check = document.getElementById("check").checked;				
				var isBot = document.getElementById("isBot").value;
				var main_text = document.getElementById("main_text").value;
				var param = 
					"action=send" +
					"&recipient=" + recipient +
					"&reverse_email=" + reverse_email +
					"&theme=" + theme +
					"&check=" + check +
					"&isBot=" + isBot +
					"&main_text=" + main_text;
				
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						document.getElementById("result").innerHTML=xmlHttp.responseText;
					}
				}
				xmlHttp.open("POST","sendmail.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
			
			</script>
		</head>
	<body onload="gen_spam_defence()">

	<p>E-mail получателя : </p> 
	<input id="recipient" type = "text">
	<p>Обратный e-mail: </p> 
	<input id="reverse_email" type = "text">
	<p>Тема : </p> 
	<input id="theme" type = "text">
	<div id="check_spambot"></div>
	<p>Результат : <div id="result"></div>
	</p>
	<p>Текст сообщения : </p>
	<textarea rows="10" cols="100" id="main_text" placeholder="Ваше сообщение"></textarea>
	<br>
	<button type="button" onclick="send()">Отправить</button>
	<br>
	
	</body>
	</html>
HTML

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
);
print $html;
