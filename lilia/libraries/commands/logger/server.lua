
lia.log.addType("command", function(client, _) return Format("%s used '%s'", client:Name()) end)

lia.log.addType("smartassOOC", function(client, _) return Format("%s tried to send a massive message in OOC or LOOC'", client:Name()) end)

