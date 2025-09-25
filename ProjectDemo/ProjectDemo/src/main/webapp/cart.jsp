<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    

    // Get or create the cart from session
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if(cart == null) cart = new HashMap<>();

    // Handle removing a product from the cart
    String removeProductIdStr = request.getParameter("removeProductId");
    if(removeProductIdStr != null) {
        int removeProductId = Integer.parseInt(removeProductIdStr);
        cart.remove(removeProductId);
    }

    // Handle adding/updating quantity of a product in the cart
    String productIdStr = request.getParameter("productId");
    String quantityStr = request.getParameter("quantity");

    if(productIdStr != null && quantityStr != null) {
        int productId = Integer.parseInt(productIdStr);
        int quantity = Integer.parseInt(quantityStr);

        if(quantity <= 0) {
            // Remove if quantity is 0 or negative
            cart.remove(productId);
        } else {
            cart.put(productId, quantity);
        }
    }

    // Save cart back to session
    session.setAttribute("cart", cart);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Your Cart</title>
    <style>
        .cart-item {
            border: 1px solid #ccc; 
            padding: 10px; 
            margin-bottom: 10px;
            width: 400px;
        }
        form {
            display: inline;
        }
        input[type=number] {
            width: 50px;
        }
    </style>
</head>
<body>
<h2>Your Shopping Cart</h2>
<%
    if(cart.isEmpty()) {
%>
    <p>Your cart is empty.</p>
    <a href="index.jsp">Shop Now</a>
<%
    } else {
        double total = 0.0;

        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");
        PreparedStatement ps = conn.prepareStatement("SELECT id, name, price FROM products1 WHERE id = ?");

        for(Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            int pid = entry.getKey();
            int qty = entry.getValue();

            ps.setInt(1, pid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                String pname = rs.getString("name");
                double price = rs.getDouble("price");
                double subtotal = price * qty;
                total += subtotal;
%>
    <div class="cart-item">
        <b><%= pname %></b><br/>
        Quantity: <%= qty %><br/>
        Price each: $<%= price %><br/>
        Subtotal: $<%= subtotal %><br/>

        <!-- Remove button -->
        <form method="post" action="cart.jsp">
            <input type="hidden" name="removeProductId" value="<%= pid %>" />
            <button type="submit">Remove</button>
        </form>

        <!-- Update quantity form -->
        <form method="post" action="cart.jsp" style="margin-left:10px;">
            <input type="hidden" name="productId" value="<%= pid %>" />
            <input type="number" name="quantity" value="<%= qty %>" min="0" />
            <button type="submit">Update</button>
        </form>
    </div>
<%
            }
            rs.close();
        }
        ps.close();
        conn.close();
%>
    <h3>Total: $<%= total %></h3>
    <a href="checkout.jsp">Proceed to Checkout</a><br/><br/>
    <a href="index.jsp">Continue Shopping</a>
<%
    }
%>
</body>
</html>
