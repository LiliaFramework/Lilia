local pacNetworkStrings = {"liaPACSync", "liaPACPartAdd", "liaPACPartRemove", "liaPACPartReset"}
for _, netString in ipairs(pacNetworkStrings) do
  util.AddNetworkString(netString)
end
