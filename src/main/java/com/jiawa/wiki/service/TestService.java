package com.jiawa.wiki.service;

import com.jiawa.wiki.domain.TestRecord;
import com.jiawa.wiki.mapper.TestMapper;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TestService {
    private final TestMapper testMapper;

    public TestService(TestMapper testMapper) {
        this.testMapper = testMapper;
    }

    @Transactional(readOnly = true)
    public List<TestRecord> list() {
        return testMapper.findAll();
    }
}
