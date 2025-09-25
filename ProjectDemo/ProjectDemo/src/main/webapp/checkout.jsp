<%@ page import="java.util.*, java.sql.*, java.net.*, java.io.*" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<% 
//out.println("Step 1: Starting checkout page<br>");

/* // Get session
HttpSession httpSession = request.getSession(false);
if (httpSession == null) {
    //out.println("Step 2: No session found<br>");
    return;
} */

// Get cart from session
Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
if (cart == null || cart.isEmpty()) {
    //out.println("Step 3: Cart is empty or null<br>");
    return;
}

//out.println("Step 4: Retrieved cart from session<br>");

// Dummy user info (replace with actual logged-in user data)
session.setAttribute("name", "Test User");
session.setAttribute("email", "test@example.com");
session.setAttribute("phone", "01700000000");
session.setAttribute("address", "Dhaka, Bangladesh");
session.setAttribute("city", "Dhaka");
session.setAttribute("postcode", "1205");
session.setAttribute("country", "Bangladesh");

//out.println("Step 5: Dummy user info added<br>");

// Get user info
String customerName = (String)session.getAttribute("name");
String email = (String)session.getAttribute("email");
String phone = (String)session.getAttribute("phone");
String address = (String)session.getAttribute("address");
String city = (String)session.getAttribute("city");
String postcode = (String)session.getAttribute("postcode");
String country = (String)session.getAttribute("country");
String userId="";
String username = (String)session.getAttribute("username");

if (customerName == null || email == null || phone == null || address == null) {
    //out.println("Step 6: Missing user info<br>");
    return;
}
//out.println("Step 7: Got user info<br>");

// DB setup
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

double total = 0.0;
StringBuilder productNames = new StringBuilder();

try {
    out.println("Do you want ot proceed to payment?");
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "system", "a12345");

    for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
        int productId = entry.getKey();
        int quantity = entry.getValue();

        ps = conn.prepareStatement("SELECT name, price FROM products1 WHERE id = ?");
        ps.setInt(1, productId);
        rs = ps.executeQuery();

        if (rs.next()) {
            String name = rs.getString("name");
            double price = rs.getDouble("price");
            total += price * quantity;

            if (productNames.length() > 0) {
                productNames.append(",");
            }
            productNames.append(name);
        }
    }
    //out.println("Step 9: Fetched all product info<br>");
} catch (Exception e) {
    //out.println("DB Error: " + e.getMessage() + "<br>");
    e.printStackTrace(new PrintWriter(out));
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
		
		
conn = null;
PreparedStatement psUser = null;
PreparedStatement psOrder = null;
PreparedStatement psOrderItem = null;
ResultSet rsUser = null;
try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");

    // Get user ID from users1
    psUser = conn.prepareStatement("SELECT id FROM users1 WHERE username = ?");
    psUser.setString(1, username);
    rsUser = psUser.executeQuery();

    if (!rsUser.next()) {
        out.println("User not found.");
        return;
    }

    int user = rsUser.getInt("id");
    userId = String.valueOf(user);
    
    
}
catch(Exception e) {
    out.println("Error: " + e.getMessage());
    e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    try { if (rsUser != null) rsUser.close(); } catch(Exception e) {}
    try { if (psUser != null) psUser.close(); } catch(Exception e) {}
    try { if (conn != null) conn.close(); } catch(Exception e) {}
}





//out.println("Step 10: Total amount = " + total + "<br>");
//out.println("Step 11: Product names = " + productNames.toString() + "<br>");
%>

<!-- Step 12: Redirect to SSLCommerz -->
<form method="post" action="processPayment.jsp">
    <input type="hidden" name="store_id" value="ius6892e0cad91c6">
    <input type="hidden" name="store_passwd" value="ius6892e0cad91c6@ssl">
    <input type="hidden" name="total_amount" value="<%= total %>">
    <input type="hidden" name="currency" value="BDT">
    <input type="hidden" name="tran_id" value="TID<%= System.currentTimeMillis() %>">

    <!-- Customer Information -->
    <input type="hidden" name="cus_name" value="<%= customerName %>">
    <input type="hidden" name="cus_email" value="<%= email %>">
    <input type="hidden" name="cus_add1" value="<%= address %>">
    <input type="hidden" name="cus_city" value="<%= city %>">
    <input type="hidden" name="cus_postcode" value="<%= postcode %>">
    <input type="hidden" name="cus_country" value="<%= country %>">
    <input type="hidden" name="cus_phone" value="<%= phone %>">
    <input type="hidden" name="userId" value="<%= userId %>">

    <!-- Shipment Information -->
    <input type="hidden" name="shipping_method" value="Courier">
    <input type="hidden" name="ship_name" value="<%= customerName %>">
    <input type="hidden" name="ship_add1" value="<%= address %>">
    <input type="hidden" name="ship_city" value="<%= city %>">
    <input type="hidden" name="ship_postcode" value="<%= postcode %>">
    <input type="hidden" name="ship_country" value="<%= country %>">

    <!-- Product info -->
    <input type="hidden" name="product_name" value="<%= productNames.toString() %>">
    <input type="hidden" name="product_category" value="General">
    <input type="hidden" name="product_profile" value="physical-goods">

<!--     Success/Fail URLs
    <input type="hidden" name="success_url" value="http://localhost:8080/ProjectDemo/success.jsp">
    <input type="hidden" name="fail_url" value="http://localhost:8080/ProjectDemo/fail.jsp">
    <input type="hidden" name="cancel_url" value="http://localhost:8080/ProjectDemo/cancel.jsp">
 -->
    <br><br>
    <input type="submit" value="Proceed to Payment">
</form>
<form action="cart.jsp">
    <button type="submit">I'm Not Sure yet</button>
</form>




