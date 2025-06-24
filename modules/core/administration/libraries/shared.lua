function MODULE:CanPlayerModifyConfig(client)
    return client:hasPrivilege("Staff Permissions - Access Edit Configuration Menu")
end