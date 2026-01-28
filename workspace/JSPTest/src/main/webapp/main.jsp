<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>인구 밀도 지도</title>
     <link rel="stylesheet" href="css/main.css" />
</head>
<body>
	<nav class="navbar">
        <a href="main.jsp" class="navbar-brand">Density Map
        </a>
        <button class="navbar-toggle" onclick="toggleMenu()">
            <i class="fas fa-bars"></i>
        </button>
        <ul class="navbar-menu" id="navbarMenu">
            <li><a href="#" class="active">HOME</a></li>
            <li><a href="plcy.jsp">청년 맞춤 정책</a></li>
            <li><a href="simul.jsp">정책 시뮬레이터</a></li>
            <%
            	if((String)session.getAttribute("id")==null || !request.isRequestedSessionIdValid()){
            %>
            <li><a href="login.jsp">Login</a></li>
            <%
            	}else{
            %>
            <li><a href="myInfo.jsp">마이페이지</a></li>
            <li><a href="main_logout.jsp">Logout</a></li>
            <%	} %>
        </ul>
    </nav>
    <div id="map"></div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=4b52fb43de1e7bbf6f3f906f61ae9523"></script>
	<script type="text/javascript">
	// 지도 초기화 및 설정
	var mapContainer = document.getElementById('map');
	var mapOption = {
	    center: new kakao.maps.LatLng(36.5, 127.9),
	    level: 12
	};

	var map = new kakao.maps.Map(mapContainer, mapOption);

	// 폴리곤 생성에 필요한 객체
	var areas = [];
	var customOverlay = new kakao.maps.CustomOverlay({});
	var currentLevel = map.getLevel();
	var currentFile = '';
	var legendElement = null;
	
	var infoOverlay = new kakao.maps.CustomOverlay({
	    content: '<div class="area-tooltip"></div>',
	    position: new kakao.maps.LatLng(0, 0),
	    xAnchor: 0.5,
	    yAnchor: 1.5,
	    zIndex: 999
	});

	// 인구 밀도에 따른 색상 결정 함수
	function getColorByDensity(density) {
	    // 인구 밀도 구간별 다른 색상 반환
	    if (density > 10000) return '#021024';       
	    else if (density > 1000) return '#052659';   
	    else if (density > 500) return '#5483B3';    
	    else if (density > 100) return '#7DA0C4';    
	    else return '#C1E8FF';                       
	}

	// 지도 레벨 변경 이벤트 리스너 등록
	kakao.maps.event.addListener(map, 'zoom_changed', function() {
	    var level = map.getLevel();
	    
	    // 레벨이 변경되고 특정 임계점을 넘었을 때만 데이터 갱신
	    if ((currentLevel > 10 && level <= 10) || (currentLevel <= 10 && level > 10)) {
	        currentLevel = level;
	        loadGeoJSONByLevel(level);
	    } else {
	        currentLevel = level;
	    }
	});

	// 최초 로딩시 현재 레벨에 따라 데이터 로드
	loadGeoJSONByLevel(currentLevel);

	// 지도 레벨에 따라 적절한 GeoJSON 파일 로드
	function loadGeoJSONByLevel(level) {
	    // 지도 레벨에 따라 파일 결정
	    var fileName = level > 10 ? "json/sido1.json" : "json/sig1.json";
	    
	    // 이미 같은 파일이 로드되어 있다면 중복 로드하지 않음
	    if (fileName === currentFile) {
	        return;
	    }
	    
	    currentFile = fileName;
	    
	    // 기존 폴리곤 제거
	    removeAllPolygons();
	    
	    // 새 데이터 로드
	    $.getJSON(fileName, function(geojson) {
	        processGeoJSON(geojson);
	    });
	}

	// 기존 폴리곤 전체 제거
	function removeAllPolygons() {
	    for (var i = 0; i < areas.length; i++) {
	        areas[i].polygon.setMap(null);
	    }
	    areas = [];
	}

	// GeoJSON 데이터 처리 및 폴리곤 생성
	function processGeoJSON(geojson) {
	    var data = geojson.features;
	    
	    // 각 지역에 대해 폴리곤 생성
	    for (var i = 0; i < data.length; i++) {
	        var feature = data[i];
	        var geometry = feature.geometry;
	        var properties = feature.properties;
	        
	        // 인구 밀도 추출
	        var density = parseFloat(properties.ppltn_dnsty);
	        var name = properties.SIG_KOR_NM || properties.CTP_KOR_NM; // 시군구명 또는 시도명
	        
	        // 폴리곤 좌표 처리
	        var polygonPaths = [];
	        
	        if (geometry.type === "Polygon") {
	            // 단일 폴리곤인 경우
	            var coordinates = geometry.coordinates[0];
	            var path = [];
	            
	            for (var j = 0; j < coordinates.length; j++) {
	                path.push(new kakao.maps.LatLng(coordinates[j][1], coordinates[j][0]));
	            }
	            
	            polygonPaths.push(path);
	        } else if (geometry.type === "MultiPolygon") {
	            // 여러 폴리곤으로 구성된 경우
	            var coordinates = geometry.coordinates;
	            
	            for (var j = 0; j < coordinates.length; j++) {
	                var path = [];
	                
	                for (var k = 0; k < coordinates[j][0].length; k++) {
	                    path.push(new kakao.maps.LatLng(coordinates[j][0][k][1], coordinates[j][0][k][0]));
	                }
	                
	                polygonPaths.push(path);
	            }
	        }
	        
	        // 인구 밀도에 따른 색상 결정
	        var fillColor = getColorByDensity(density);
	        
	        // 폴리곤 생성 및 스타일 지정
	        for (var j = 0; j < polygonPaths.length; j++) {
	            var polygon = new kakao.maps.Polygon({
	                map: map,
	                path: polygonPaths[j],
	                strokeWeight: 2,
	                strokeColor: '#004c80',
	                strokeOpacity: 0.8,
	                fillColor: fillColor,
	                fillOpacity: 0.7,
	                zIndex:1
	            });
	            
	            // 지역 정보 저장
	            var area = {
	                name: name,
	                density: density,
	                polygon: polygon
	            };
	            
	            areas.push(area);
	            
	         	// 폴리곤 클릭 이벤트 핸들러
	            kakao.maps.event.addListener(polygon, 'click', (function(area) {
	                return function(mouseEvent) {
	                    // 클릭 좌표를 기준으로 지도 레벨 변경
	                    map.setLevel(9, {
	                        anchor: mouseEvent.latLng,  // 클릭 지점을 지도 중심으로 고정
	                        animate: {
	                            duration: 400  // 0.4초 동안 애니메이션 효과
	                        }
	                    });
	                };
	            })(area));
	         	
	            kakao.maps.event.addListener(polygon, 'mouseover', (function(area) {
	                return function(mouseEvent) {
	                    // 툴팁 콘텐츠 설정
	                    infoOverlay.setContent('<div class="area-tooltip">' + area.name + '<br>' + '인구밀도: ' + area.density + '</div>');
	                    infoOverlay.setPosition(mouseEvent.latLng);
	                    infoOverlay.setMap(map);
	                };
	            })(area));

	            kakao.maps.event.addListener(polygon, 'mousemove', (function(area) {
	                return function(mouseEvent) {
	                    infoOverlay.setPosition(mouseEvent.latLng);
	                };
	            })(area));

	            kakao.maps.event.addListener(polygon, 'mouseout', (function(area) {
	                return function() {
	                    infoOverlay.setMap(null);
	                    polygon.setOptions({
	                        fillOpacity: 0.7,
	                        strokeWeight: 2
	                    });
	                };
	            })(area));

	         	
	        }
	        
	    }
	    // 지도 범례 갱신
	    updateLegend();
	}

	// 범례 추가 함수
	function updateLegend() {
	    // 기존 범례가 있으면 제거
	    if (legendElement) {
	        legendElement.parentNode.removeChild(legendElement);
	    }
	    
	    var legend = document.createElement('div');
	    legendElement = legend;
	    legend.className = 'legend';
	    legend.style.position = 'absolute';
	    legend.style.bottom = '30px';
	    legend.style.left = '10px';
	    legend.style.backgroundColor = 'white';
	    legend.style.padding = '10px';
	    legend.style.borderRadius = '5px';
	    legend.style.boxShadow = '0 1px 3px rgba(0,0,0,0.3)';
	    
	    var title = document.createElement('div');
	    title.innerHTML = '<strong>인구 밀도 (명/km²)</strong>';
	    title.style.marginBottom = '8px';
	    legend.appendChild(title);
	    
	    // 현재 지도 레벨에 따른 행정구역 표시
	    var levelInfo = document.createElement('div');
	    levelInfo.innerHTML = '<small>' + (currentLevel > 10 ? '시/도 단위' : '시/군/구 단위') + '</small>';
	    levelInfo.style.marginBottom = '8px';
	    legend.appendChild(levelInfo);
	    
	    // 범례 항목
	    var items = [
	        {color: '#021024', label: '10,000 이상'},
	        {color: '#052659', label: '1,000-10,000'},
	        {color: '#5483B3', label: '500-1,000'},
	        {color: '#7DA0C4', label: '100-500'},
	        {color: '#C1E8FF', label: '100 미만'}
	    ];
	    
	    for (var i = 0; i < items.length; i++) {
	        var item = document.createElement('div');
	        item.style.marginBottom = '5px';
	        item.style.display = 'flex';
	        item.style.alignItems = 'center';
	        
	        var colorBox = document.createElement('div');
	        colorBox.style.width = '20px';
	        colorBox.style.height = '20px';
	        colorBox.style.backgroundColor = items[i].color;
	        colorBox.style.marginRight = '5px';
	        
	        var label = document.createElement('span');
	        label.textContent = items[i].label;
	        
	        item.appendChild(colorBox);
	        item.appendChild(label);
	        legend.appendChild(item);
	    }
	    
	    document.body.appendChild(legend);
	}
	
	
	
	</script>
</body>
</html>
