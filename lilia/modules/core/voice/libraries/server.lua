local GM = GM or GAMEMODE
local MODULE = MODULE
function GM:PlayerCanHearPlayersVoice(listener, speaker)
  if not IsValid(listener) and IsValid(speaker) or listener == speaker then return false, false end
  if speaker:GetNWBool("IsDeadRestricted", false) then return false, false end
  local char = speaker:getChar()
  if not (char and not char:getData("VoiceBan", false)) then return false, false end
  if not (lia.config.get("IsVoiceEnabled", true) and GetGlobalBool("EnabledVoice", true)) then return false, false end
  local voiceType = speaker:getNetVar("VoiceType", "Talking")
  local range = MODULE.TalkRanges[voiceType] or MODULE.TalkRanges["Talking"]
  local distanceSqr = listener:GetPos():DistToSqr(speaker:GetPos())
  local canHear = distanceSqr <= range * range
  return canHear, canHear
end

function MODULE:PostPlayerLoadout(client)
  client:setNetVar("VoiceType", "Talking")
end

util.AddNetworkString("ChangeSpeakMode")
net.Receive("ChangeSpeakMode", function(_, client)
  local mode = net.ReadString()
  if MODULE.TalkRanges[mode] then client:setNetVar("VoiceType", mode) end
end)