local ExploitableNets = {"VJSay", "vj_fireplace_turnon1", "vj_npcmover_sv_create", "vj_npcmover_sv_startmove", "vj_npcmover_removesingle", "vj_npcmover_removeall", "vj_npcspawner_sv_create", "vj_npcrelationship_sr_leftclick", "vj_testentity_runtextsd", "vj_fireplace_turnon2"}
local function ExploitableNet(client, netName)
  if not IsValid(client) or not client:IsPlayer() then return end
  client:ChatPrint("Unauthorized use of net message: " .. netName)
  lia.log.add(client, "unprotectedVJNetCall", {
    netMessage = netName
  })
end

for _, netName in ipairs(ExploitableNets) do
  net.Receive(netName, function(_, client) ExploitableNet(client, netName) end)
end
