package com.moa.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL 드라이버를 찾을 수 없어요. WEB-INF/lib에 mysql-connector-j jar가 있는지 확인하세요.", e);
        }

        String envHost = System.getenv("MYSQLHOST");

        if (envHost != null && !envHost.isEmpty()) {
            // Railway 등 클라우드 배포 환경 - Railway가 자동으로 넣어주는 환경변수를 그대로 사용해요.
            String port = System.getenv("MYSQLPORT");
            String db = System.getenv("MYSQLDATABASE");
            URL = "jdbc:mysql://" + envHost + ":" + port + "/" + db + "?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
            USER = System.getenv("MYSQLUSER");
            PASSWORD = System.getenv("MYSQLPASSWORD");
        } else {
            // 로컬 Eclipse 개발 환경 - 본인 컴퓨터 MySQL 그대로 사용
            URL = "jdbc:mysql://localhost:3306/moadb?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
            USER = "root";
            PASSWORD = "1111";
        }
    }

    // Connection이 뭐냐면, "지금 DB랑 연결된 통로 하나"를 의미해요.
    // 이 메소드를 부를 때마다 새로운 통로 하나가 열려요.
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
