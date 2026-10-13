package com.jiawa.wiki.runner;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Created by Qinyi.
 */
@Order(value = 2)
@Component
@Slf4j
public class Runner02 implements ApplicationRunner {

    /**
     * ApplicationRunner 将外部参数 封装成 ApplicationArguments 对象
     * @param applicationArguments
     * @throws Exception
     */
    @Override
    public void run(ApplicationArguments applicationArguments) throws Exception {

        log.info("Running Runner02");
    }
}
