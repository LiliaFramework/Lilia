--- Default tables for database tables.
-- These tables define the structure of the database tables used in Lilia.
-- @configurations DatableConnection

-- @table DatabaseTables
-- @realm server
-- @field MySQLTableCreate SQL query for creating tables in MySQL database | **string**
-- @field SqlLiteTableCreate SQL query for creating tables in SQLite database | **string**
-- @field SqlLiteTableDrop SQL query for dropping tables in SQLite database | **string**
-- @field MySQLTableDrop SQL query for dropping tables in MySQL database | **string**
MySQLTableCreate = [[
    CREATE TABLE IF NOT EXISTS `lia_players` (
        `_steamID` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_steamName` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_firstJoin` DATETIME,
        `_lastJoin` DATETIME,
        `_data` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_intro` BINARY(1) NULL DEFAULT 0,
        PRIMARY KEY (`_steamID`)
    );

    CREATE TABLE IF NOT EXISTS `lia_characters` (
        `_id` INT(12) NOT NULL AUTO_INCREMENT,
        `_steamID` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_name` VARCHAR(70) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_desc` VARCHAR(512) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_model` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_attribs` VARCHAR(512) DEFAULT NULL COLLATE 'utf8mb4_general_ci',
        `_schema` VARCHAR(24) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_createTime` DATETIME NOT NULL,
        `_lastJoinTime` DATETIME NOT NULL,
        `_data` VARCHAR(1024) DEFAULT NULL COLLATE 'utf8mb4_general_ci',
        `_money` INT(10) UNSIGNED NULL DEFAULT '0',
        `_faction` VARCHAR(24) DEFAULT NULL COLLATE 'utf8mb4_general_ci',
        `recognized_as` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
        PRIMARY KEY (`_id`)
    );

    CREATE TABLE IF NOT EXISTS `lia_inventories` (
        `_invID` INT(12) NOT NULL AUTO_INCREMENT,
        `_charID` INT(12) NULL DEFAULT NULL,
        `_invType` VARCHAR(24) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
        PRIMARY KEY (`_invID`)
    );

    CREATE TABLE IF NOT EXISTS `lia_items` (
        `_itemID` INT(12) NOT NULL AUTO_INCREMENT,
        `_invID` INT(12) NULL DEFAULT NULL,
        `_uniqueID` VARCHAR(60) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_data` VARCHAR(512) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
        `_quantity` INT(16),
        `_x` INT(4),
        `_y` INT(4),
        PRIMARY KEY (`_itemID`)
    );

    CREATE TABLE IF NOT EXISTS `lia_invdata` (
        `_invID` INT(12) NOT NULL,
        `_key` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
        `_value` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
        FOREIGN KEY (`_invID`) REFERENCES lia_inventories(_invID) ON DELETE CASCADE,
        PRIMARY KEY (`_invID`, `_key`)
    );

    CREATE TABLE IF NOT EXISTS `lilia_logs` (
        `id` INT(12) NOT NULL AUTO_INCREMENT,
        `category` TEXT NOT NULL,
        `log` TEXT NOT NULL,
        `time` INT(12) NOT NULL,
        PRIMARY KEY (`id`)
    );
]]
SqlLiteTableCreate = [[
    CREATE TABLE IF NOT EXISTS lia_players (
        _steamID varchar,
        _steamName varchar,
        _firstJoin datetime,
        _lastJoin datetime,
        _data varchar,
        _intro binary
    );

    CREATE TABLE IF NOT EXISTS lia_characters (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        _steamID VARCHAR,
        _name VARCHAR,
        _desc VARCHAR,
        _model VARCHAR,
        _attribs VARCHAR,
        _schema VARCHAR,
        _createTime DATETIME,
        _lastJoinTime DATETIME,
        _data VARCHAR,
        _money VARCHAR,
        _faction VARCHAR,
        recognized_as TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS lia_inventories (
        _invID integer PRIMARY KEY AUTOINCREMENT,
        _charID integer,
        _invType varchar
    );

    CREATE TABLE IF NOT EXISTS lia_items (
        _itemID integer PRIMARY KEY AUTOINCREMENT,
        _invID integer,
        _uniqueID varchar,
        _data varchar,
        _quantity integer,
        _x integer,
        _y integer
    );

    CREATE TABLE IF NOT EXISTS lia_invdata (
        _invID integer,
        _key text,
        _value text,
        FOREIGN KEY(_invID) REFERENCES lia_inventories(_invID),
        PRIMARY KEY (_invID, _key)
    );

    CREATE TABLE IF NOT EXISTS lilia_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        log TEXT NOT NULL,
        time INTEGER NOT NULL
    );
]]
MySQLTableDrop = [[
    DROP TABLE IF EXISTS `lia_players`;
    DROP TABLE IF EXISTS `lia_characters`;
    DROP TABLE IF EXISTS `lia_inventories`;
    DROP TABLE IF EXISTS `lia_items`;
    DROP TABLE IF EXISTS `lia_invdata`;
    DROP TABLE IF EXISTS `lia_inventories`;
]]
SqlLiteTableDrop = [[
    DROP TABLE IF EXISTS lia_players;
    DROP TABLE IF EXISTS lia_characters;
    DROP TABLE IF EXISTS lia_inventories;
    DROP TABLE IF EXISTS lia_items;
    DROP TABLE IF EXISTS lia_invdata;
    DROP TABLE IF EXISTS lia_inventories;
]]
