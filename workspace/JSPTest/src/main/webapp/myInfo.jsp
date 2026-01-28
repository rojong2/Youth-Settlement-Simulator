<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String sessionId = (String)session.getAttribute("id");
if(sessionId == null) {
    response.sendRedirect("login.jsp");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String currentName = "";
String currentLive = "";
String currentLiveCode = "";

try {
    Class.forName("com.mysql.jdbc.Driver");
    String dbURL = "jdbc:mysql://localhost:3306/JSPDB";
    String dbUser = "root";
    String dbPassword = "1234";
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
    String sql = "SELECT * FROM user WHERE id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, sessionId);
    rs = pstmt.executeQuery();
    if(rs.next()) {
        currentName = rs.getString("name");
        currentLive = rs.getString("live");
        currentLiveCode = rs.getString("liveCode");
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) rs.close();
    if(pstmt != null) pstmt.close();
    if(conn != null) conn.close();
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>회원 정보</title>
<link rel="stylesheet" href="css/myInfo.css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
<script>
    // 지역 코드 매핑
    const regionCodes = {
        "Seoul": "11",
        "Busan": "21",
        "Deagu": "22",
        "Incheon": "23",
        "Gwangju": "24",
        "Daejeon": "25",
        "Ulsan": "26",
        "Sejong": "29",
        "Gyeonggi": "31",
        "Gangwon": "32",
        "Chungbuk": "33",
        "Chungnam": "34",
        "Jeonbuk": "35",
        "Jeonnam": "36",
        "Gyeongbuk": "37",
        "Gyeongnam": "38",
        "jeju": "39"
    };

    // 섹션 전환 함수
    function showSection(sectionName) {
        document.getElementById('info-section').style.display = 'none';
        document.getElementById('edit-section').style.display = 'none';
        document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
        if(sectionName === 'info') {
            document.getElementById('info-section').style.display = 'block';
            document.querySelector('[href="#info"]').classList.add('active');
        } else if(sectionName === 'edit') {
            document.getElementById('edit-section').style.display = 'block';
            document.querySelector('[href="#edit"]').classList.add('active');
        }
    }

    // 지역 선택 시 코드 자동 설정
    document.addEventListener('DOMContentLoaded', () => {
        document.getElementById('regionSelect').value = "<%= currentLive %>";
        document.getElementById('regionSelect').addEventListener('change', () => {
            const selectedRegion = document.getElementById('regionSelect').value;
            document.getElementById('newLiveCode').value = regionCodes[selectedRegion] || '';
        });
    });
    function validateForm() {
        const name = document.getElementById('newName').value.trim();
        const region = document.getElementById('regionSelect').value;
        
        if(name === '') {
            alert('이름을 입력해주세요.');
            return false;
        }
        
        if(name.length < 2) {
            alert('이름은 최소 2글자 이상 입력해주세요.');
            return false;
        }
        
        if(region === '') {
            alert('거주 지역을 선택해주세요.');
            return false;
        }
        
        return confirm('정보를 수정하시겠습니까?');
    }
</script>
</head>
<body>
	<nav class="navbar">
		<a href="main.jsp" class="navbar-brand">My Info
		</a>
		<button class="navbar-toggle" onclick="toggleMenu()">
			<i class="fas fa-bars"></i>
		</button>
		<ul class="navbar-menu" id="navbarMenu">
			<li><a href="main.jsp">HOME</a></li>
			<li><a href="plcy.jsp">청년 맞춤 정책</a></li>
			<li><a href="simul.jsp">정책 시뮬레이터</a></li>
			<%
			if ((String) session.getAttribute("id") == null || !request.isRequestedSessionIdValid()) {
			%>
			<li><a href="login.jsp">Login</a></li>
			<%
			} else {
			%>
			<li><a href="myInfo.jsp"  class="active">마이페이지</a></li>
			<li><a href="main_logout.jsp">Logout</a></li>
			<%
			}
			%>
		</ul>
	</nav>

	<div class="profile-container">
    <div class="main-content-wrapper">
        <!-- 사이드바 -->
        <div class="sidebar-profile">
            <div class="profile-card">
                <div class="profile-header">
                    <i class="fas fa-user-circle profile-icon"></i>
                    <h2><%= session.getAttribute("id") %>님</h2>
                </div>
                <nav class="profile-nav">
                    <a href="#info" class="nav-item active" onclick="showSection('info')">기본 정보</a>
                    <a href="#edit" class="nav-item" onclick="showSection('edit')">정보 변경</a>
                </nav>
            </div>
        </div>
        <!-- 컨텐츠 -->
        <div class="profile-content">
            <!-- 기본 정보 -->
            <div id="info-section" style="display:block;">
                <div class="info-card">
                    <div class="card-header">
                        <h3>기본 정보</h3>
                    </div>
                    <div class="card-body">
                        <div class="info-item">
                            <label>아이디</label>
                            <div class="info-value"><%= session.getAttribute("id") %></div>
                        </div>
                        <div class="info-item">
                            <label>이름</label>
                            <div class="info-value"><%= currentName %></div>
                        </div>
                        <div class="info-item">
                            <label>거주 지역</label>
                            <div class="info-value"><%= currentLive %></div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 정보 변경 -->
            <div id="edit-section" style="display:none;">
                <form id="updateForm" action="myInfo_process.jsp" method="post" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="newName">이름</label>
                        <input type="text" id="newName" name="newName" value="<%= currentName %>" class="form-control" required maxlength="20" />
                    </div>
                    <div class="form-group">
                        <label for="regionSelect">거주 지역</label>
                        <select name="newLive" id="regionSelect" class="form-control" required>
                            <option value="">선택하세요</option>
                            <option value="Seoul">서울특별시</option>
                            <option value="Busan">부산광역시</option>
                            <option value="Daegu">대구광역시</option>
                            <option value="Incheon">인천광역시</option>
                            <option value="Gwangju">광주광역시</option>
                            <option value="Daejeon">대전광역시</option>
                            <option value="Ulsan">울산광역시</option>
                            <option value="Sejong">세종특별자치시</option>
                            <option value="Gyeonggi">경기도</option>
                            <option value="Gangwon">강원도</option>
                            <option value="Chungbuk">충청북도</option>
                            <option value="Chungnam">충청남도</option>
                            <option value="Jeonbuk">전라북도</option>
                            <option value="Jeonnam">전라남도</option>
                            <option value="Gyeongbuk">경상북도</option>
                            <option value="Gyeongnam">경상남도</option>
                            <option value="jeju">제주특별자치도</option>
                        </select>
                        <input type="hidden" id="newLiveCode" name="newLiveCode" value="<%= currentLiveCode %>" />
                    </div>
                    <div class="form-buttons">
                        <button type="submit" class="update-btn"><i class="fas fa-save"></i> 저장</button>
                        <button type="button" class="cancel-btn" onclick="showSection('info')"><i class="fas fa-times"></i> 취소</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
</script>
</body>
</html>
