package com.jiawa.wiki.config;

import lombok.Data;
import lombok.ToString;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Created by Qinyi.
 */
@Data
@Component
@ConfigurationProperties(prefix = "adconf.mysql")
public class MySQLConfig {

    private String host;
    private Integer port;
    private String database;
    private String username;
    @ToString.Exclude
    private String password;
}
