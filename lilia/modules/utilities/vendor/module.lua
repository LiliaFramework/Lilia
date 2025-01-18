MODULE.name = "Vendors"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Adds NPC vendors that can sell things."
MODULE.CAMIPrivileges = {
  {
    Name = "Staff Permissions - Can Edit Vendors",
    MinAccess = "admin",
    Description = "Allows access to edit vendors.",
  },
}

if CLIENT then
  function MODULE:PopulateAdminStick(AdminMenu, target)
    if IsValid(target) and target:GetClass() == "lia_vendor" then
      AdminMenu:AddOption("Restock Vendor", function()
        LocalPlayer():ConCommand("say /restockvendor")
        AdminStickIsOpen = false
      end):SetIcon("icon16/arrow_refresh.png")

      AdminMenu:AddOption("Restock Vendor Money", function()
        Derma_StringRequest("Restock Vendor Money", "Enter amount:", "", function(amount)
          if amount and tonumber(amount) then LocalPlayer():ConCommand("say /restockvendormoney " .. tonumber(amount)) end
          AdminStickIsOpen = false
        end)
      end):SetIcon("icon16/money_add.png")
    end
  end
end
