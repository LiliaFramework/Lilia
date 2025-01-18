lia.table = lia.table or {}
function lia.table.Sum(tbl)
  local sum = 0
  for _, v in pairs(tbl) do
    if isnumber(v) then
      sum = sum + v
    elseif istable(v) then
      sum = sum + lia.table.Sum(v)
    end
  end
  return sum
end

function lia.table.Lookupify(tbl)
  local lookup = {}
  for _, v in pairs(tbl) do
    lookup[v] = true
  end
  return lookup
end

function lia.table.MakeAssociative(tab)
  local ret = {}
  for _, v in pairs(tab) do
    ret[v] = true
  end
  return ret
end

function lia.table.Unique(tab)
  return table.GetKeys(table.MakeAssociative(tab))
end

function lia.table.FullCopy(tab)
  local res = {}
  for k, v in pairs(tab) do
    if istable(v) then
      res[k] = lia.table.FullCopy(v)
    elseif isvector(v) then
      res[k] = Vector(v.x, v.y, v.z)
    elseif isangle(v) then
      res[k] = Angle(v.p, v.y, v.r)
    else
      res[k] = v
    end
  end
  return res
end

function lia.table.Filter(tab, func)
  local c = 1
  for i = 1, #tab do
    if func(tab[i]) then
      tab[c] = tab[i]
      c = c + 1
    end
  end

  for i = c, #tab do
    tab[i] = nil
  end
  return tab
end

function lia.table.FilterCopy(tab, func)
  local ret = {}
  for i = 1, #tab do
    if func(tab[i]) then ret[#ret + 1] = tab[i] end
  end
  return ret
end

table.Sum = lia.table.Sum
table.Unique = lia.table.Unique
table.Filter = lia.table.Filter
table.FullCopy = lia.table.FullCopy
table.Lookupify = lia.table.Lookupify
table.FilterCopy = lia.table.FilterCopy
table.MakeAssociative = lia.table.MakeAssociative
