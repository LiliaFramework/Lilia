util.AddNetworkString("AdminModeSwapCharacter")
lia.log.addType("adminMode", {
  func = function(client, id, message) return string.format("[%s] %s: %s [CharID: %d]", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), message, id) end,
  category = "Admin Actions",
  color = Color(255, 255, 0)
})

lia.log.addType("sitRoomSet", {
  func = function(client, pos, message) return string.format("[%s] %s: %s [Location: %s]", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), message, pos) end,
  category = "Sit Rooms",
  color = Color(0, 255, 0)
})

lia.log.addType("sendToSitRoom", {
  func = function(client, target, message) return string.format("[%s] %s: %s [%s]", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), message, target) end,
  category = "Sit Rooms",
  color = Color(0, 128, 255)
})