-- Wiki 测试数据（MySQL）。先执行 db/schema.sql，再执行本文件。
-- 本文件不建表、不删表、不清空数据；仅供开发/测试环境导入。
-- 测试账号：wiki_test_writer / wiki_test_reader；密码均为 WikiTest123!。
-- 密码按当前 UserController 的单次 MD5 规则保存；名称不代表任何权限角色。
-- 固定ID范围：分类910xxx、电子书920xxx、文档/正文930xxx、用户940xxx、test950xxx、demo960xxx。
-- 主键或唯一键冲突时保留已有记录，不覆盖用户修改；如ID/登录名已被其他数据占用，请先调整测试ID。
-- 封面为空字符串，避免依赖外部图片；正文使用HTML，覆盖中文和文档树展示。
-- 重复执行会跳过已有记录；不同日期执行会补充新日期快照，历史快照不会自动清理。

SET NAMES utf8mb4;
USE `wiki`;
START TRANSACTION;

INSERT INTO `test`
(
    `id`,
    `name`
)
VALUES
    (950001, '中文查询测试'),
    (950002, '分页查询测试'),
    (950003, '特殊字符测试：Vue & Java')
ON DUPLICATE KEY UPDATE `id` = `test`.`id`;

INSERT INTO `demo`
(
    `id`,
    `name`
)
VALUES
    (960001, '示例一'),
    (960002, '示例二'),
    (960003, '示例三')
ON DUPLICATE KEY UPDATE `id` = `demo`.`id`;

INSERT INTO `category`
(
    `id`,
    `parent`,
    `name`,
    `sort`
)
VALUES
    (910001, 0, '后端开发', 1),
    (910002, 0, '前端开发', 2),
    (910011, 910001, 'Java', 1),
    (910012, 910001, '数据库', 2),
    (910021, 910002, 'Vue', 1),
    (910022, 910002, 'TypeScript', 2)
ON DUPLICATE KEY UPDATE `id` = `category`.`id`;

INSERT INTO `ebook`
(
    `id`,
    `name`,
    `category1_id`,
    `category2_id`,
    `description`,
    `cover`,
    `doc_count`,
    `view_count`,
    `vote_count`
)
VALUES
    (920001, 'Spring Boot 入门', 910001, 910011, '介绍项目搭建、接口开发和数据库访问。', '', 3, 600, 60),
    (920002, 'MySQL 实践', 910001, 910012, '介绍表结构设计、基础查询与索引。', '', 3, 450, 45),
    (920003, 'Vue 3 开发指南', 910002, 910021, '介绍组件、响应式数据和路由。', '', 3, 300, 30)
ON DUPLICATE KEY UPDATE `id` = `ebook`.`id`;

INSERT INTO `doc`
(
    `id`,
    `ebook_id`,
    `parent`,
    `name`,
    `sort`,
    `view_count`,
    `vote_count`
)
VALUES
    (930001, 920001, 0, 'Spring Boot 概览', 1, 300, 30),
    (930002, 920001, 930001, '创建第一个接口', 2, 200, 20),
    (930003, 920001, 930001, '集成 MyBatis', 3, 100, 10),
    (930011, 920002, 0, 'MySQL 基础', 1, 200, 20),
    (930012, 920002, 930011, '设计表结构', 2, 150, 15),
    (930013, 920002, 930011, '索引与查询', 3, 100, 10),
    (930021, 920003, 0, 'Vue 3 基础', 1, 150, 15),
    (930022, 920003, 930021, '响应式与组件', 2, 100, 10),
    (930023, 920003, 930021, 'Vue Router 路由', 3, 50, 5)
ON DUPLICATE KEY UPDATE `id` = `doc`.`id`;

INSERT INTO `content`
(
    `id`,
    `content`
)
VALUES
    (930001, '<h1>Spring Boot 概览</h1><p>Spring Boot 简化 Spring 应用的配置和启动。</p>'),
    (930002, '<h1>创建第一个接口</h1><p>通过 @RestController 和 @GetMapping 定义 HTTP 查询接口。</p>'),
    (930003, '<h1>集成 MyBatis</h1><p>使用 Mapper 接口和 XML 管理 SQL，并通过 Service 组织业务逻辑。</p>'),
    (930011, '<h1>MySQL 基础</h1><p>本示例使用 InnoDB 引擎和 utf8mb4 字符集。</p>'),
    (930012, '<h1>设计表结构</h1><p>为表定义主键、合适的字段类型和必要的唯一索引。</p>'),
    (930013, '<h1>索引与查询</h1><p>使用 EXPLAIN 分析执行计划，按实际查询条件设计索引。</p>'),
    (930021, '<h1>Vue 3 基础</h1><p>Vue 使用声明式模板构建用户界面。</p>'),
    (930022, '<h1>响应式与组件</h1><p>使用 ref、reactive 和 computed 管理响应式状态。</p>'),
    (930023, '<h1>Vue Router 路由</h1><p>使用 createRouter 配置路由，使用 RouterView 显示当前页面。</p>')
