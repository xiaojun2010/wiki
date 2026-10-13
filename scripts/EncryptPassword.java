import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.jasypt.iv.RandomIvGenerator;

/** Run with the Jasypt jar on the classpath (Java 11+ source-file launcher). */
public class EncryptPassword {
    public static void main(String[] args) throws Exception {
        String masterKey = System.getenv("JASYPT_ENCRYPTOR_PASSWORD");
        if (masterKey == null || masterKey.trim().isEmpty()) {
            throw new IllegalStateException("Set JASYPT_ENCRYPTOR_PASSWORD first");
        }
        String password;
        if (System.console() != null) {
            char[] input = System.console().readPassword("Database password: ");
            if (input == null) {
                throw new IllegalArgumentException("No password supplied");
            }
            password = new String(input);
            java.util.Arrays.fill(input, '\0');
        } else {
            password = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8)).readLine();
        }
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("No password supplied");
        }
        StandardPBEStringEncryptor encryptor = new StandardPBEStringEncryptor();
        encryptor.setPassword(masterKey);
        encryptor.setAlgorithm("PBEWITHHMACSHA512ANDAES_256");
        encryptor.setKeyObtentionIterations(100000);
        encryptor.setIvGenerator(new RandomIvGenerator());
        System.out.println("ENC(" + encryptor.encrypt(password) + ")");
    }
}
