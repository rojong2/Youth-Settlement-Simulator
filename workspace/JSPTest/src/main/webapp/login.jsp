<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인 - Density Map</title>
    <link rel="stylesheet" href="css/login.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <nav class="navbar">
        <a href="main.jsp" class="navbar-brand">Login
        </a>
        <button class="navbar-toggle" onclick="toggleMenu()">
        </button>
        <ul class="navbar-menu" id="navbarMenu">
            <li><a href="main.jsp">HOME</a></li>
            <li><a href="plcy.jsp">청년 맞춤 정책</a></li>
            <li><a href="simul.jsp">정책 시뮬레이터</a></li>
            <%
                if((String)session.getAttribute("id")==null || !request.isRequestedSessionIdValid()){
            %>
            <li><a href="login.jsp" class="active">Login</a></li>
            <%
                }else{
            %>
            <li><a href="myInfo.jsp">마이페이지</a></li>
            <li><a href="main_logout.jsp">Logout</a></li>
            <%  } %>
        </ul>
    </nav>

    <div class="auth-container">
        <div class="auth-wrapper">
			<div class="auth-card login-card" id="loginCard">
				<div class="card-header">
					<h2>로그인</h2>
					<p>계정에 로그인하여 서비스를 이용하세요</p>
				</div>
				<div class="card-body">
					<%
					if (session.getAttribute("id") == null) {
					%>
					<form method="post" action="login_process.jsp"
						class="auth-form">
						<div class="form-group">
							<label for="loginId">아이디</label>
							<div class="input-wrapper">
								<i class="fas fa-user"></i> <input type="text" id="loginId"
									name="id"
									value="<%=request.getParameter("id") != null ? request.getParameter("id") : ""%>"
									placeholder="아이디를 입력하세요" required autofocus>
							</div>
						</div>
						<div class="form-group">
							<label for="loginPassword">비밀번호</label>
							<div class="input-wrapper">
								<i class="fas fa-lock"></i> <input type="password"
									id="loginPassword" name="passwd" placeholder="비밀번호를 입력하세요"
									required>
							</div>
						</div>
						<%
						if (request.getAttribute("errorMessage") != null) {
						%>
						<div class="error-message">
							<i class="fas fa-exclamation-circle"></i>
							<%=request.getAttribute("errorMessage")%>
						</div>
						<%
						}
						%>
						<button type="submit" class="auth-btn login-btn">
							<i class="fas fa-sign-in-alt"></i> 로그인
						</button>
					</form>
					<div class="auth-footer">
						<p>
							계정이 없으신가요? <a href="#" onclick="showSignup()">회원가입</a>
						</p>
					</div>
					<%
					} else {
					response.sendRedirect("main.jsp");
					}
					%>
				</div>
			</div>

			<!-- 회원가입 카드 -->
            <div class="auth-card signup-card" id="signupCard" style="display: none;">
                <div class="card-header">
                    <h2>회원가입</h2>
                    <p>새 계정을 만들어 서비스를 시작하세요</p>
                </div>
                <div class="card-body">
                    <form method="post" action="join.jsp" class="auth-form">
                        <div class="form-group">
                            <label for="signupId">아이디</label>
                            <div class="input-wrapper">
                                <input type="text" id="signupId" name="id" placeholder="아이디를 입력하세요" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="signupName">이름</label>
                            <div class="input-wrapper">
                                <input type="text" id="signupName" name="name" placeholder="이름을 입력하세요" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="signupPassword">비밀번호</label>
                            <div class="input-wrapper">
                                <input type="password" id="signupPassword" name="passwd" placeholder="비밀번호를 입력하세요" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="regionSelect">거주 지역</label>
                            <div class="input-wrapper">
                                <select id="regionSelect" name="live" required>
                                    <option value="">지역을 선택하세요</option>
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
                                <input type="hidden" id="liveCode" name="liveCode" value="">
                            </div>
                        </div>
                        <button type="submit" class="auth-btn signup-btn">회원가입
                        </button>
                    </form>
                    <div class="auth-footer">
                        <p>이미 계정이 있으신가요? <a href="#" onclick="showLogin()">로그인</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const regionCodes = {
            "서울특별시": "11",
            "부산광역시": "21",
            "대구광역시": "22",
            "인천광역시": "23",
            "광주광역시": "24",
            "대전광역시": "25",
            "울산광역시": "26",
            "세종특별자치시": "29",
            "경기도": "31",
            "강원도": "32",
            "충청북도": "33",
            "충청남도": "34",
            "전라북도": "35",
            "전라남도": "36",
            "경상북도": "37",
            "경상남도": "38",
            "제주특별자치도": "39"
        };

        function showSignup() {
            document.getElementById('loginCard').style.display = 'none';
            document.getElementById('signupCard').style.display = 'block';
            document.getElementById('signupId').focus();
        }

        function showLogin() {
            document.getElementById('signupCard').style.display = 'none';
            document.getElementById('loginCard').style.display = 'block';
            document.getElementById('loginId').focus();
        }

        // 지역 선택 시 코드 자동 설정
        document.getElementById('regionSelect').addEventListener('change', function() {
            const selectedRegion = this.value;
            document.getElementById('liveCode').value = regionCodes[selectedRegion] || '';
        });

        // 네비게이션 토글 함수
        function toggleMenu() {
            const menu = document.getElementById('navbarMenu');
            menu.classList.toggle('active');
        }
    </script>
</body>
</html>
