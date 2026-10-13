package com.jiawa.wiki.runner;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Created by Qinyi.
 * 默认 ApplicationRunner 会优先于 CommandLineRunner 执行
 * 但是 @Order 可以改变执行顺序
 */
@Order(value = 1)
@Component
@Slf4j
public class Runner01 implements CommandLineRunner {
    /**
     * 将 参数 封装成 string 数组
     * @param strings
     * @throws Exception
     */
    @Override
    public void run(String... strings) throws Exception {
        log.info("Running Runner01");
    }
}
