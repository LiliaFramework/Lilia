--- Hook Documentation for Third Person Module.
-- @hooks ThirdPerson

--- Called when the third person mode is toggled.
--- @realm client
--- @bool state Indicates whether the third person mode is enabled (`true`) or disabled (`false`).
function thirdPersonToggled(state)
end

--- @realm client
function ShouldDisableThirdperson(client)
end
