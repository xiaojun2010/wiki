CREATE database if NOT EXISTS `wiki` default character set utf8mb4 collate utf8mb4_unicode_ci;
use `wiki`;


drop table if exists `test`;


create table `test`
(
    `id`   bigint not null comment 'id',
    `name` varchar(50) comment '名称',
    primary key (`id`)
)
    engine = innodb default charset = utf8mb4 comment ='测试';