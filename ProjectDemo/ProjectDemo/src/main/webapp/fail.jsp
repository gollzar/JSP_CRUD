<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Payment Failed</title>
</head>
<body>
    <h2 style="color: red;">Payment Failed!</h2>
    <p>Sorry, your payment was not successful.</p>

    <h3>Transaction Details:</h3>
    <ul>
        <li>Transaction ID: <%= request.getParameter("tran_id") %></li>
        <li>Status: <%= request.getParameter("status") %></li>
        <li>Error: <%= request.getParameter("error") != null ? request.getParameter("error") : "N/A" %></li>
    </ul>

    <a href=index.jsp>Try Again</a>
</body>
</html>
