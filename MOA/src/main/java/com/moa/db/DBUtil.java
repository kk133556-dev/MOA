package com.moa.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    // ▼▼▼ 본인 MySQL 환경에 맞게 이 3줄만 수정하세요 ▼▼▼
    private static final String URL = "jdbc:mysql://localhost:3306/moadb?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASSWORD = "1111";
    // ▲▲▲ 여기까지 ▲▲▲

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL 드라이버를 찾을 수 없어요. WEB-INF/lib에 mysql-connector-j jar가 있는지 확인하세요.", e);
        }
    }

    // Connection이 뭐냐면, "지금 DB랑 연결된 통로 하나"를 의미해요.
    // 이 메소드를 부를 때마다 새로운 통로 하나가 열려요.
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
