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
			
			function delete_session(){
				var hidden_field_session = document.getElementById("hidden_field_session").value;
				var param = "action=delete" + 
				"&hidden_field_session=" + hidden_field_session;
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						if(xmlHttp.responseText == "delete"){
							alert(xmlHttp.responseText);
							document.getElementById("hidden_field_session").value = "";
							window.location = xmlHttp.responseText;
						}
					}
				}
				xmlHttp.open("POST","script.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
			
			function set_hidden_field(){
				var param = "action=get_session_metod";
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						document.getElementById("hidden_field_session").value=xmlHttp.responseText;
						//alert(xmlHttp.responseText);
						get_user_info();
					}
				}
				xmlHttp.open("POST","script.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
			
			function get_user_info(){
				var hidden_field_session = document.getElementById("hidden_field_session").value;
				var param = "action=get_user_info" + 
				"&hidden_field_session=" + hidden_field_session;
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						document.getElementById("user_info").innerHTML=xmlHttp.responseText;
					}
				}
				xmlHttp.open("POST","script.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
		</script>

	</head>
	<body onload="set_hidden_field()">
	<button type="button" onclick="get_user_info()">Следующая цитата</button>
	<button type="button" onclick="delete_session()">Выход</button>
	<div id="user_info"></div>
	<input id="hidden_field_session" type="hidden" name="session" value="" />
	</body>
	</html>
HTML

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
	);
	
#print encode('cp1251', $html);
print $html;



