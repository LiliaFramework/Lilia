hook.Add("Test_Function", "2looool",function()

if lia.db then
    if #lia.char.names < 1 then netstream.Start("liaCharFetchNames") end
else
    print("lmao")
end

end)