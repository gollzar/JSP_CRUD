<%@ page import="java.util.*, java.sql.*, java.net.*, java.io.*, org.json.JSONObject, org.json.JSONArray" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
response.setContentType("text/html;charset=UTF-8");
out.println("Starting payment processing...<br>");


// Get cart from session
Map<Integer, Integer> cart = (Map<Integer, Integer>)session.getAttribute("cart");
if (cart == null || cart.isEmpty()) {
    out.println("Cart is empty or null.<br>");
    return;
}


JSONArray cartArray = new JSONArray();

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");

    for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
        int productId = entry.getKey();
        int quantity = entry.getValue();

        ps = conn.prepareStatement("SELECT name, price FROM products1 WHERE id = ?");
        ps.setInt(1, productId);
        rs = ps.executeQuery();

        if (rs.next()) {
            JSONObject item = new JSONObject();
            item.put("id", productId);
            item.put("name", rs.getString("name"));
            item.put("price", rs.getDouble("price"));
            item.put("quantity", quantity);
            cartArray.put(item);
        }
    }
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
    if (conn != null) conn.close();
}

String cartJson = cartArray.toString();
session.setAttribute("cartJson", cartJson); // save JSON for later (e.g. success.jsp)



// Dummy user info or get from session/DB (replace with real data)
String customerName = (String)session.getAttribute("name");
String email = (String)session.getAttribute("email");
String phone = (String)session.getAttribute("phone");
String address = (String)session.getAttribute("address");
String city = (String)session.getAttribute("city");
String postcode = (String)session.getAttribute("postcode");
String country = (String)session.getAttribute("country");

String username = (String) session.getAttribute("username");
String userId = request.getParameter("userId");

conn = null;
/* PreparedStatement psUser = null;
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
    String userId = String.valueOf(user);
    out.print(userId);
    
    
}
 catch(Exception e) {
    out.println("Error: " + e.getMessage());
    e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    try { if (rsUser != null) rsUser.close(); } catch(Exception e) {}
    try { if (psUser != null) psUser.close(); } catch(Exception e) {}
    try { if (conn != null) conn.close(); } catch(Exception e) {}
}
 */


// If any user info is missing, set dummy data for test
if (customerName == null) customerName = "Test User";
if (email == null) email = "test@example.com";
if (phone == null) phone = "01700000000";
if (address == null) address = "Dhaka";
if (city == null) city = "Dhaka";
if (postcode == null) postcode = "1205";
if (country == null) country = "Bangladesh";

// Calculate total and get product names from DB
double total = 0.0;
StringBuilder productNames = new StringBuilder();


ps = null;
rs = null;
try {
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
                productNames.append(", ");
            }
            productNames.append(name);
        }
        if (rs != null) { rs.close(); rs = null; }
        if (ps != null) { ps.close(); ps = null; }
    }
} catch (Exception e) {
    out.println("DB Error: " + e.getMessage() + "<br>");
    e.printStackTrace(new PrintWriter(out));
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}


String encodedCart = URLEncoder.encode(cartJson, "UTF-8");
//response.sendRedirect("success.jsp?cartJson=" + encodedCart);

// Prepare transaction ID
String transactionId = "TID" + System.currentTimeMillis();

String successUrl = "http://localhost:8081/ProjectDemo/success.jsp?cartJson=" + encodedCart + "&userId=" + userId;

// Now encode the full URL for SSLCommerz
String encodedSuccessUrl = URLEncoder.encode(successUrl, "UTF-8");


try {
    // Setup connection to SSLCommerz API
    String sslUrl = "https://sandbox.sslcommerz.com/gwprocess/v4/api.php";
    URL url = new URL(sslUrl);
    HttpURLConnection connSSL = (HttpURLConnection) url.openConnection();
    connSSL.setRequestMethod("POST");
    connSSL.setDoOutput(true);

    // Prepare POST data with all required fields and URL encoding
    String postData = "store_id=ius6892e0cad91c6"
            + "&store_passwd=ius6892e0cad91c6@ssl"
            + "&total_amount=" + total
            + "&currency=BDT"
            + "&tran_id=" + transactionId
            + "&cus_name=" + URLEncoder.encode(customerName, "UTF-8")
            + "&cus_email=" + URLEncoder.encode(email, "UTF-8")
            + "&cus_phone=" + URLEncoder.encode(phone, "UTF-8")
            + "&cus_add1=" + URLEncoder.encode(address, "UTF-8")
            + "&cus_city=" + URLEncoder.encode(city, "UTF-8")
            + "&cus_postcode=" + URLEncoder.encode(postcode, "UTF-8")
            + "&cus_country=" + URLEncoder.encode(country, "UTF-8")
            + "&shipping_method=Courier"
            + "&ship_name=" + URLEncoder.encode(customerName, "UTF-8")
            + "&ship_add1=" + URLEncoder.encode(address, "UTF-8")
            + "&ship_city=" + URLEncoder.encode(city, "UTF-8")
            + "&ship_postcode=" + URLEncoder.encode(postcode, "UTF-8")
            + "&ship_country=" + URLEncoder.encode(country, "UTF-8")
            + "&product_name=" + URLEncoder.encode(productNames.toString(), "UTF-8")
            + "&product_category=General"
            + "&product_profile=physical-goods"
            + "&success_url=" + encodedSuccessUrl
            + "&fail_url=" + URLEncoder.encode("http://localhost:8081/ProjectDemo/fail.jsp", "UTF-8")
            + "&cancel_url=" + URLEncoder.encode("http://localhost:8081/ProjectDemo/cancel.jsp", "UTF-8");

    // Send POST data
    OutputStream os = connSSL.getOutputStream();
    os.write(postData.getBytes());
    os.flush();
    os.close();

    // Read response JSON
    BufferedReader br = new BufferedReader(new InputStreamReader(connSSL.getInputStream()));
    StringBuilder sb = new StringBuilder();
    String line;
    while ((line = br.readLine()) != null) {
        sb.append(line);
    }
    br.close();

    // Parse JSON response
    JSONObject json = new JSONObject(sb.toString());
    String status = json.getString("status");

    if ("SUCCESS".equalsIgnoreCase(status)) {
        String gatewayUrl = json.getString("GatewayPageURL");
        response.sendRedirect(gatewayUrl); // Redirect to SSLCommerz payment UI
    } else {
        out.println("Payment initialization failed.<br>");
        out.println("Reason: " + json.optString("failedreason", "Unknown") + "<br>");
        out.println("Full response: " + sb.toString());
    }

} catch (Exception e) {
    out.println("Error during payment processing: " + e.getMessage() + "<br>");
    e.printStackTrace(new PrintWriter(out));
}
%>
