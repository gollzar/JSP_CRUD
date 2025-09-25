<%@ page import="java.sql.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement ps = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","a12345");
        ps = conn.prepareStatement("INSERT INTO users1 (username, password, role) VALUES (?, ?, 'customer')");
        ps.setString(1, username);
        ps.setString(2, password); // Add hashing for real apps
        ps.executeUpdate();
        out.println("Registration successful! <a href='user_login.jsp'>Login now</a>");
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if(ps != null) ps.close();
        if(conn != null) conn.close();
    }
%>
