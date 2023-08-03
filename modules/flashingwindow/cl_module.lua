function MODULE:InitPostEntity()
    if system.IsWindows() and not system.HasFocus() then
        system.FlashWindow()
    end
end