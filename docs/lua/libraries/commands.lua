--[[
    lia.command.add(command, data)

    Description:
        Registers a new command with its associated data.

    Parameters:
        command (string) – Command name.
        data (table) – Table containing command properties.

    Returns:
        nil

    Realm:
        Shared
]]

--[[
    lia.command.hasAccess(client, command, data)

    Description:
        Determines if a player may run the specified command.

    Parameters:
        client (Player) – Command caller.
        command (string) – Command name.
        data (table) – Command data table.

    Returns:
        boolean – Whether access is granted.
        string – Privilege checked.

    Realm:
        Shared
]]

--[[
   lia.command.extractArgs

   Description:
      Splits the provided text into arguments, respecting quotes.
      Quoted sections are treated as single arguments.

   Parameters:
      text (string) - The raw input text to parse.

   Returns:
      table - A list of arguments extracted from the text.

   Realm:
      Shared

   Example Usage:
        -- [[ Example of how to use this function ]]
      local args = lia.command.extractArgs('/mycommand "quoted arg" anotherArg')
      -- args = {"quoted arg", "anotherArg"}
]]

    --[[
      lia.command.run

      Description:
         Executes a command by its name, passing the provided arguments.
         If the command returns a string, it notifies the client (if valid).

      Parameters:
         client (Player) - The player or console running the command.
         command (string) - The name of the command to run.
         arguments (table) - A list of arguments for the command.

      Returns:
         nil

      Realm:
         Server

      Example Usage:
        -- [[ Example of how to use this function ]]
         lia.command.run(player, "mycommand", {"arg1", "arg2"})
   ]]

    --[[
      lia.command.parse

      Description:
         Attempts to parse the input text as a command, optionally using realCommand
         and arguments if provided. If parsed successfully, the command is executed.

      Parameters:
         client (Player) - The player or console issuing the command.
         text (string) - The raw text that may contain the command name and arguments.
         realCommand (string) - If provided, use this as the command name instead of parsing text.
         arguments (table) - If provided, use these as the command arguments instead of parsing text.

      Returns:
         boolean - True if the text was parsed as a valid command, false otherwise.

      Realm:
         Server

      Example Usage:
        -- [[ Example of how to use this function ]]
         lia.command.parse(player, "/mycommand arg1 arg2")
   ]]

    --[[
      lia.command.send

      Description:
         Sends a command (and optional arguments) from the client to the server using netstream.
         The server will then execute the command.

      Parameters:
         command (string) - The name of the command to send.
         ... (vararg) - Any additional arguments to pass to the command.

      Returns:
         nil

      Realm:
         Client

      Example Usage:
        -- [[ Example of how to use this function ]]
         lia.command.send("mycommand", "arg1", "arg2")
   ]]
