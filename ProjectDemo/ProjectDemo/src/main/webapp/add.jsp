<%@ page import="javax.servlet.http.HttpSession" %>
<%
    if(session == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("admin_login.jsp");
        return;
    }
%>
<html>
<head><title>Add Product</title></head>
<body>
<h2>Add New Product</h2>
<form action="save.jsp" method="post" enctype="multipart/form-data">
    Name: <input type="text" name="name" required/><br><br>
    Price: <input type="text" name="price" required/><br><br>
    Description:<br><textarea name="description" rows="4" cols="40" required></textarea><br><br>
    Image: <input type="file" name="image" required/><br><br>
    <input type="submit" value="Save Product" />
</form>
<a href="admin_home.jsp">Back to Admin Home</a>
</body>
</html>
