<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<style type="text/css">
      body {
        font: 300 112.5%/1.5em "Helvetica", "Arial", sans-serif;
        margin: 3em 3em 6em;
        padding: 0;
      }

      h1 {
        font-size: 3em;
        line-height: 1em;
        text-align: center;
        margin: 0.5em 0;
      }

</style>

<head>
<h1>Welcome to MySchedule!</h1>
<article>Enter your username and password to login</article><br>

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Login page</title>
<script type="text/javascript">
$(document).ready(function()
{
	$("#submit").click(function()
	{
		checkLogin();
	});
});

function checkLogin()
{
   $.ajax({
        type: "POST",
        url: "LoginServlet",
        async: false,
        data: { username : $('#username').val(),
        		password : $('#password').val()  }
      }).done(function(msg) 
      {
        if(msg.length > 0 && msg != 'invalid')
        {
        	$("#message").text("Valid user");
			//window.location.replace("Courses.jsp?user="+msg);
			var url = 'Courses.jsp';
			var form = $('<form action="' + url + '" method="post">' +
			  '<input type="hidden" name="user" value="' + msg + '" />' +
			  '</form>');
			$('body').append(form);
			$(form).submit();
        }
        else
        {
        	$("#message").text("Please check your username and/or password");
        }
        $("#message").show();
      });
}

</script>
</head>
<body bgcolor=#fefee2>
<form id="LoginForm" method="post" action="LoginServlet">
Username<input type="text" name="username" id="username" placeholder="FirstName LastName" autofocus required><br>
Password<input type="password" name="password" id="password" placeholder="Password" required><br>
<input type="button" value="Submit" id="submit">
<input type="button" value="Clear">
<div id = "message" style="display:none">
</div>
</form> 
</body>
</html>