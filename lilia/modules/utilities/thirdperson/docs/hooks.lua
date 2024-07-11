--- Hook Documentation for Third Person Module.
-- @hooks ThirdPerson

--- Called when the third-person mode is toggled.
--- @realm client
--- @bool state Indicates whether the third-person mode is enabled (`true`) or disabled (`false`).
function thirdPersonToggled(state)
end

--- Runs to check if third-person view is allowed.
-- @realm client
-- @client client The player client to check.
-- @return bool True if third-person view should be disabled, false otherwise.
function ShouldDisableThirdperson(client)
end
