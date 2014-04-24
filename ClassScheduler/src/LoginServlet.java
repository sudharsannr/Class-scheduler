


import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String responseString = "invalid";
		if(username != null && password != null)
		{
			if(username.length() > 0 && password.length() > 0)
			{
				InputStream propStream = request.getServletContext().getResourceAsStream("/WEB-INF/DBProperties.property");
				responseString = checkLogin(username, password, propStream).trim();
			}
		}
        response.getWriter().write(responseString);
	}

	private String checkLogin(String username, String password, InputStream propStream)
	{
		StringBuilder resultSB = new StringBuilder();
		Properties myprop = new Properties();
		try
		{
			myprop.load(propStream);
			Connection connection = null;
			StringBuffer connectionString = new StringBuffer();
			connectionString.append("jdbc:oracle:thin:@")
			.append(myprop.getProperty("host"))
			.append(":")
			.append(myprop.getProperty("port"))
			.append(":")
			.append(myprop.getProperty("sid"));
			Class.forName("oracle.jdbc.driver.OracleDriver");
			connection = DriverManager.getConnection(connectionString.toString(), myprop.getProperty("username"),myprop.getProperty("password"));
			if (connection != null) 
			{
				Statement stmt = null;
				String query = "SELECT STUDENTID FROM STUDENTS WHERE STUDENTNAME = ? AND PASSWORD = ?";
				try 
				{
					PreparedStatement ps = connection.prepareStatement(query);
					ps.setString(1, username);
					ps.setString(2, password);
					stmt = connection.createStatement();
					ResultSet rs = ps.executeQuery();
					while (rs.next()) 
						resultSB.append(rs.getString(1));
					stmt.close();
					rs.close();
					connection.close();
				} 
				catch (SQLException e ) 
				{
					e.printStackTrace();
				} 
				finally 
				{
					try
					{
						if (stmt != null) 
							stmt.close();
						if (connection != null)
							connection.close();
					}
					catch (SQLException e)
					{
						e.printStackTrace();
					} 
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return resultSB.toString();
	}
}
