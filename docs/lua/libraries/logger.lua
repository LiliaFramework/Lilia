    --[[
      lia.log.loadTables()

      Description:
         Creates the logs directory for the current active gamemode under "lilia/logs".

      Parameters:
         None

      Returns:
          nil

      Realm:
         Server

      Internal Function:
         true
   ]]

    --[[
      lia.log.addType(logType, func, category)

      Description:
         Registers a new log type by associating a log generating function and a category with the log type identifier.
         The registered function will be used later to generate log messages for that type.

      Parameters:
         logType (string) - The unique identifier for the log type.
         func (function) - A function that takes a client and additional parameters, returning a log string.
         category (string) - The category for the log type, used for organizing log files.

      Returns:
          nil

      Realm:
         Server
   ]]

    --[[
      lia.log.getString(client, logType, ...)

      Description:
         Retrieves the log string and its associated category for a given client and log type.
         It calls the registered log function with the provided parameters.

      Parameters:
         client (Player) - The client for which the log is generated.
         logType (string) - The identifier for the log type.
         ... (vararg) - Additional parameters passed to the log function.

      Returns:
          string, string - The generated log string and its category if successful; otherwise, nil.

      Realm:
         Server

      Internal Function:
         true
   ]]

    --[[
      lia.log.add(client, logType, ...)

      Description:
         Generates a log string using the registered log type function, triggers the "OnServerLog" hook,
         and appends the log string to a log file corresponding to its category in the logs directory.

      Parameters:
         client (Player) - The client associated with the log event.
         logType (string) - The identifier for the log type.
         ... (vararg) - Additional parameters passed to the log type function.

      Returns:
          nil

      Realm:
         Server
   ]]
