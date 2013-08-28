#!/usr/bin/perl -w

use strict;
use CGI;
use Encode;

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
			
			function check_autorization(){
				var user_name = document.getElementById("user_name").value;
				var password = document.getElementById("password").value;
				var param = 
					"action=check_autorization" +
					"&user_name=" + user_name +
					"&password=" + password;
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						var result = xmlHttp.responseText;
						if(result == "false"){
							document.getElementById("result_autorization").innerHTML = "Имя пользователя или пароль не верны!";
						}else {
							autorization();
						}
					}
				}
				xmlHttp.open("POST","script.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
			
			function autorization(){
				var user_name = document.getElementById("user_name").value;
				var session_choose = document.getElementById("session_choose").value;
				var param = 
					"action=autorization" +
					"&user_name=" + user_name +
					"&session_choose=" + session_choose;
				
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						window.location = xmlHttp.responseText;
					}
				}
				xmlHttp.open("POST","script.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
			
			function registration(){
				var reg_user_name = document.getElementById("reg_user_name").value;
				var reg_password = document.getElementById("reg_password").value;
				var repeat_reg_password = document.getElementById("repeat_reg_password").value;
				var param = 
					"action=registration" +
					"&reg_user_name=" + reg_user_name +
					"&reg_password=" + reg_password +
					"&repeat_reg_password=" + repeat_reg_password
					;
				
				var xmlHttp = getXmlHttpObject();
				xmlHttp.onreadystatechange = function(){
					if(isGoodRequest(xmlHttp)){
						document.getElementById("result_registration").innerHTML=xmlHttp.responseText;
					}
				}
				xmlHttp.open("POST","script.pl",true);
				xmlHttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
				xmlHttp.send(param);
			}
	</script>
	</head>
	<body>
	<table>
	  <tr>
		<td><b>Вход</b></td>
		<td><b>Регистрация</b></td>
	  </tr>
	  <tr>
		<td>
			<table>
				<tr>
					<td>Имя пользователя :</td>
					<td><input id="user_name" type = "text"></td>
				</tr>
				<tr>
					<td>Пароль :</td>
					<td><input id="password" type = "password"></td>
				</tr>
				<tr>
					<td>Выбор метода сессии :</td>
					<td>
						<select id="session_choose" size="1">
							 <option value="cookie">cookie</option>
							 <option value="hidden">hidden field</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><button type="button" onclick="check_autorization()">Вход</button></td>
				</tr>
				<tr>
					<td><div id="result_autorization"></div></td>
				</tr>
			</table>
		</td>
		<td>
			<table>
				<tr>
					<td>Введите имя пользователя :</td>
					<td><input id="reg_user_name" type = "text"></td>
				</tr>
				<tr>
					<td>Введите пароль :</td>
					<td><input id="reg_password" type = "password"></td>
				</tr>
				<tr>
					<td>Повторите пароль :</td>
					<td><input id="repeat_reg_password" type = "password"></td>
				</tr>
				<tr>
					<td><button type="button" onclick="registration()">Регистрация</button></td>
				</tr>
				<tr>
					<td><div id="result_registration"></div></td>
				</tr>
			</table>
		</td>
	  </tr>
	</table>
	</body>
	</html>
HTML

print $cgi->header(
		-type=>'text/html',
		-charset=>'utf-8'
);

#print encode('cp1251', $html);
print $html;