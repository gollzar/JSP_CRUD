<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate session
    session.invalidate();
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="2;URL=user_login.jsp" />
    <title>Logging Out</title>
</head>
<body>
    <h2>You have been successfully logged out.</h2>
    <p>Redirecting to <a href="user_login.jsp">Login Page</a>...</p>
</body>
</html>
