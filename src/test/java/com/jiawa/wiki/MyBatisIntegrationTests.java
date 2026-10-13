package com.jiawa.wiki;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("integration-test")
@Transactional
@Sql(statements = "CREATE TABLE IF NOT EXISTS test (id BIGINT PRIMARY KEY, name VARCHAR(50))")
public class MyBatisIntegrationTests {
    @Autowired
    private MockMvc mvc;

    @Test
    @Sql(statements = {
        "CREATE TABLE IF NOT EXISTS test (id BIGINT PRIMARY KEY, name VARCHAR(50))",
        "INSERT INTO test (id, name) VALUES (2, '第二条'), (1, '第一条')"
    })
    public void listsRecordsThroughMyBatis() throws Exception {
        mvc.perform(get("/test/list"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[0].id").value(1))
            .andExpect(jsonPath("$[0].name").value("第一条"))
            .andExpect(jsonPath("$[1].id").value(2));
    }

    @Test
    public void returnsEmptyListForEmptyTable() throws Exception {
        mvc.perform(get("/test/list"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(0));
    }
}
