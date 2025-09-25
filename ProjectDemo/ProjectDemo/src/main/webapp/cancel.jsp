<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Payment Cancelled</title>
</head>
<body>
    <h2 style="color: orange;">Payment Cancelled!</h2>
    <p>You have cancelled the payment.</p>

    <h3>Transaction Info:</h3>
    <ul>
        <li>Transaction ID: <%= request.getParameter("tran_id") %></li>
    </ul>

    <a href="cart.jsp">Return to Checkout</a>
</body>
</html>
