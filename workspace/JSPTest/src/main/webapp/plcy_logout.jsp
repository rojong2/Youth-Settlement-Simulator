<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
session.invalidate();
response.sendRedirect("plcy.jsp");
%>
</body>
</html>
<!-- 로그아웃 세션 종료하는 기능 -->