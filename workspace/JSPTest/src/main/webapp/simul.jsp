<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>청년 정책 효과 시뮬레이터</title>
    <link rel="stylesheet" href="css/plcy.css" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/simul.css"/>
</head>
<body>
    <nav class="navbar">
        <a href="main.jsp" class="navbar-brand">Policy Simulater</a>
        <button class="navbar-toggle" onclick="toggleMenu()">
            <i class="fas fa-bars"></i>
        </button>
        <ul class="navbar-menu" id="navbarMenu">
            <li><a href="main.jsp">HOME</a></li>
            <li><a href="plcy.jsp">청년 맞춤 정책</a></li>
            <li><a href="#" class="active">정책 시뮬레이터</a></li>
            <%
                if((String)session.getAttribute("id")==null || !request.isRequestedSessionIdValid()){
            %>
            <li><a href="login.jsp">Login</a></li>
            <%
                }else {
            %>
            <li><a href="myInfo.jsp">마이페이지</a></li>
            <li><a href="simul_logout.jsp">Logout</a></li>
            <%  } %>
        </ul>
    </nav>

    <div class="simulator-container">
        <!-- 헤더 -->
        <div class="simulator-header">
            <h1>청년 정책 효과 시뮬레이터</h1>
            <p>청년 정책들이 지역에 미치는 영향을 시각화하는 웹 인터페이스입니다</p>
        </div>

        <!-- 컨트롤 패널 -->
        <div class="controls-panel">
            <div class="controls-grid">
                <div class="control-group">
                    <label for="policy-type" class="control-label">정책 유형</label>
                    <select id="policy-type" class="control-select">
                        <option value="housing">주거 지원</option>
                        <option value="employment">취업 지원</option>
                        <option value="education">교육 지원</option>
                        <option value="childcare">보육 지원</option>
                        <option value="business">창업 지원</option>
                    </select>
                    <div id="policy-description" class="policy-description"></div>
                </div>

                <div class="control-group">
                    <label for="region" class="control-label">지역 선택</label>
                    <select id="region" class="control-select">
                        <option value="seoul" <%= "Seoul".equals(live) ? "selected" : "" %>>서울특별시</option>
                        <option value="busan" <%= "Busan".equals(live) ? "selected" : "" %>>부산광역시</option>
                        <option value="daegu" <%= "Daegu".equals(live) ? "selected" : "" %>>대구광역시</option>
                        <option value="incheon" <%= "Incheon".equals(live) ? "selected" : "" %>>인천광역시</option>
                        <option value="gwangju" <%= "Gwangju".equals(live) ? "selected" : "" %>>광주광역시</option>
                        <option value="daejeon" <%= "Daejeon".equals(live) ? "selected" : "" %>>대전광역시</option>
                        <option value="ulsan" <%= "Ulsan".equals(live) ? "selected" : "" %>>울산광역시</option>
                        <option value="sejong" <%= "Sejong".equals(live) ? "selected" : "" %>>세종특별자치시</option>
                        <option value="gyeonggi" <%= "Gyeonggi".equals(live) ? "selected" : "" %>>경기도</option>
                        <option value="gangwon" <%= "Gangwon".equals(live) ? "selected" : "" %>>강원특별자치도</option>
                        <option value="chungbuk" <%= "Chungbuk".equals(live) ? "selected" : "" %>>충청북도</option>
                        <option value="chungnam" <%= "Chungnam".equals(live) ? "selected" : "" %>>충청남도</option>
                        <option value="jeonbuk" <%= "Jeonbuk".equals(live) ? "selected" : "" %>>전라북도</option>
                        <option value="jeonnam" <%= "Jeonnam".equals(live) ? "selected" : "" %>>전라남도</option>
                        <option value="gyeongbuk" <%= "Gyeongbuk".equals(live) ? "selected" : "" %>>경상북도</option>
                        <option value="gyeongnam" <%= "Gyeongnam".equals(live) ? "selected" : "" %>>경상남도</option>
                        <option value="jeju" <%= "jeju".equals(live) ? "selected" : "" %>>제주특별자치도</option>
                    </select>
                </div>

                <div class="control-group">
                    <label for="budget-scale" class="control-label">예산 규모</label>
                    <select id="budget-scale" class="control-select">
                        <option value="small">소규모 (50억원 미만)</option>
                        <option value="medium" selected>중규모 (50억원~200억원)</option>
                        <option value="large">대규모 (200억원 이상)</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- 탭 컨테이너 -->
        <div class="tab-container">
            <div class="tabs">
                <button class="tab active" data-tab="population">인구 변화</button>
                <button class="tab" data-tab="economic">경제 효과</button>
                <button class="tab" data-tab="social">사회적 효과</button>
            </div>

            <div class="tab-content">
                <!-- 인구 변화 탭 -->
                <div id="population-tab" class="tab-pane active">
                    <div class="results-grid">
                        <div class="chart-container">
                            <h3>5년간 인구 변화 추이</h3>
                            <canvas id="population-chart"></canvas>
                        </div>
                        <div class="result-cards">
                            <div class="result-card">
                                <h4>인구 변화 분석</h4>
                                <div class="metric">
                                    <span class="metric__label">현재 인구</span>
                                    <span class="metric__value" id="current-population">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">5년 후 예상 인구</span>
                                    <span class="metric__value highlight" id="future-population">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">정책 효과</span>
                                    <span class="metric__value positive" id="policy-effect-population">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">총 변화율</span>
                                    <span class="metric__value" id="total-change-rate">-</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 경제 효과 탭 -->
                <div id="economic-tab" class="tab-pane">
                    <div class="results-grid">
                        <div class="chart-container">
                            <h3>5년간 지역내 총생산(GRDP) 증가율</h3>
                            <canvas id="economic-chart"></canvas>
                        </div>
                        <div class="result-cards">
                            <div class="result-card">
                                <h4>경제 효과 분석</h4>
                                <div class="metric">
                                    <span class="metric__label">현재 GRDP</span>
                                    <span class="metric__value" id="current-grdp">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">5년 후 예상 GRDP</span>
                                    <span class="metric__value highlight" id="future-grdp">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">정책 효과</span>
                                    <span class="metric__value positive" id="policy-effect-economic">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">투자 대비 수익률</span>
                                    <span class="metric__value neutral" id="roi">-</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 사회적 효과 탭 -->
                <div id="social-tab" class="tab-pane">
                    <div class="results-grid">
                        <div class="chart-container">
                            <h3>5개 지표별 사회적 효과</h3>
                            <canvas id="social-chart"></canvas>
                        </div>
                        <div class="result-cards">
                            <div class="result-card">
                                <h4>사회적 효과 분석</h4>
                                <div class="metric">
                                    <span class="metric__label">생활 만족도 증가</span>
                                    <span class="metric__value positive" id="satisfaction-increase">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">가장 개선된 영역</span>
                                    <span class="metric__value highlight" id="improvement-area">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">지역 적합도</span>
                                    <span class="metric__value" id="regional-fit">-</span>
                                </div>
                                <div class="metric">
                                    <span class="metric__label">종합 효과성</span>
                                    <span class="metric__value" id="overall-effectiveness">-</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        // 네비게이션 토글 함수
        function toggleMenu() {
            const navbarMenu = document.getElementById('navbarMenu');
            navbarMenu.classList.toggle('responsive');
        }
        
        // 데이터 정의
        const policyData = {
            housing: {
                name: "주거 지원 정책",
                description: "청년층을 위한 주택 공급, 월세 지원, 대출 이자 지원 등의 주거 안정화 정책",
                effects: {
                    population: {
                        small: [0.5, 0.7, 0.8, 0.9, 1.0],
                        medium: [0.8, 1.1, 1.3, 1.5, 1.7],
                        large: [1.2, 1.6, 1.9, 2.2, 2.5]
                    },
                    economic: {
                        small: [0.3, 0.4, 0.5, 0.6, 0.7],
                        medium: [0.5, 0.7, 0.9, 1.1, 1.3],
                        large: [0.8, 1.1, 1.4, 1.7, 2.0]
                    },
                    social: {
                        small: [0.2, 0.3, 0.4, 0.5, 0.6],
                        medium: [0.4, 0.6, 0.8, 1.0, 1.2],
                        large: [0.7, 1.0, 1.3, 1.6, 1.9]
                    }
                }
            },
            employment: {
                name: "취업 지원 정책",
                description: "청년 일자리 창출, 취업 연계 프로그램, 인턴십 지원, 임금 지원 등의 고용 촉진 정책",
                effects: {
                    population: {
                        small: [0.6, 0.8, 1.0, 1.2, 1.4],
                        medium: [1.0, 1.3, 1.6, 1.9, 2.2],
                        large: [1.5, 2.0, 2.5, 3.0, 3.5]
                    },
                    economic: {
                        small: [0.7, 0.9, 1.1, 1.3, 1.5],
                        medium: [1.2, 1.5, 1.8, 2.1, 2.4],
                        large: [1.8, 2.3, 2.8, 3.3, 3.8]
                    },
                    social: {
                        small: [0.3, 0.4, 0.5, 0.6, 0.7],
                        medium: [0.5, 0.7, 0.9, 1.1, 1.3],
                        large: [0.8, 1.1, 1.4, 1.7, 2.0]
                    }
                }
            },
            education: {
                name: "교육 지원 정책",
                description: "장학금 지원, 교육비 지원, 전문교육 프로그램, 평생교육 지원 등의 교육 접근성 향상 정책",
                effects: {
                    population: {
                        small: [0.3, 0.5, 0.7, 0.9, 1.1],
                        medium: [0.6, 0.9, 1.2, 1.5, 1.8],
                        large: [1.0, 1.4, 1.8, 2.2, 2.6]
                    },
                    economic: {
                        small: [0.4, 0.6, 0.8, 1.0, 1.2],
                        medium: [0.8, 1.1, 1.4, 1.7, 2.0],
                        large: [1.3, 1.7, 2.1, 2.5, 2.9]
                    },
                    social: {
                        small: [0.5, 0.7, 0.9, 1.1, 1.3],
                        medium: [1.0, 1.3, 1.6, 1.9, 2.2],
                        large: [1.5, 2.0, 2.5, 3.0, 3.5]
                    }
                }
            },
            childcare: {
                name: "보육 지원 정책",
                description: "출산 장려금, 보육시설 확충, 육아휴직 지원, 아동수당 확대 등의 양육 부담 경감 정책",
                effects: {
                    population: {
                        small: [0.7, 1.0, 1.3, 1.6, 1.9],
                        medium: [1.2, 1.6, 2.0, 2.4, 2.8],
                        large: [1.8, 2.4, 3.0, 3.6, 4.2]
                    },
                    economic: {
                        small: [0.2, 0.3, 0.5, 0.7, 0.9],
                        medium: [0.4, 0.6, 0.9, 1.2, 1.5],
                        large: [0.7, 1.0, 1.4, 1.8, 2.2]
                    },
                    social: {
                        small: [0.8, 1.1, 1.4, 1.7, 2.0],
                        medium: [1.5, 1.9, 2.3, 2.7, 3.1],
                        large: [2.2, 2.8, 3.4, 4.0, 4.6]
                    }
                }
            },
            business: {
                name: "창업 지원 정책",
                description: "청년 창업자금 지원, 창업 공간 제공, 멘토링 프로그램, 세제 혜택 등의 스타트업 활성화 정책",
                effects: {
                    population: {
                        small: [0.4, 0.6, 0.8, 1.0, 1.2],
                        medium: [0.7, 1.0, 1.3, 1.6, 1.9],
                        large: [1.1, 1.5, 1.9, 2.3, 2.7]
                    },
                    economic: {
                        small: [0.8, 1.2, 1.6, 2.0, 2.4],
                        medium: [1.4, 1.9, 2.4, 2.9, 3.4],
                        large: [2.1, 2.8, 3.5, 4.2, 4.9]
                    },
                    social: {
                        small: [0.3, 0.5, 0.7, 0.9, 1.1],
                        medium: [0.6, 0.9, 1.2, 1.5, 1.8],
                        large: [1.0, 1.4, 1.8, 2.2, 2.6]
                    }
                }
            }
        };

        const regionData = {
            seoul: {name: "서울특별시", population: 9518826, multiplier: 1.0},
            busan: {name: "부산광역시", population: 3373871, multiplier: 1.1},
            daegu: {name: "대구광역시", population: 2418346, multiplier: 1.2},
            incheon: {name: "인천광역시", population: 2923278, multiplier: 1.0},
            gwangju: {name: "광주광역시", population: 1456468, multiplier: 1.3},
            daejeon: {name: "대전광역시", population: 1469543, multiplier: 1.2},
            ulsan: {name: "울산광역시", population: 1136017, multiplier: 1.1},
            sejong: {name: "세종특별자치시", population: 365309, multiplier: 1.4},
            gyeonggi: {name: "경기도", population: 13239666, multiplier: 1.1},
            gangwon: {name: "강원특별자치도", population: 1541502, multiplier: 1.5},
            chungbuk: {name: "충청북도", population: 1598200, multiplier: 1.4},
            chungnam: {name: "충청남도", population: 2121029, multiplier: 1.3},
            jeonbuk: {name: "전라북도", population: 1804104, multiplier: 1.5},
            jeonnam: {name: "전라남도", population: 1851549, multiplier: 1.6},
            gyeongbuk: {name: "경상북도", population: 2639422, multiplier: 1.4},
            gyeongnam: {name: "경상남도", population: 3340216, multiplier: 1.3},
            jeju: {name: "제주특별자치도", population: 674635, multiplier: 1.2}
        };

        // 전역 변수
        let currentPolicy = 'housing';
        let currentRegion = 'seoul';
        let currentBudget = 'medium';
        let charts = {};

        // 초기화
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM loaded, initializing app...');
            
            if (typeof Chart === 'undefined') {
                console.error('Chart.js가 로드되지 않았습니다');
                return;
            }
            
            setupEventListeners();
            
            setTimeout(() => {
                updateAll();
            }, 100);
        });

        function setupEventListeners() {
            console.log('이벤트 리스너 설정 중...');
            
            const policySelect = document.getElementById('policy-type');
            const regionSelect = document.getElementById('region');
            const budgetSelect = document.getElementById('budget-scale');
            const tabButtons = document.querySelectorAll('.tab');

            if (!policySelect || !regionSelect || !budgetSelect) {
                console.error('필수 DOM 요소를 찾을 수 없습니다');
                return;
            }

            // 탭 버튼 이벤트
            tabButtons.forEach(button => {
                button.addEventListener('click', (e) => {
                    const tabName = e.target.getAttribute('data-tab');
                    console.log('탭 클릭:', tabName);
                    switchTab(tabName);
                });
            });

            // 드롭다운 이벤트
            policySelect.addEventListener('change', (e) => {
                currentPolicy = e.target.value;
                console.log('정책 변경:', currentPolicy);
                updatePolicyDescription();
                updateAll();
            });

            regionSelect.addEventListener('change', (e) => {
                currentRegion = e.target.value;
                console.log('지역 변경:', currentRegion);
                updateAll();
            });

            budgetSelect.addEventListener('change', (e) => {
                currentBudget = e.target.value;
                console.log('예산 변경:', currentBudget);
                updateAll();
            });

            // 초기 정책 설명 업데이트
            updatePolicyDescription();
        }

        function switchTab(tabName) {
        	const tabButtons = document.querySelectorAll('.tab');
        	const tabPanes = document.querySelectorAll('.tab-pane');
        	  
        	tabButtons.forEach(btn => btn.classList.remove('active'));
        	document.querySelector('[data-tab=' + tabName + ']').classList.add('active');

        	tabPanes.forEach(pane => pane.classList.remove('active'));
        	document.getElementById(tabName + '-tab').classList.add('active');
        }

        function updatePolicyDescription() {
            const policy = policyData[currentPolicy];
            const descElement = document.getElementById('policy-description');
            if (policy && descElement) {
                descElement.textContent = policy.description;
            }
        }

        function updateAll() {
            console.log('모든 데이터 업데이트 중:', {currentPolicy, currentRegion, currentBudget});
            try {
                updatePopulationTab();
                updateEconomicTab();
                updateSocialTab();
            } catch (error) {
                console.error('데이터 업데이트 오류:', error);
            }
        }

        function getEffectData(effectType) {
            const policy = policyData[currentPolicy];
            const region = regionData[currentRegion];
            
            if (!policy || !region) {
                console.error('잘못된 정책 또는 지역:', currentPolicy, currentRegion);
                return [0, 0, 0, 0, 0];
            }
            
            const baseEffects = policy.effects[effectType][currentBudget];
            return baseEffects.map(effect => effect * region.multiplier);
        }

        function updatePopulationTab() {
            console.log('인구 변화 탭 업데이트 중...');
            
            const effectData = getEffectData('population');
            const region = regionData[currentRegion];
            const currentPop = region.population;
            
            // 기존 추세 (연간 -0.1% 감소 가정)
            const baselineData = [-0.1, -0.2, -0.3, -0.4, -0.5];
            
            // 정책 적용 후 데이터
            const policyDataChart = effectData.map((effect, index) => baselineData[index] + effect);
            
            // 차트 업데이트
            updatePopulationChart(baselineData, policyDataChart);
            
            // 결과 카드 업데이트
            const futurePopBaseline = currentPop * (1 + baselineData[4] / 100);
            const futurePopPolicy = currentPop * (1 + policyDataChart[4] / 100);
            const policyEffect = futurePopPolicy - futurePopBaseline;
            const totalChangeRate = policyDataChart[4];
            
            updateElement('current-population', formatNumber(currentPop) + '명');
            updateElement('future-population', formatNumber(Math.round(futurePopPolicy)) + '명');
            updateElement('policy-effect-population', '+' + formatNumber(Math.round(policyEffect)) + '명');
            updateElement('total-change-rate', totalChangeRate.toFixed(1) + '%');
        }

        function updateEconomicTab() {
            console.log('경제 효과 탭 업데이트 중...');
            
            const effectData = getEffectData('economic');
            
            // 차트 업데이트
            updateEconomicChart(effectData);
            
            // 결과 카드 업데이트
            const region = regionData[currentRegion];
            const baseGRDP = Math.round(region.population * 0.035); // 1인당 GRDP 3.5천만원 가정
            const futureGRDP = baseGRDP * (1 + effectData[4] / 100);
            const policyEffect = baseGRDP * (effectData[4] / 100);
            const roi = (effectData[4] * 2).toFixed(1);
            
            updateElement('current-grdp', formatNumber(baseGRDP) + '억원');
            updateElement('future-grdp', formatNumber(Math.round(futureGRDP)) + '억원');
            updateElement('policy-effect-economic', '+' + formatNumber(Math.round(policyEffect)) + '억원');
            updateElement('roi', roi + '%');
        }

        function updateSocialTab() {
            console.log('사회적 효과 탭 업데이트 중...');
            
            const effectData = getEffectData('social');
            
            // 5개 지표로 변환
            const socialIndicators = [
                Math.min(100, 50 + effectData[4] * 8),   // 주거환경
                Math.min(100, 55 + effectData[4] * 6),   // 교육환경  
                Math.min(100, 48 + effectData[4] * 10),  // 복지수준
                Math.min(100, 52 + effectData[4] * 7),   // 고용안정성
                Math.min(100, 51 + effectData[4] * 9)    // 생활만족도
            ];
            
            // 차트 업데이트
            updateSocialChart(socialIndicators);
            
            // 결과 카드 업데이트
            const maxImprovement = Math.max(...socialIndicators);
            const maxIndex = socialIndicators.indexOf(maxImprovement);
            const indicatorNames = ['주거환경', '교육환경', '복지수준', '고용안정성', '생활만족도'];
            const satisfactionIncrease = effectData[4] * 5;
            const regionalFit = getRegionalFit();
            const overallEffectiveness = getOverallEffectiveness();
            
            updateElement('satisfaction-increase', '+' + satisfactionIncrease.toFixed(1) + '점');
            updateElement('improvement-area', indicatorNames[maxIndex]);
            updateElement('regional-fit', regionalFit);
            updateElement('overall-effectiveness', overallEffectiveness);
        }

        function getRegionalFit() {
            const region = regionData[currentRegion];
            const multiplier = region.multiplier;
            
            if (multiplier >= 1.4) return '매우 높음';
            if (multiplier >= 1.2) return '높음';
            if (multiplier >= 1.1) return '보통';
            return '낮음';
        }

        function getOverallEffectiveness() {
            const populationEffect = getEffectData('population')[4];
            const economicEffect = getEffectData('economic')[4];
            const socialEffect = getEffectData('social')[4];
            
            const avgEffect = (populationEffect + economicEffect + socialEffect) / 3;
            
            if (avgEffect >= 2.0) return '매우 효과적';
            if (avgEffect >= 1.5) return '효과적';
            if (avgEffect >= 1.0) return '보통';
            if (avgEffect >= 0.5) return '제한적';
            return '미미함';
        }

        function updateElement(id, value) {
            const element = document.getElementById(id);
            if (element) {
                element.textContent = value;
            } else {
                console.warn('요소를 찾을 수 없음:', id);
            }
        }

        function updatePopulationChart(baseline, policyDataChart) {
            const ctx = document.getElementById('population-chart');
            if (!ctx) {
                console.error('인구 차트 캔버스를 찾을 수 없습니다');
                return;
            }
            
            const chartCtx = ctx.getContext('2d');
            
            if (charts.population) {
                charts.population.destroy();
            }
            
            charts.population = new Chart(chartCtx, {
                type: 'line',
                data: {
                    labels: ['1년 후', '2년 후', '3년 후', '4년 후', '5년 후'],
                    datasets: [{
                        label: '기존 추세',
                        data: baseline,
                        borderColor: '#e74c3c',
                        backgroundColor: 'rgba(231, 76, 60, 0.1)',
                        borderWidth: 2,
                        fill: false,
                        tension: 0.1
                    }, {
                        label: '정책 적용 후',
                        data: policyDataChart,
                        borderColor: '#021024',
                        backgroundColor: 'rgba(2, 16, 36, 0.1)',
                        borderWidth: 3,
                        fill: false,
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            title: {
                                display: true,
                                text: '인구 변화율 (%)'
                            }
                        }
                    }
                }
            });
        }

        function updateEconomicChart(data) {
            const ctx = document.getElementById('economic-chart');
            if (!ctx) {
                console.error('경제 차트 캔버스를 찾을 수 없습니다');
                return;
            }
            
            const chartCtx = ctx.getContext('2d');
            
            if (charts.economic) {
                charts.economic.destroy();
            }
            
            charts.economic = new Chart(chartCtx, {
                type: 'bar',
                data: {
                    labels: ['1년 후', '2년 후', '3년 후', '4년 후', '5년 후'],
                    datasets: [{
                        label: 'GRDP 증가율',
                        data: data,
                        backgroundColor: ['#021024', '#334155', '#475569', '#64748b', '#94a3b8'],
                        borderColor: ['#021024', '#334155', '#475569', '#64748b', '#94a3b8'],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'GRDP 증가율 (%)'
                            }
                        }
                    }
                }
            });
        }

        function updateSocialChart(data) {
            const ctx = document.getElementById('social-chart');
            if (!ctx) {
                console.error('사회적 효과 차트 캔버스를 찾을 수 없습니다');
                return;
            }
            
            const chartCtx = ctx.getContext('2d');
            
            if (charts.social) {
                charts.social.destroy();
            }
            
            charts.social = new Chart(chartCtx, {
                type: 'radar',
                data: {
                    labels: ['주거환경', '교육환경', '복지수준', '고용안정성', '생활만족도'],
                    datasets: [{
                        label: '정책 효과',
                        data: data,
                        backgroundColor: 'rgba(2, 16, 36, 0.2)',
                        borderColor: '#021024',
                        borderWidth: 2,
                        pointBackgroundColor: '#021024',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        r: {
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                stepSize: 20
                            }
                        }
                    }
                }
            });
        }

        function formatNumber(num) {
            return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        }
    </script>
</body>
</html>
