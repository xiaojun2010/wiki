package com.jiawa.wiki;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
--add-opens java.base/java.lang=ALL-UNNAMED
--add-opens java.base/java.lang.reflect=ALL-UNNAMED
--add-opens java.base/java.util=ALL-UNNAMED
--add-opens java.base/java.util.concurrent=ALL-UNNAMED
--add-opens java.base/java.io=ALL-UNNAMED
--add-opens java.base/java.text=ALL-UNNAMED
--add-opens java.base/java.math=ALL-UNNAMED
--add-opens java.base/java.net=ALL-UNNAMED
--add-opens java.base/java.time=ALL-UNNAMED
--add-opens java.base/sun.nio.ch=ALL-UNNAMED
--add-opens java.base/sun.net.www.protocol.http=ALL-UNNAMED
--add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED
--add-opens java.desktop/java.awt.font=ALL-UNNAMED
 */
@EnableScheduling
@SpringBootApplication
public class WikiApplication {

    /**
     * <h2>SpringBoot 应用入口类</h2>
     * */
	public static void main(String[] args) {

		SpringApplication.run(WikiApplication.class, args);
	}
}

