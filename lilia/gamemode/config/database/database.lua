--[[--
**Connection Details:**
]]
-- @configurations DatableConnection

--- Default database configuration for Lilia.
-- This table defines the default settings for connecting to the database used in Lilia.
-- @table DefaultDatabaseDetails
-- @realm server
-- @field module Database module to be used (sqlite or mysqloo)
-- @field hostname Hostname of the database server
-- @field username Username for accessing the database
-- @field password Password for accessing the database
-- @field database Name of the database to connect to
-- @field port Port number for the database server

DefaultDatabase = {
    module = "sqlite",
    hostname = "127.0.0.1",
    username = "",
    password = "",
    database = "",
    port = 3306,
}