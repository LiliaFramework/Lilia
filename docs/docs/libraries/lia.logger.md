# Logger Library


This page documents logging utilities.


---


## Overview


The logger library writes structured log entries to files and the console. It tracks important gameplay events for later auditing or debugging.


---


### lia.log.loadTables()

**Description:**


Creates the logs directory for the current active gamemode under "lilia/logs".


**Parameters:**


* None


**Realm:**


* Server


    Internal Function:

    true


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.log.loadTables
    lia.log.loadTables()
```


---


### lia.log.addType(logType, func, category)

**Description:**


Registers a new log type by associating a log generating function and a category with the log type identifier.

The registered function will be used later to generate log messages for that type.


**Parameters:**


* logType (string) – The unique identifier for the log type.


* func (function) – A function that takes a client and additional parameters, returning a log string.


* category (string) – The category for the log type, used for organizing log files.


**Realm:**


* Server


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.log.addType
    lia.log.addType("mytype", function(client)
        return client:Name() .. " did something"
    end, "actions")
```


---


### lia.log.getString(client, logType, ...)

**Description:**


Retrieves the log string and its associated category for a given client and log type.

It calls the registered log function with the provided parameters.


**Parameters:**


* client (Player) – The client for which the log is generated.


* logType (string) – The identifier for the log type.


* ... (vararg) – Additional parameters passed to the log function.


**Realm:**


* Server


    Internal Function:

    true


**Returns:**


* string, string – The generated log string and its category if successful; otherwise, nil.


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.log.getString
    local str, category = lia.log.getString(client, "mytype", "info")
```


---


### lia.log.add(client, logType, ...)

**Description:**


Generates a log string using the registered log type function, triggers the "OnServerLog" hook,

and appends the log string to a log file corresponding to its category in the logs directory.


**Parameters:**


* client (Player) – The client associated with the log event.


* logType (string) – The identifier for the log type.


* ... (vararg) – Additional parameters passed to the log type function.


**Realm:**


* Server


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.log.add
    lia.log.add(client, "mytype", "info")
```

