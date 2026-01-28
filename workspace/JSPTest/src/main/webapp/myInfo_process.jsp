<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");
String sessionId = (String)session.getAttribute("id");
if(sessionId == null) {
    response.sendRedirect("login.jsp");
    return;
}

String newName = request.getParameter("newName");
String newLive = request.getParameter("newLive");
String newLiveCode = request.getParameter("newLiveCode");

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    String dbURL = "jdbc:mysql://localhost:3306/JSPDB";
    String dbUser = "root";
    String dbPassword = "1234";
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

    String sql = "UPDATE user SET name=?, live=?, liveCode=? WHERE id=?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, newName);
    pstmt.setString(2, newLive);
    pstmt.setString(3, newLiveCode);
    pstmt.setString(4, sessionId);
    
    int result = pstmt.executeUpdate();
    
    if(result > 0) {
        session.setAttribute("name", newName);
    }
    
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(pstmt != null) pstmt.close();
    if(conn != null) conn.close();
}

response.sendRedirect("myInfo.jsp");
%>
<script>
</script>