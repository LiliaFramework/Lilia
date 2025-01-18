function MODULE:PropBreak(_, entity)
  if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end
end
