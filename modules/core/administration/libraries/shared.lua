function MODULE:CanPlayerModifyConfig(client)
    print("hi", client:hasPrivilege("Staff Permissions - Access Edit Configuration Menu"))
    return client:hasPrivilege("Staff Permissions - Access Edit Configuration Menu")
end