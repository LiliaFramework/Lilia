----------------------------------------------------------------------------------------------
function ExecuteCallback(callback, client, target)
    if type(callback) == "function" then
        callback(client, target)
    end
end
----------------------------------------------------------------------------------------------