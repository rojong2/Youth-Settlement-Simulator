<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
Connection conn = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    String url = "jdbc:mysql://localhost:3306/JSPDB";
    String user = "root";
    String password = "1234";
    conn = DriverManager.getConnection(url, user, password);

    request.setCharacterEncoding("UTF-8");
    
    String id = request.getParameter("id");
    String passwd = request.getParameter("passwd");

    String sql = "SELECT * FROM user WHERE id = ? AND passwd = ?";
    PreparedStatement psmt = conn.prepareStatement(sql);
    psmt.setString(1, id);
    psmt.setString(2, passwd);
    ResultSet rs = psmt.executeQuery();

    if (rs.next()) {
        session.setAttribute("id", id);
        session.setMaxInactiveInterval(60*60);
        response.sendRedirect("main.jsp");
    } else {
        request.setAttribute("errorMessage", "아이디 또는 비밀번호가 일치하지 않습니다.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
    rs.close();
    psmt.close();
} catch (Exception e) {
    request.setAttribute("errorMessage", "로그인 처리 중 오류가 발생했습니다: " + e.getMessage());
    request.getRequestDispatcher("login.jsp").forward(request, response);
} finally {
    if (conn != null) conn.close();
}
%>
