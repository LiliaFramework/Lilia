--- Hook Documentation for Bodygrouper Module.
-- @hooksmodule Bodygrouper

--- Called when a user leaves a bodygrouper closet.
-- This hook is triggered when a player is removed from a bodygrouper closet.
-- @entity closet The bodygrouper closet entity.
-- @client client The player who was removed from the closet.
function BodygrouperClosetRemoveUser(closet, client)
end

--- Called when a user enters a bodygrouper closet.
-- This hook is triggered when a player is added to a bodygrouper closet.
-- @entity closet The bodygrouper closet entity.
-- @client client The player who was added to the closet.
function BodygrouperClosetAddUser(closet, client)
end