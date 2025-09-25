<%@ page import="java.sql.*, java.util.*, org.json.*" %>
<%@ page import="java.net.URLDecoder" %>
<%
//String userIdStr = request.getParameter("value_a");



/* String tranId = request.getParameter("tran_id");
String amountStr = request.getParameter("amount"); // optional
 */ 
/* if (userIdStr == null || cartJson == null || tranId == null) {
    out.println("Missing transaction/user/cart info!");
    return;
}  */

/* out.println("Received cartJson: " + cartJson + "<br>"); */



/* int userId = Integer.parseInt(userIdStr);
double totalAmount = (amountStr != null) ? Double.parseDouble(amountStr) : 0.0; */

//String userId = request.getParameter("id");
//String cartJson = request.getParameter("cartJson");


//String cartJson = URLDecoder.decode(request.getParameter("cartJson"), "UTF-8");
String cartJsonEncoded= request.getParameter("cartJson");
String cartJson = URLDecoder.decode(cartJsonEncoded, "UTF-8");


// Get userId
String userIdStr = request.getParameter("userId");
int userId = Integer.parseInt(userIdStr);


Connection conn = null;
PreparedStatement psOrder = null;
PreparedStatement psItem = null;
try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection(
        "jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");
    conn.setAutoCommit(false);

    JSONArray cartArray = new JSONArray(cartJson);
    
    
	double total=0;
    for (int i = 0; i < cartArray.length(); i++) {
        JSONObject item = cartArray.getJSONObject(i);
        total=total+ (item.getInt("quantity")*item.getInt("price"));
    }
    
    
    // Insert into orders1
    psOrder = conn.prepareStatement(
        "INSERT INTO orders1 (user_id, total) VALUES (?, ?)",
        new String[] {"id"} // get generated id
    );
    psOrder.setInt(1, userId);
    psOrder.setDouble(2, total);
    psOrder.executeUpdate();

    // Get generated order ID
    ResultSet rs = psOrder.getGeneratedKeys();
    int orderId = -1;
    if (rs.next()) orderId = rs.getInt(1);
    rs.close();

    // Insert order items

    psItem = conn.prepareStatement(
        "INSERT INTO order_items1 (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)"
    );
    
    for (int i = 0; i < cartArray.length(); i++) {
        JSONObject item = cartArray.getJSONObject(i);
        psItem.setInt(1, orderId);
        psItem.setInt(2, item.getInt("id"));
        psItem.setInt(3, item.getInt("quantity"));
        psItem.setDouble(4, item.getDouble("price"));
        psItem.executeUpdate();
    }

    conn.commit();
/*     out.println("<h2>Payment successful!</h2>");
    out.println("<p>Order ID: " + orderId + "</p>"); */

} catch(Exception e) {
    if (conn != null) try { conn.rollback(); } catch(Exception ex) {}
    out.println("DB Error: " + e.getMessage());
    e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    try { if (psItem != null) psItem.close(); } catch(Exception e) {}
    try { if (psOrder != null) psOrder.close(); } catch(Exception e) {}
    try { if (conn != null) conn.close(); } catch(Exception e) {}
}
%>


<html>
<head>
    <title>Payment Success</title>
</head>
<body>
    <h2 style="color: green;">Payment Successful!</h2>
    <p>Thank you for your purchase.</p>

    <h3>Transaction Details:</h3>
    <ul>
        <li>Transaction ID: <%= request.getParameter("tran_id") %></li>
        <li>Amount: <%= request.getParameter("amount") %> BDT</li>
        <li>Status: <%= request.getParameter("status") %></li>
        <li>Card Type: <%= request.getParameter("card_type") %></li>
        <li>Bank Transaction ID: <%= request.getParameter("bank_tran_id") %></li>
        <li>Validation ID: <%= request.getParameter("val_id") %></li>
    </ul>

    <a href="index.jsp">Return to Home</a>
</body>
</html>