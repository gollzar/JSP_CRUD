<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM users1 WHERE username=? AND password=?");
    ps.setString(1, username);
    ps.setString(2, password);
    ResultSet rs = ps.executeQuery();

    if(rs.next()) {
        session.setAttribute("username", username);
        session.setAttribute("role", rs.getString("role"));
        response.sendRedirect("index.jsp");
    } else {
        out.println("<script>alert('Invalid credentials');location.href='user_login.jsp';</script>");
    }

    rs.close();
    ps.close();
    conn.close();
%>