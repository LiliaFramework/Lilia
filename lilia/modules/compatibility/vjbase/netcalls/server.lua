net.Receive("VJSay", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_fireplace_turnon1", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_npcmover_sv_create", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_npcmover_sv_startmove", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_npcmover_removesingle", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_npcmover_removeall", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_npcspawner_sv_create", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_npcrelationship_sr_leftclick", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_testentity_runtextsd", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)

net.Receive("vj_fireplace_turnon2", function(_, client)
    client:chatNotify("This is an exploitable net message. You can't use it!")
    lia.log.add(client, "unprotectedVJNetCall")
end)