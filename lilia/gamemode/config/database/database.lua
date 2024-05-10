--- Default database configuration for Lilia.
-- @configurations DatabaseConnection


--- This table defines the default settings for connecting to the database used in Lilia.
-- @table Configuration
-- @realm server
-- @field module Database module to be used (sqlite or mysqloo) | **string**
-- @field hostname Hostname of the database server | **string**
-- @field username Username for accessing the database | **string**
-- @field password Password for accessing the database | **string**
-- @field database Name of the database to connect to | **string**
-- @field port Port number for the database server | **integer**
DefaultDatabase = {
    module = "sqlite",
    hostname = "127.0.0.1",
    username = "",
    password = "",
    database = "",
    port = 3306,
}
