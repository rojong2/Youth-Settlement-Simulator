<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
Connection conn = null;

String url = "jdbc:mysql://localhost:3306/JSPDB";
String user = "root";
String password = "1234";

Class.forName("com.mysql.jdbc.Driver");
conn = DriverManager.getConnection(url, user, password);	

    request.setCharacterEncoding("UTF-8");
    
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String passwd = request.getParameter("passwd");
    String live = request.getParameter("live");
    int livecode = 11;
    if(live != null) {
        if(live.equals("Seoul"))
            livecode = 11;
        else if (live.equals("Busan"))
            livecode = 21;
        else if (live.equals("Daegu"))
            livecode = 22;
        else if (live.equals("Incheon"))
            livecode = 23;
        else if (live.equals("Gwangju"))
            livecode = 24;
        else if (live.equals("Daejeon"))
            livecode = 25;
        else if (live.equals("Ulsan"))
            livecode = 26;
        else if (live.equals("Sejong"))
            livecode = 29;
        else if (live.equals("Gyeonggi"))
            livecode = 31;
        else if (live.equals("Gangwon"))
            livecode = 32;
        else if (live.equals("Chungbuk"))
            livecode = 33;
        else if (live.equals("Chungnam"))
            livecode = 34;
        else if (live.equals("Jeonbuk"))
            livecode = 35;
        else if (live.equals("Jeonnam"))
            livecode = 36;
        else if (live.equals("Gyeongbuk"))
            livecode = 37;
        else if (live.equals("Gyeongnam"))
            livecode = 38;
        else if (live.equals("jeju"))
            livecode = 39;
    }

    Statement stmt = null;
    try {
        String sql = "INSERT INTO USER(id, name, passwd, live,livecode) VALUES('" + id + "','" + name + "','" + passwd + "','" + live + "','" + livecode + "')";
        stmt = conn.createStatement();
        stmt.executeUpdate(sql);
        response.sendRedirect("login.jsp");
    } catch (SQLException ex) {
        out.println("회원가입 실패.<br>");
        out.println("SQLException: " + ex.getMessage());
    } finally {
        if (stmt != null)
            stmt.close();
        if (conn != null)
            conn.close();
    }
%>