ON DUPLICATE KEY UPDATE `id` = `content`.`id`;

INSERT INTO `user`
(
    `id`,
    `login_name`,
    `name`,
    `password`
)
VALUES
    (940001, 'wiki_test_writer', '测试作者', 'f73d2ae43d38a062eba2c4170581aeee'),
    (940002, 'wiki_test_reader', '测试读者', 'f73d2ae43d38a062eba2c4170581aeee')
ON DUPLICATE KEY UPDATE `id` = `user`.`id`;

-- 最近31天（含今天），共3本书 × 31天 = 93条快照。
-- 今日累计值与上面的文档/电子书计数一致，每天阅读增量分别为10、8、6，点赞增量为1（零累计值的首日为0）。
-- 所有累计值非负；相邻日期的累计值差等于增量。最早日期的增量相对于未插入的前一天基线。
-- 使用直接 VALUES 插入及 CURDATE()，此段可独立执行，无需先设置会话变量。
-- 不指定快照id，使用schema.sql定义的自增主键；由(ebook_id,date)唯一索引避免重复。
INSERT INTO `ebook_snapshot`
(
    `ebook_id`,
    `date`,
    `view_count`,
    `vote_count`,
    `view_increase`,
    `vote_increase`
)
VALUES
    (920001, DATE_SUB(CURDATE(), INTERVAL 0 DAY), 600, 60, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 590, 59, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 580, 58, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 570, 57, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 560, 56, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 550, 55, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 540, 54, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 530, 53, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 8 DAY), 520, 52, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 9 DAY), 510, 51, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 500, 50, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 11 DAY), 490, 49, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 480, 48, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 13 DAY), 470, 47, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 460, 46, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 450, 45, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 16 DAY), 440, 44, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 17 DAY), 430, 43, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 18 DAY), 420, 42, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 19 DAY), 410, 41, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 400, 40, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 21 DAY), 390, 39, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 22 DAY), 380, 38, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 23 DAY), 370, 37, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 24 DAY), 360, 36, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 350, 35, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 26 DAY), 340, 34, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 27 DAY), 330, 33, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 28 DAY), 320, 32, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 29 DAY), 310, 31, 10, 1),
    (920001, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 300, 30, 10, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 0 DAY), 450, 45, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 442, 44, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 434, 43, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 426, 42, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 418, 41, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 410, 40, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 402, 39, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 394, 38, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 8 DAY), 386, 37, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 9 DAY), 378, 36, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 370, 35, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 11 DAY), 362, 34, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 354, 33, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 13 DAY), 346, 32, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 338, 31, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 330, 30, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 16 DAY), 322, 29, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 17 DAY), 314, 28, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 18 DAY), 306, 27, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 19 DAY), 298, 26, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 290, 25, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 21 DAY), 282, 24, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 22 DAY), 274, 23, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 23 DAY), 266, 22, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 24 DAY), 258, 21, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 250, 20, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 26 DAY), 242, 19, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 27 DAY), 234, 18, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 28 DAY), 226, 17, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 29 DAY), 218, 16, 8, 1),
    (920002, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 210, 15, 8, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 0 DAY), 300, 30, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 294, 29, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 288, 28, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 282, 27, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 276, 26, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 270, 25, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 264, 24, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 258, 23, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 8 DAY), 252, 22, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 9 DAY), 246, 21, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 240, 20, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 11 DAY), 234, 19, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 228, 18, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 13 DAY), 222, 17, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 216, 16, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 210, 15, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 16 DAY), 204, 14, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 17 DAY), 198, 13, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 18 DAY), 192, 12, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 19 DAY), 186, 11, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 180, 10, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 21 DAY), 174, 9, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 22 DAY), 168, 8, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 23 DAY), 162, 7, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 24 DAY), 156, 6, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 150, 5, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 26 DAY), 144, 4, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 27 DAY), 138, 3, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 28 DAY), 132, 2, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 29 DAY), 126, 1, 6, 1),
    (920003, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 120, 0, 6, 0)
ON DUPLICATE KEY UPDATE `id` = `ebook_snapshot`.`id`;

COMMIT;
