package com.jiawa.wiki.controller;



import lombok.extern.slf4j.Slf4j;
import com.jiawa.wiki.domain.TestRecord;
import com.jiawa.wiki.service.TestService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
//@Controller 返回一个页面
public class TestController {

    private final TestService testService;

    public TestController(TestService testService) {
        this.testService = testService;
    }

    @GetMapping("/test/list")
    public List<TestRecord> list() {
        List<TestRecord> testRecordList = testService.list();
        log.info("testRecordList = {}",testRecordList);
        return testRecordList;
    }

    @Value("${test.hello}")
    private String testHello;

    @RequestMapping(value = "/hello",method = {RequestMethod.GET,RequestMethod.POST})
    public String hello(){
        return "Hello World!" + testHello;
    }

    @PostMapping("/hello/post")
    public String helloPost(String name){
        log.info("name = {}",name);
        return "Hello World! Post ,"+name;
    }
}
