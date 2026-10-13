package com.jiawa.wiki;

import com.jiawa.wiki.config.MySQLConfig;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.jasypt.encryption.StringEncryptor;
import org.jasypt.exceptions.EncryptionOperationNotPossibleException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

@RunWith(SpringRunner.class)
@SpringBootTest(properties = {
    "spring.datasource.password=" + EncryptionIntegrationTests.CIPHERTEXT,
    "adconf.mysql.password=" + EncryptionIntegrationTests.CIPHERTEXT,
    "spring.datasource.url=jdbc:h2:mem:wiki-encryption-test;MODE=MySQL;DB_CLOSE_ON_EXIT=FALSE"
})
@ActiveProfiles("integration-test")
public class EncryptionIntegrationTests {
    static final String CIPHERTEXT = "ENC(g56DlO5KjcZNjcZ9qN9Fd45ti3326iRshG/uBdAojuEPsq/pysTErSkRAcVAlvRMCilGMpxcul+AejP919FxiA==)";

    @Autowired
    private DataSourceProperties dataSourceProperties;
    @Autowired
    private MySQLConfig mySQLConfig;

    @Test
    public void decryptsBothPasswordProperties() {
        assertEquals("test-db-password", dataSourceProperties.getPassword());
        assertEquals("test-db-password", mySQLConfig.getPassword());
        assertFalse(mySQLConfig.toString().contains("test-db-password"));
    }

    @Test(expected = EncryptionOperationNotPossibleException.class)
    public void rejectsWrongMasterKey() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty("jasypt.encryptor.password", "wrong-key")
                .withProperty("jasypt.encryptor.algorithm", "PBEWITHHMACSHA512ANDAES_256")
                .withProperty("jasypt.encryptor.key-obtention-iterations", "100000");
        StringEncryptor encryptor = new EncryptionConfig().stringEncryptor(environment);
        encryptor.decrypt(CIPHERTEXT.substring(4, CIPHERTEXT.length() - 1));
    }

    @Test(expected = IllegalStateException.class)
    public void requiresMasterKey() {
        new EncryptionConfig().stringEncryptor(new MockEnvironment()
                .withProperty("jasypt.encryptor.password-file", "target/nonexistent-encryption-key.env"));
    }

    @Test
    public void readsLocalKeyWhenEnvironmentKeyIsAbsent() throws Exception {
        Path keyFile = Files.createTempFile("wiki-test-key-", ".env");
        try {
            Files.write(keyFile, "export JASYPT_ENCRYPTOR_PASSWORD=integration-test-key-not-for-production\n"
                    .getBytes(StandardCharsets.UTF_8));
            MockEnvironment environment = new MockEnvironment()
                    .withProperty("jasypt.encryptor.password-file", keyFile.toString())
                    .withProperty("jasypt.encryptor.algorithm", "PBEWITHHMACSHA512ANDAES_256")
                    .withProperty("jasypt.encryptor.key-obtention-iterations", "100000");
            StringEncryptor encryptor = new EncryptionConfig().stringEncryptor(environment);
            assertEquals("test-db-password", encryptor.decrypt(CIPHERTEXT.substring(4, CIPHERTEXT.length() - 1)));
        } finally {
            Files.deleteIfExists(keyFile);
        }
    }

    @Test
    public void explicitKeyTakesPriorityOverLocalFile() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty("jasypt.encryptor.password", "integration-test-key-not-for-production")
                .withProperty("jasypt.encryptor.password-file", "target/nonexistent-encryption-key.env")
                .withProperty("jasypt.encryptor.algorithm", "PBEWITHHMACSHA512ANDAES_256")
                .withProperty("jasypt.encryptor.key-obtention-iterations", "100000");
        StringEncryptor encryptor = new EncryptionConfig().stringEncryptor(environment);
        assertEquals("test-db-password", encryptor.decrypt(CIPHERTEXT.substring(4, CIPHERTEXT.length() - 1)));
    }
}
