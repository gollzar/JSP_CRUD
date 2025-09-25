<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","a12345");
        ps = conn.prepareStatement("SELECT * FROM USERS1 WHERE USERNAME=? AND PASSWORD=? AND ROLE=?");
        ps.setString(1, username);
        ps.setString(2, password);
        ps.setString(3, "admin");
        
        rs = ps.executeQuery();

        if(rs.next()) {

            session.setAttribute("username", username);
            session.setAttribute("role", "admin");
            response.sendRedirect("admin_home.jsp");
        } else {
            out.println("Invalid admin login. <a href='admin_login.jsp'>Try again</a>");
        }

    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if(rs != null) rs.close();
        if(ps != null) ps.close();
        if(conn != null) conn.close();
    }
%>
