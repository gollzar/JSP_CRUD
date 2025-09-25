<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%

if(session == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("admin_login.jsp");
    return;
}
Connection conn = null;
PreparedStatement stmt = null;

try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");

    DiskFileItemFactory factory = new DiskFileItemFactory();
    ServletFileUpload upload = new ServletFileUpload(factory);

    List<FileItem> items = upload.parseRequest(request);

    String name = "", description = "", imageName = "";
    double price = 0;
    InputStream imageData = null;

    for (FileItem item : items) {
        if (item.isFormField()) {
            switch (item.getFieldName()) {
                case "name": name = item.getString(); break;
                case "description": description = item.getString(); break;
                case "price": price = Double.parseDouble(item.getString()); break;
            }
        } else {
            imageName = item.getName();
            imageData = item.getInputStream(); 
        }
    }

    String sql = "INSERT INTO products1 (name, price, description, image_name, image_data) VALUES (?, ?, ?, ?, ?)";
    stmt = conn.prepareStatement(sql);
    stmt.setString(1, name);
    stmt.setDouble(2, price);
    stmt.setString(3, description);
    stmt.setString(4, imageName);
    stmt.setBlob(5, imageData);

    int result = stmt.executeUpdate();

    if (result > 0) {
    	out.println("Product saved successfully.<br><a href='add.jsp'>Add Another</a> | <a href='admin_home.jsp'>Admin Home</a>");
    } else {
        out.println("Product not saved.");
    }

} catch (Exception e) {
    out.println("❗ Error: " + e.getMessage());
} finally {
    if (stmt != null) try { stmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
