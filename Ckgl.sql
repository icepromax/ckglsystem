-- 创建基础表(没有外键依赖的表)
-- 商品分类表
create database ckgl;
use ckgl;
CREATE TABLE IF NOT EXISTS goodstype (
                                         id INT NOT NULL AUTO_INCREMENT COMMENT '主键',
                                         name VARCHAR(100) NOT NULL COMMENT '分类名',
                                         remark VARCHAR(1000) NULL DEFAULT NULL COMMENT '备注',
                                         PRIMARY KEY (id)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 仓库表
CREATE TABLE IF NOT EXISTS storage (
                                       id INT NOT NULL AUTO_INCREMENT COMMENT '主键',
                                       name VARCHAR(100) NOT NULL COMMENT '仓库名',
                                       remark VARCHAR(1000) NULL DEFAULT NULL COMMENT '备注',
                                       PRIMARY KEY (id)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 用户表
CREATE TABLE IF NOT EXISTS user (
                                    id INT NOT NULL AUTO_INCREMENT COMMENT '主键',
                                    no VARCHAR(20) NULL DEFAULT NULL COMMENT '账号',
                                    name VARCHAR(100) NOT NULL COMMENT '名字',
                                    password VARCHAR(20) NOT NULL COMMENT '密码',
                                    age INT NULL DEFAULT NULL,
                                    sex INT NULL DEFAULT NULL COMMENT '性别',
                                    phone VARCHAR(20) NULL DEFAULT NULL COMMENT '电话',
                                    role_id INT NULL DEFAULT NULL COMMENT '角色 0超级管理员，1管理员，2普通账号',
                                    isValid VARCHAR(4) NULL DEFAULT 'Y' COMMENT '是否有效，Y有效，其他无效',
                                    PRIMARY KEY (id)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 菜单表
CREATE TABLE IF NOT EXISTS menu (
                                    id INT NOT NULL,
                                    menuCode VARCHAR(8) NULL DEFAULT NULL COMMENT '菜单编码',
                                    menuName VARCHAR(16) NULL DEFAULT NULL COMMENT '菜单名字',
                                    menuLevel VARCHAR(2) NULL DEFAULT NULL COMMENT '菜单级别',
                                    menuParentCode VARCHAR(8) NULL DEFAULT NULL COMMENT '菜单的父code',
                                    menuClick VARCHAR(16) NULL DEFAULT NULL COMMENT '点击触发的函数',
                                    menuRight VARCHAR(8) NULL DEFAULT NULL COMMENT '权限 0超级管理员，1表示管理员，2表示普通用户，可以用逗号组合使用',
                                    menuComponent VARCHAR(200) NULL DEFAULT NULL,
                                    menuIcon VARCHAR(100) NULL DEFAULT NULL,
                                    PRIMARY KEY (id)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 商品表(包含wholesale_price字段)
CREATE TABLE IF NOT EXISTS goods (
                                     id INT NOT NULL AUTO_INCREMENT COMMENT '主键',
                                     name VARCHAR(100) NOT NULL COMMENT '货名',
                                     storage INT NOT NULL COMMENT '仓库',
                                     goodsType INT NOT NULL COMMENT '分类',
                                     count INT NULL DEFAULT NULL COMMENT '数量',
                                     wholesale_price DECIMAL(10,2) NULL DEFAULT NULL COMMENT '批发价',
                                     remark VARCHAR(1000) NULL DEFAULT NULL COMMENT '备注',
                                     PRIMARY KEY (id),
                                     CONSTRAINT fk_goods_goodstype FOREIGN KEY (goodsType)
                                         REFERENCES goodstype(id) ON DELETE RESTRICT ON UPDATE CASCADE,
                                     CONSTRAINT fk_goods_storage FOREIGN KEY (storage)
                                         REFERENCES storage(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 记录表
CREATE TABLE IF NOT EXISTS record (
                                      id INT NOT NULL AUTO_INCREMENT COMMENT '主键',
                                      goods INT NOT NULL COMMENT '货品id',
                                      userId INT NULL DEFAULT NULL COMMENT '取货人/补货人',
                                      admin_id INT NULL DEFAULT NULL COMMENT '操作人id',
                                      count INT NULL DEFAULT NULL COMMENT '数量',
                                      createtime DATETIME NULL DEFAULT NULL COMMENT '操作时间',
                                      remark VARCHAR(1000) NULL DEFAULT NULL COMMENT '备注',
                                      PRIMARY KEY (id),
                                      CONSTRAINT fk_record_goods FOREIGN KEY (goods)
                                          REFERENCES goods(id) ON DELETE RESTRICT ON UPDATE CASCADE,
                                      CONSTRAINT fk_record_user FOREIGN KEY (userId)
                                          REFERENCES user(id) ON DELETE SET NULL ON UPDATE CASCADE,
                                      CONSTRAINT fk_record_admin FOREIGN KEY (admin_id)
                                          REFERENCES user(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 通告表
CREATE TABLE IF NOT EXISTS notice (
                                      id INT AUTO_INCREMENT PRIMARY KEY,
                                      title VARCHAR(100) NOT NULL COMMENT '通告标题',
                                      content TEXT NOT NULL COMMENT '通告内容',
                                      publisher VARCHAR(50) NOT NULL COMMENT '发布人',
                                      publish_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
                                      is_top TINYINT(1) DEFAULT 0 COMMENT '是否置顶(0:否 1:是)'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci;

-- 创建索引
CREATE INDEX idx_publish_time ON notice(publish_time);
CREATE INDEX idx_is_top ON notice(is_top);

-- 插入初始数据
-- 商品分类数据
INSERT INTO goodstype VALUES
                          (1, '日用品', '日常生活用品'),
                          (2, '数码产品', '数码产品'),
                          (3, '食品', '食品'),
                          (4, '冷冻品', '冷冻食品'),
                          (5, '水果', '水果产品'),
                          (6, '蔬菜', '蔬菜产品');

-- 仓库数据
INSERT INTO storage VALUES
                        (1, '日用品仓库', '用于存放日用品'),
                        (2, '数码仓库', '用于存放数码产品'),
                        (3, '食品仓库', '用于存放食品'),
                        (4, '冷冻仓库', '用于存放冷冻食品'),
                        (5, '果蔬仓库', '用于存放水果和蔬菜'),
                        (6, '服装仓库', '用于存放服装'),
                        (7, '水产仓库', '用于存放水产品');

-- 用户数据
INSERT INTO user VALUES
                     (1, 'adminPromax', '超级管理员', '123456', 18, 1, '18855079621', 0, 'Y'),
                     (2, 'admin', '普通管理员', '123456', 19, 0, '18855079621', 1, 'Y'),
                     (3, 'user', '用户01', '123456', 20, 0, '18855079621', 2, 'Y'),
                     (4, 'user03', '湫', '123456', 20, 1, '18855079621', 2, 'Y'),
                     (5, 'user04', '朝菌', '123456', 18, 1, '18855079621', 2, 'Y'),
                     (6, 'user05', '蟪蛄', '123456', 32, 0, '18855079621', 2, 'Y'),
                     (7, 'user06', '鲲鹏', '123456', 26, 1, '18855079621', 2, 'Y'),
                     (8, 'admin02', '管理员02', '123456', 24, 0, '18855079621', 1, 'Y'),
                     (9, 'user02', '椿', '123456', 18, 0, '18855079621', 2, 'Y');

-- 菜单数据
INSERT INTO menu VALUES
                     (1, '001', '管理员管理', '1', NULL, 'Admin', '0', 'admin/AdminManage.vue', 'el-icon-s-custom'),
                     (2, '002', '用户管理', '1', NULL, 'User', '0,1', 'user/UserManage.vue', 'el-icon-user-solid'),
                     (3, '003', '仓库管理', '1', NULL, 'Storage', '0,1', 'storage/StorageManage', 'el-icon-office-building'),
                     (4, '004', '物品分类管理', '1', NULL, 'Goodstype', '0,1', 'goodstype/GoodstypeManage', 'el-icon-menu'),
                     (5, '005', '物品管理 ', '1', NULL, 'Goods', '0,1,2', 'goods/GoodsManage', 'el-icon-s-management'),
                     (6, '006', '记录管理', '1', NULL, 'Record', '0,1,2', 'record/RecordManage', 'el-icon-s-order'),
                     (7,'007','数据可视化','1',NULL,'visualization','0,1,2','visualization/visualization.vue','el-icon-s-order'),
                     (8,'008','通告','1',NULL,'information','0,1,2','Information/information.vue','el-icon-s-order');

-- 商品数据（包含wholesale_price字段）
INSERT INTO goods VALUES
                      (1, 'iPhone15', 2, 2, 1100, 6999.00, '货物不可以挤压'),
                      (2, 'MacBook Pro', 2, 2, 50, 12999.00, '贵重物品小心搬运'),
                      (3, '洗发水', 1, 1, 500, 45.50, '日用品'),
                      (4, '冷冻饺子', 4, 4, 200, 25.80, '需冷冻保存'),
                      (5, '苹果', 5, 5, 300, 8.50, '新鲜水果'),
                      (6, '西红柿', 5, 6, 150, 3.20, '蔬菜'),
                      (7, '皮皮虾', 7, 4, 100, 68.00, '海鲜'),
                      (8, 'AD钙奶', 3, 3, 400, 2.50, '饮品'),
                      (9, 'T恤', 6, 1, 250, 79.00, '服装'),
                      (10, 'iPad', 2, 2, 80, 3499.00, '平板电脑'),
                      (11, 'iPad Air5', 2, 2, 800, 8000.00, '货物不可以挤压');

-- 记录数据
INSERT INTO record VALUES
                       (1, 1, 3, 2, 100, '2025-06-06 20:46:48', '取货'),
                       (2, 4, 9, 8, 200, '2025-06-06 20:47:45', '补货'),
                       (3, 5, 4, 2, 80, '2025-06-06 20:48:47', '取货'),
                       (4, 6, 5, 8, 120, '2025-06-06 20:49:57', '补货'),
                       (5, 11, 6, 2, 50, '2025-06-06 20:50:20', '取货');

-- 通告数据
INSERT INTO notice VALUES
    (1, '欢迎使用仓库管理系统', '有合作需要请联系电话18323~~~申请账号', '超级管理员', '2025-06-24 19:47:21', 1);