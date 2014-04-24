<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*, java.io.IOException, java.io.InputStream, java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException, java.sql.Statement, java.util.Properties, java.io.FileInputStream" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Course page</title>
<script src="skycons.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="http://maps.googleapis.com/maps/api/js?key=AIzaSyDY0kkJiTPVd2U7aTOAwhc9ySH6oHxOIYM&sensor=false">
</script>
<script type="text/javascript">
/*
 * Call googleMaps api to show the location on Map
 */
 
function gMaps(location)
{
		console.log('success');
	   var address=location + " University of Florida, Gainesville, Florida";
		console.log(address);
	   var map = new google.maps.Map(document.getElementById('map'), { 
	       mapTypeId: google.maps.MapTypeId.ROADMAP,
	       zoom: 17
	   });

	   
	   var geocoder = new google.maps.Geocoder();
		console.log('geocodeer');
	   geocoder.geocode({
	      'address': address
	   }, 
	   function(results, status) {
	      if(status == google.maps.GeocoderStatus.OK) {
	         new google.maps.Marker({
	            position: results[0].geometry.location,
	            map: map
	         });
	         map.setCenter(results[0].geometry.location);
	
}
});
}


/*
 * wea
 */

 function weather(){
 	var apiKey = '31dd13254dc61603b77bd5285024d2bc';
     var url = 'https://api.forecast.io/forecast/';
     var lati = 29.4454179;
     var longi = -82.8692515;
     var data;
     $.getJSON(url + apiKey + "/" + lati + "," + longi + "?callback=?", function(data) {
     var t = "", s = "";
     var n = new Date().getDay();
     var table= "<table>";
                 
     var arr = ["Monday","Tuesday","Wednesday","Thursday", "Friday", "Saturday", "Sunday"];
     for (var i=0, len=arr.length; i<n-1; i++) 
     {
         //alert(arr.slice(0, arr.length).join(","));
         arr.push(arr.shift());
     }
		table +="<tr>";
		var r = "";
		  var iconArray = new Array();
		  var skycons = new Skycons();
		  var skyconsIcon = new Object();
		  skyconsIcon["CLEAR_DAY"] = Skycons.CLEAR_DAY; 
		  skyconsIcon["CLEAR_NIGHT"] = Skycons.CLEAR_NIGHT;
		  skyconsIcon["PARTLY_CLOUDY_DAY"] = Skycons.PARTLY_CLOUDY_DAY;
		  skyconsIcon["PARTLY_CLOUDY_NIGHT"] = Skycons.PARTLY_CLOUDY_NIGHT;
		  skyconsIcon["CLOUDY"] = Skycons.CLOUDY;
		  skyconsIcon["RAIN"] = Skycons.RAIN;
		  skyconsIcon["SLEET"] = Skycons.SLEET;
		  skyconsIcon["SNOW"] = Skycons.SNOW;
		  skyconsIcon["WIND"] = Skycons.WIND;
		  skyconsIcon["FOG"] = Skycons.FOG;
		
     for(var i =  0; i < 7; i++)
		  {
		    var avgTemp = Math.round((data.daily.data[i].temperatureMin + data.daily.data[i].temperatureMax)*10)/20;
		    table += "<tr>";
		    table += "<td>" + arr[i] + "</td>";
			table +="<td>"+ avgTemp + "</td>";
			iconArray[i] = data.daily.data[i].icon.toUpperCase().replace(/\-/g,'_');
		    table += "<td><canvas id=\""+ i + "\" width=\"48\" height=\"48\"></canvas></td>";
		    table += "</tr>";
		  }
     table += "</table>";
		  console.log(table);
		  
       $('#weather').html(table);
      for(var j = 0; j < 7; j++)
    	  {
    	    console.log(j + " " + skyconsIcon[iconArray[j]]);
    	  	skycons.add(j.toString(), skyconsIcon[iconArray[j]]);
    	  }
      skycons.play();
});
          
 }


</script>
</head>
<body bgcolor=#fefee2>
<% String userid = request.getParameter("user"); 
   if (userid != null) { %>
      <H3> Your weekly schedule! Your user-id is :  <I> <%= userid %> </I> </H3>
      <B> <%= runQuery(userid) %> </B> 
      <b>Click the location to view it on Map and for weather forecast </b><HR><BR>
<% }  %>

<table>
<tr>
<td>
	<div id="map" style="width:500px;height:380px;"></div>
</td>
<td>
	<div id="weather" style="width:300px;height:380px;"></div>
</td>
</tr>
</table>
</body>
</html>

<%-- Declare and define the runQuery() method. --%>
<%! private String runQuery(String userid) throws SQLException {
     Statement stmt = null; 
     ResultSet rset = null;
     Connection connection = null;
     String tblResponse = "";
     try 
		{
			Class.forName("oracle.jdbc.driver.OracleDriver");
		 	Properties myprop = new Properties();
			myprop.load(getServletContext().getResourceAsStream("/WEB-INF/DBProperties.property"));
			StringBuffer connectionString = new StringBuffer();
			connectionString.append("jdbc:oracle:thin:@")
		  	.append(myprop.getProperty("host"))
		  	.append(":")
		  	.append(myprop.getProperty("port"))
		  	.append(":")
		  	.append(myprop.getProperty("sid"));
			connection = DriverManager.getConnection(connectionString.toString(), myprop.getProperty("username"),myprop.getProperty("password"));
	        stmt = connection.createStatement();
	        String query = "SELECT S.COURSEID, C.COURSENAME, C.COURSELOCATION, CS.DAYS, CS.PERIOD FROM SUBSCRIPTION S "
			        	   + "INNER JOIN " 
			        	   + "COURSESCHEDULE CS ON S.COURSEID = CS.COURSEID "
			        	   + "INNER JOIN " 
			        	   + "COURSES C ON CS.COURSEID = C.COURSEID "
			        	   + "WHERE S.STUDENTID = ?";
			PreparedStatement ps = connection.prepareStatement(query);
			ps.setInt(1, Integer.parseInt(userid));
			stmt = connection.createStatement();
	        rset = ps.executeQuery();
	        tblResponse = formatResult(rset);
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
	    finally 
	    {
	        if (rset!= null) rset.close(); 
	        if (stmt!= null) stmt.close();
	        if (connection!= null) connection.close();
	    }
       	return tblResponse;
  }
  private String formatResult(ResultSet rset) throws SQLException 
  {
    StringBuffer sb = new StringBuffer();
    if (!rset.next())
      sb.append("<p>No course available for the student<p>\n");
    else 
    {
    	sb.append("<table border='1'>");
    	sb.append("<tr>");
    	sb.append("<td>COURSEID</td>");
    	sb.append("<td>COURSE NAME</td>");
    	sb.append("<td>LOCATION</td>");
    	sb.append("<td>DAYS</td>");
    	sb.append("<td>PERIOD</td>");
    	sb.append("</tr>");
        do 
        {  
        	sb.append("<tr>");
        	sb.append("<td>" + rset.getString(1) + "</td>");
        	sb.append("<td>" + rset.getString(2) + "</td>");
        	sb.append("<td><a href='#' onClick=\"gMaps('" + rset.getString(3) + "');weather();\">" + rset.getString(3) + "</a></td>");
        	sb.append("<td>" + rset.getString(4) + "</td>");
        	sb.append("<td>" + rset.getInt(5) + "</td>");
        	
        	sb.append("</tr>");
        } while (rset.next());
        sb.append("</table>");
    }
    return sb.toString();
  }
%>