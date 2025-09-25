<%@ page import="javax.servlet.http.HttpSession" %>
<%
    if(session == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("admin_login.jsp");
        return;
    }
%>
<html>
<head><title>Admin Dashboard</title></head>
<body>
<h2>Welcome Admin: <%= session.getAttribute("username") %></h2>
<ul>
    <li><a href="add.jsp">Add Product</a></li>
    <li><a href="index.jsp">View Products</a></li>
    <li><a href="logout.jsp">Logout</a></li>
</ul>
</body>
</html>
