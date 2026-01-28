<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
String live = "all"; // 기본값 전체 지역
if (session != null && session.getAttribute("id") != null) {
    String id = (String) session.getAttribute("id");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/jspdb", "root", "1234");
        String sql = "SELECT live FROM user WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        rs = pstmt.executeQuery();
        if (rs.next()) {
        	live = rs.getString("live");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
}
Date date = new Date();
SimpleDateFormat simpleDate = new SimpleDateFormat("yyyyMMdd");
String strDate = simpleDate.format(date);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>청년 맞춤 정책</title>
<link rel="stylesheet" href="css/plcy.css" />
</head>
<body>
	<nav class="navbar">
        <a href="main.jsp" class="navbar-brand">Custom Policy
        </a>
        <button class="navbar-toggle" onclick="toggleMenu()">
            <i class="fas fa-bars"></i>
        </button>
        <ul class="navbar-menu" id="navbarMenu">
            <li><a href="main.jsp">HOME</a></li>
            <li><a href="plcy.jsp"  class="active">청년 맞춤 정책</a></li>
            <li><a href="simul.jsp">정책 시뮬레이터</a></li>
            <%
           		if((String)session.getAttribute("id")==null || !request.isRequestedSessionIdValid()){
            %>
            <li><a href="login.jsp">Login</a></li>
            <%
            	}else {
            %>
            <li><a href="myInfo.jsp">마이페이지</a></li>
            <li><a href="plcy_logout.jsp">Logout</a></li>
            <%	} %>
        </ul>
    </nav>
	<div class="policy-container">
		<h1>청년정책 정보</h1>
		<div class="main-content-wrapper">
			<!-- 사이드바 필터 영역 추가 -->
			<div class="sidebar-filter">
				<div class="filter-section">
					<h3>지역 선택</h3>
					<select id="region-select" class="region-dropdown">
						<option value="all" <%= "all".equals(live) ? "selected" : "" %>>전체 지역</option>
                		<option value="11000" <%= "Seoul".equals(live) ? "selected" : "" %>>서울특별시</option>
                		<option value="26000" <%= "Busan".equals(live) ? "selected" : "" %>>부산광역시</option>
                		<option value="27000" <%= "Daegu".equals(live) ? "selected" : "" %>>대구광역시</option>
		                <option value="28000" <%= "Incheon".equals(live) ? "selected" : "" %>>인천광역시</option>
                		<option value="29000" <%= "Gwangju".equals(live) ? "selected" : "" %>>광주광역시</option>
                		<option value="30000" <%= "Daejeon".equals(live) ? "selected" : "" %>>대전광역시</option>
                		<option value="31000" <%= "Ulsan".equals(live) ? "selected" : "" %>>울산광역시</option>
                		<option value="36000" <%= "Sejong".equals(live) ? "selected" : "" %>>세종특별자치시</option>
                		<option value="41000" <%= "Gyeonggi".equals(live) ? "selected" : "" %>>경기도</option>
                		<option value="51000" <%= "Gangwon".equals(live) ? "selected" : "" %>>강원도</option>
                		<option value="43000" <%= "Chungbuk".equals(live) ? "selected" : "" %>>충청북도</option>
                		<option value="44000" <%= "Chungnam".equals(live) ? "selected" : "" %>>충청남도</option>
                		<option value="52000" <%= "Jeonbuk".equals(live) ? "selected" : "" %>>전라북도</option>
                		<option value="46000" <%= "Jeonnam".equals(live) ? "selected" : "" %>>전라남도</option>
                		<option value="47000" <%= "Gyeongbuk".equals(live) ? "selected" : "" %>>경상북도</option>
                		<option value="48000" <%= "Gyeongnam".equals(live) ? "selected" : "" %>>경상남도</option>
                		<option value="50000,50110" <%= "jeju".equals(live) ? "selected" : "" %>>제주특별자치도</option>
					</select>
				</div>

				<div class="filter-section">
					<h3>정책 분야</h3>
					<div class="category-buttons">
						<button class="category-btn active" data-category="all">전체</button>
						<button class="category-btn" data-category="일자리">일자리</button>
						<button class="category-btn" data-category="주거">주거</button>
						<button class="category-btn" data-category="교육">교육</button>
						<button class="category-btn" data-category="복지문화">복지·문화</button>
						<button class="category-btn" data-category="참여권리">참여·권리</button>
					</div>
				</div>

				<div class="active-filters">
					<button id="reset-filters" class="reset-btn">초기화</button>
				</div>
			</div>

			<!-- 정책 리스트 영역 -->
			<div class="policy-list-container">
				<div id="policy-list">
					<div class="loading">데이터를 불러오는 중...</div>
				</div>
				<ul id="pagination" class="pagination"></ul>
			</div>
		</div>
	</div>


	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script>
	let regionCode = "";
	if(<%="all".equals(live)%>){
		regionCode = "all";
	}else if(<%="Seoul".equals(live)%>){
		regionCode = "11000";
	}else if(<%="Busan".equals(live)%>){
		regionCode = "26000";
	}else if(<%="Daegu".equals(live)%>){
		regionCode = "27000";
	}else if(<%="Incheon".equals(live)%>){
		regionCode = "28000";
	}else if(<%="Gwangju".equals(live)%>){
		regionCode = "29000";
	}else if(<%="Ulsan".equals(live)%>){
		regionCode = "30000";
	}else if(<%="Sejong".equals(live)%>){
		regionCode = "31000";
	}else if(<%="Gyeonggi".equals(live)%>){
		regionCode = "41000";
	}else if(<%="Gangwon".equals(live)%>){
		regionCode = "51000";
	}else if(<%="Chungbuk".equals(live)%>){
		regionCode = "43000";
	}else if(<%="Chungnam".equals(live)%>){
		regionCode = "44000";
	}else if(<%="Jeonbuk".equals(live)%>){
		regionCode = "52000";
	}else if(<%="Jeonnam".equals(live)%>){
		regionCode = "46000";
	}else if(<%="Gyeongbuk".equals(live)%>){
		regionCode = "47000";
	}else if(<%="Gyeongnam".equals(live)%>){
		regionCode = "48000";
	}else if(<%="jeju".equals(live)%>){
		regionCode = "50000";
	}
	let currentFilters = {
		    regionCode: this.regionCode,
		    category: 'all'
		};
	
    $(document).ready(function() {
        const apiKey = '05c2658a-395e-49fb-ae00-750bad07e2e5';
        const apiUrl = 'https://www.youthcenter.go.kr/go/ythip/getPlcy';
        let currentPage = 1;
        let totalPages = 1;

        function renderPagination() {
            const $pagination = $('#pagination').empty();
            const maxVisiblePages = 5;
            
            // Previous 버튼
            $pagination.append(`
                <li class="page-item \${currentPage === 1 ? 'disabled' : ''}">
                    <a class="page-link" href="#" data-page="\${currentPage - 1}">«</a>
                </li>
            `);

            // 페이지 범위 계산
            let startPage = Math.max(currentPage - Math.floor(maxVisiblePages/2), 1);
            let endPage = startPage + maxVisiblePages - 1;
            
            if(endPage > totalPages) {
                endPage = totalPages;
                startPage = Math.max(endPage - maxVisiblePages + 1, 1);
            }

            // 처음 페이지 버튼
            if(startPage > 1) {
                $pagination.append(`
                    <li class="page-item">
                        <a class="page-link" href="#" data-page="1">1</a>
                    </li>
                    \${startPage > 2 ? '<li class="page-item disabled"><span class="page-link">...</span></li>' : ''}
                `);
            }

            // 페이지 번호 생성
            for(let i = startPage; i <= endPage; i++) {
                $pagination.append(`
                    <li class="page-item \${i === currentPage ? 'active' : ''}">
                        <a class="page-link" href="#" data-page="\${i}">\${i}</a>
                    </li>
                `);
            }

            // 마지막 페이지 버튼
            if(endPage < totalPages) {
                $pagination.append(`
                    \${endPage < totalPages - 1 ? '<li class="page-item disabled"><span class="page-link">...</span></li>' : ''}
                    <li class="page-item">
                        <a class="page-link" href="#" data-page="\${totalPages}">\${totalPages}</a>
                    </li>
                `);
            }

            // Next 버튼
            $pagination.append(`
                <li class="page-item \${currentPage === totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="#" data-page="\${currentPage + 1}">»</a>
                </li>
            `);
        }
        function updateFilters() {
            console.log(currentFilters);
            // 데이터 재로드
            loadPolicyData(1, currentFilters.regionCode, currentFilters.category);
        }
		
        $('#region-select').change(function() {
            currentPage = 1;
            loadPolicyData(currentPage, $(this).val());
            currentFilters.regionCode = $(this).val();
            console.log($(this).val());
        });
        // 데이터 로드 함수
        function loadPolicyData(page, regionCode = 'all', category = 'all') {
    		$('#policy-list').html('<div class="loading">데이터를 불러오는 중...</div>');
    
   			 const requestData = {
        		apiKeyNm: apiKey,
        		pageNum: page,
        		pageSize: 27,
        		lclsfNm: category === 'all' ? '' : category
    		};

   			 if(regionCode !== 'all') {
        		requestData.zipCd = regionCode; 
   			 }
            $.ajax({
            	url: apiUrl,
                type: 'GET',
                dataType: 'json',
                data: requestData,
                success: function(response) {
                    if(response.result && response.result.youthPolicyList) {
                        const policies = response.result.youthPolicyList;
                        console.log(policies);
                        const totalCount = response.result.pagging.totCount;
                        totalPages = Math.ceil(totalCount / 27);
                        console.log(totalCount);
                        
                        // 데이터 렌더링
                        const $container = $('#policy-list').empty();
                        policies.forEach(policy => {
                        	if(policy.aplyYmd == ""){
                        		policy.aplyYmd = "상시";
                        	}else if(parseInt(policy.aplyYmd.substr(11,8)) < parseInt(<%=strDate%>)){
                        		policy.aplyYmd = "마감";
                        	}else if(parseInt(policy.aplyYmd.substr(0,8)) > parseInt(<%=strDate%>)){
                        		policy.aplyYmd = "오픈 예정 /" + policy.aplyYmd.substr(0,8) + " ~";
                        	}
                        	if(policy.zipCd.length > 1510){
                        		policy.rgtrHghrkInstCdNm = "전국"
                        	}
                            $container.append('<div class="policy-item" data-url='+policy.plcyNo+'><span class="policy-rg">'+ policy.rgtrHghrkInstCdNm + 
                            		'</span><div class="policy-title"><strong>'+ policy.plcyNm + 
                            		'</strong></div><div class="policy-info">' + policy.plcyExplnCn + 
                            		'</div><div class="policy-info"><strong>신청기간: '+ policy.aplyYmd +
                            		'</strong></div></div>');
                        });
                        
                        // 페이지네이션 업데이트
                        renderPagination();
                        
                    }
                },
                error: function(xhr) {
                    $('#policy-list').html(`
                        <div class="error">
                            <h3>데이터 로딩 실패</h3>
                            <p>상태 코드: ${xhr.status}</p>
                            <p>${xhr.responseJSON ? xhr.responseJSON.message : '서버 연결 실패'}</p>
                        </div>
                    `);
                }
            });
            
        }

        // 이벤트 처리
        $(document).on('click', '.page-link', function(e) {
            e.preventDefault();
            const newPage = parseInt($(this).data('page'));
            const selectedRegion = $('#region-select').val();
            if(!isNaN(newPage) && newPage !== currentPage) {
                currentPage = newPage;
                loadPolicyData(currentPage, selectedRegion);
                window.scrollTo(0, 0);
            }
        });
        //상세페이지로 이동
        $(document).on('click', '.policy-item', function(e) {
        	const targetUrl = $(this).data('url');
        	console.log(targetUrl);
        	const url = "https://www.youthcenter.go.kr/youthPolicy/ythPlcyTotalSearch/ythPlcyDetail/" + targetUrl;
        	if(targetUrl && targetUrl !== '#') {
                window.open(url, '_blank');
            }
        });
     	// 필터 초기화 기능
        $('#reset-filters').click(function() {
            $('#region-select').val('all');
            $('.category-btn').removeClass('active');
            $('[data-category="all"]').addClass('active');
            currentFilters = { regionCode: 'all', category: 'all' };
            updateFilters();
        });
     	// 카테고리 버튼 이벤트 핸들러
        $('.category-buttons').on('click', '.category-btn', function() {
            $('.category-btn').removeClass('active');
            $(this).addClass('active');
            currentFilters.category = $(this).data('category');
            updateFilters();
        });
        

        // 초기 로드
        loadPolicyData(1,regionCode);
        

    });
    
    </script>
</body>
</html>
