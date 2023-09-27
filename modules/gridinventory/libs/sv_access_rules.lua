--------------------------------------------------------------------------------------------------------
local function CanAccessIfPlayerHasAccessToBag(inventory, action, context)
	local bagItemID = inventory:getData("item")
	if not bagItemID then return end
	local bagItem = lia.item.instances[bagItemID]
	if not bagItem then return false, "Invalid bag item" end
	local parentInv = lia.inventory.instances[bagItem.invID]
	if parentInv == inventory then return end
	local contextWithBagInv = {}
	for key, value in pairs(context) do
		contextWithBagInv[key] = value
	end

	contextWithBagInv.bagInv = inventory

	return parentInv and parentInv:canAccess(action, contextWithBagInv) or false, "noAccess"
end

--------------------------------------------------------------------------------------------------------
local function CanNotTransferBagIntoBag(inventory, action, context)
	if action ~= "transfer" then return end
	local item, toInventory = context.item, context.to
	if toInventory and toInventory:getData("item") and item.isBag then return false, "A bag cannot be placed into another bag" end -- if to inventory is not valid, it goes to the ground.
end

--------------------------------------------------------------------------------------------------------
local function CanNotTransferBagIfNestedItemCanNotBe(inventory, action, context)
	if action ~= "transfer" then return end
	local bagItem = context.item
	if not bagItem.isBag then return end
	local bagInventory = bagItem:getInv()
	if not bagInventory then return end
	for _, nestedItem in pairs(bagInventory:getItems()) do
		local canTransferNestedItem, reason = hook.Run("CanItemBeTransfered", nestedItem, bagInventory, bagInventory, context.client)
		if canTransferNestedItem == false then return false, reason or "An item in the bag cannot be transferred" end
	end
end

--------------------------------------------------------------------------------------------------------
function MODULE:SetupBagInventoryAccessRules(inventory)
	inventory:addAccessRule(CanNotTransferBagIntoBag, 1)
	inventory:addAccessRule(CanNotTransferBagIfNestedItemCanNotBe, 1)
	inventory:addAccessRule(CanAccessIfPlayerHasAccessToBag)
end

--------------------------------------------------------------------------------------------------------
function MODULE:ItemCombine(client, item, target)
	if target.onCombine and target:call("onCombine", client, nil, item) then return end -- when other items dragged into the item.
	if item and item.onCombineTo and item:call("onCombineTo", client, nil, target) then return end -- when you drag the item on something
end

--------------------------------------------------------------------------------------------------------
function MODULE:ItemDraggedOutOfInventory(client, item)
	item:interact("drop", client)
end
--------------------------------------------------------------------------------------------------------