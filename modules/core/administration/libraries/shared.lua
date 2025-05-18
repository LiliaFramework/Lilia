function MODULE:CanPlayerModifyConfig(client)
    print(client, tostring(client:hasPrivilege("Staff Permissions - Access Edit Configuration Menu")))
    return client:hasPrivilege("Staff Permissions - Access Edit Configuration Menu")
end