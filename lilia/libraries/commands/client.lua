----
function lia.command.send(command, ...)
    netstream.Start("cmd", command, {...})
end
----
