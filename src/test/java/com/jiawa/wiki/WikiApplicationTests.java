package com.jiawa.wiki;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.LoggerContext;
import org.apache.logging.log4j.core.appender.AbstractAppender;
import org.apache.logging.log4j.core.config.LoggerConfig;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.LoggerFactory;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;

@RunWith(SpringRunner.class)
@SpringBootTest
@ActiveProfiles("integration-test")
public class WikiApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void logsAreWrittenOnABackgroundThread() throws InterruptedException {
		CountDownLatch written = new CountDownLatch(1);
		AtomicReference<Thread> writer = new AtomicReference<>();
		String message = "async-logging-verification";
		AbstractAppender observer = new AbstractAppender("AsyncTestObserver", null, null, false) {
			@Override
			public void append(LogEvent event) {
				if (message.equals(event.getMessage().getFormattedMessage())) {
					writer.set(Thread.currentThread());
					written.countDown();
				}
			}
		};
		LoggerContext context = (LoggerContext) LogManager.getContext(false);
		LoggerConfig root = context.getConfiguration().getRootLogger();
		observer.start();
		root.addAppender(observer, null, null);
		try {
			LoggerFactory.getLogger(WikiApplicationTests.class).info(message);
			assertTrue("Log event should reach the appender", written.await(5, TimeUnit.SECONDS));
			assertNotSame("Log I/O should run off the calling thread", Thread.currentThread(), writer.get());
		} finally {
			root.removeAppender(observer.getName());
			observer.stop();
		}
	}

}

