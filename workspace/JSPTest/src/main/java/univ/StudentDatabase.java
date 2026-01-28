package univ;

import java.sql.*;
import java.util.ArrayList;

public class StudentDatabase {
    // JDBC 드라이버 및 DB 접속 정보
    private static final String JDBC_DRIVER = "org.gjt.mm.mysql.Driver";
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/JSPDB";
    private static final String USER = "root";
    private static final String PASSWD = "1234";
    
    // 데이터베이스 연결 객체
    private Connection con = null;
    private Statement stmt = null;
    
    // 생성자
    public StudentDatabase() {
        try {
            Class.forName(JDBC_DRIVER);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 데이터베이스 연결 메소드
    public void connect() {
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWD);
            stmt = con.createStatement();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 데이터베이스 연결 해제 메소드
    public void disconnect() {
        try {
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 학생 목록을 가져오는 메소드
    public ArrayList<StudentEntity> getStudentList() {
        connect();
        ArrayList<StudentEntity> list = new ArrayList<>();
        
        try {
            String sql = "SELECT * FROM student";
            ResultSet rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                StudentEntity stu = new StudentEntity();
                stu.setId(rs.getString("id"));
                stu.setPasswd(rs.getString("passwd"));
                stu.setName(rs.getString("name"));
                stu.setYear(rs.getInt("year"));
                stu.setSnum(rs.getString("snum"));
                stu.setDepart(rs.getString("depart"));
                stu.setMobile1(rs.getString("mobile1"));
                stu.setMobile2(rs.getString("mobile2"));
                stu.setAddress(rs.getString("address"));
                stu.setEmail(rs.getString("email"));
                
                list.add(stu);
            }
            rs.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disconnect();
        }
        
        return list;
    }
}
