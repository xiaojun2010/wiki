-- 根据 mapper 接口、Mapper XML、实体及 Service 生成的 MySQL 建表脚本。
-- 每个字段独占一行；仅创建不存在的表，不删除数据，也不迁移已有表结构。
-- Mapper 不包含完整 DDL 元数据，以下字符串长度、默认值、索引为推定设计：
-- 普通名称 50 字符，书名/文档名 100 字符，简介 1000 字符，封面地址 500 字符。
-- user.password 使用 CHAR(32)，与当前 UserController 的 MD5 十六进制输出一致。
-- content.content 使用 LONGTEXT；关系由现有业务代码维护，不额外施加外键约束。
-- 计数字段允许 NULL，以兼容现有全字段 INSERT/UPDATE 显式传入 NULL 的行为；
-- DEFAULT 0 仅在 INSERT 省略对应字段时生效。
-- ebook_snapshot.id 自增，因 EbookSnapshotMapperCust.genSnapshot 不传入 id。
-- 其他主键由调用方提供；业务实体沿用现有 SnowFlake ID，content.id 复用 doc.id。

CREATE DATABASE IF NOT EXISTS `wiki`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `wiki`;

CREATE TABLE IF NOT EXISTS `test`
(
    `id` BIGINT NOT NULL COMMENT 'ID',
    `name` VARCHAR(50) DEFAULT NULL COMMENT '名称',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '测试';

CREATE TABLE IF NOT EXISTS `demo`
(
    `id` BIGINT NOT NULL COMMENT 'ID',
    `name` VARCHAR(50) DEFAULT NULL COMMENT '名称',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '示例';

CREATE TABLE IF NOT EXISTS `category`
(
    `id` BIGINT NOT NULL COMMENT '分类ID',
    `parent` BIGINT DEFAULT 0 COMMENT '父分类ID，0表示根分类',
    `name` VARCHAR(50) DEFAULT NULL COMMENT '分类名称',
    `sort` INT DEFAULT 0 COMMENT '排序',
    PRIMARY KEY (`id`),
    KEY `idx_category_parent_sort` (`parent`, `sort`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分类';

CREATE TABLE IF NOT EXISTS `ebook`
(
    `id` BIGINT NOT NULL COMMENT '电子书ID',
    `name` VARCHAR(100) DEFAULT NULL COMMENT '电子书名称',
    `category1_id` BIGINT DEFAULT NULL COMMENT '一级分类ID',
    `category2_id` BIGINT DEFAULT NULL COMMENT '二级分类ID',
    `description` VARCHAR(1000) DEFAULT NULL COMMENT '简介',
    `cover` VARCHAR(500) DEFAULT NULL COMMENT '封面地址',
    `doc_count` INT DEFAULT 0 COMMENT '文档数',
    `view_count` INT DEFAULT 0 COMMENT '阅读数',
    `vote_count` INT DEFAULT 0 COMMENT '点赞数',
    PRIMARY KEY (`id`),
    KEY `idx_ebook_category1` (`category1_id`),
    KEY `idx_ebook_category2` (`category2_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '电子书';

CREATE TABLE IF NOT EXISTS `doc`
(
    `id` BIGINT NOT NULL COMMENT '文档ID',
    `ebook_id` BIGINT DEFAULT NULL COMMENT '所属电子书ID',
    `parent` BIGINT DEFAULT 0 COMMENT '父文档ID，0表示根文档',
    `name` VARCHAR(100) DEFAULT NULL COMMENT '文档名称',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `view_count` INT DEFAULT 0 COMMENT '阅读数',
    `vote_count` INT DEFAULT 0 COMMENT '点赞数',
    PRIMARY KEY (`id`),
    KEY `idx_doc_ebook_sort` (`ebook_id`, `sort`),
    KEY `idx_doc_parent` (`parent`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档';

CREATE TABLE IF NOT EXISTS `content`
(
    `id` BIGINT NOT NULL COMMENT '文档ID，与doc.id对应',
    `content` LONGTEXT COMMENT '文档正文',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档内容';

CREATE TABLE IF NOT EXISTS `user`
(
    `id` BIGINT NOT NULL COMMENT '用户ID',
    `login_name` VARCHAR(50) NOT NULL COMMENT '登录名',
    `name` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `password` CHAR(32) DEFAULT NULL COMMENT '密码摘要，匹配当前代码格式',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_login_name` (`login_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户';

CREATE TABLE IF NOT EXISTS `ebook_snapshot`
(
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '快照ID',
    `ebook_id` BIGINT NOT NULL COMMENT '电子书ID',
    `date` DATE NOT NULL COMMENT '快照日期',
    `view_count` INT DEFAULT 0 COMMENT '累计阅读数',
    `vote_count` INT DEFAULT 0 COMMENT '累计点赞数',
    `view_increase` INT DEFAULT 0 COMMENT '当日阅读增量',
    `vote_increase` INT DEFAULT 0 COMMENT '当日点赞增量',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_snapshot_ebook_date` (`ebook_id`, `date`),
    KEY `idx_snapshot_date` (`date`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '电子书每日统计快照';
