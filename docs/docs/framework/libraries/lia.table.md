# lia.table

---

## Various Useful Table-Related Functions

The `lia.table` library provides a collection of utility functions for performing common table operations within the Lilia Framework. These functions facilitate tasks such as summing numerical values, creating lookup tables, generating unique value lists, deep copying tables, and filtering table contents. By utilizing these utilities, developers can streamline table manipulations and enhance the functionality of their schemas and plugins.

---

## Functions

### **lia.table.Sum**

**Description:**  
Sums all numerical values in a table. This function recursively traverses nested tables to ensure that all numerical values, regardless of their depth, are included in the total sum.

**Realm:**  
`Shared`

**Parameters:**  

- `tbl` (`table`):  
  The table containing numerical values to sum.

**Returns:**  
`number` - The sum of all numerical values.

**Example Usage:**
```lua
local numbers = {1, 2, {3, 4}, 5}
local total = lia.table.Sum(numbers)
print(total)
-- Output: 15
```

---

### **lia.table.Lookupify**

**Description:**  
Creates a lookup table from a list of values. This function transforms a list into an associative table where each value from the input list becomes a key in the resulting table with a value of `true`. This is useful for quickly checking the existence of elements.

**Realm:**  
`Shared`

**Parameters:**  

- `tbl` (`table`):  
  The list of values to create a lookup table from.

**Returns:**  
`table` - A lookup table where the keys are the values from the input list.

**Example Usage:**
```lua
local fruits = {"apple", "banana", "cherry"}
local fruitLookup = lia.table.Lookupify(fruits)
print(fruitLookup["banana"]) -- Output: true
print(fruitLookup["grape"])  -- Output: nil
```

---

### **lia.table.MakeAssociative**

**Description:**  
Converts a table into an associative table where the original values become keys with a value of `true`. This function is similar to `Lookupify` and is useful for creating sets or checking the existence of elements.

**Realm:**  
`Shared`

**Parameters:**  

- `tab` (`table`):  
  The table to convert.

**Returns:**  
`table` - The associative table.

**Example Usage:**
```lua
local colors = {"red", "green", "blue"}
local colorSet = lia.table.MakeAssociative(colors)
print(colorSet["green"]) -- Output: true
print(colorSet["yellow"])-- Output: nil
```

---

### **lia.table.Unique**

**Description:**  
Returns a table of unique values from the input table. This function removes duplicate entries by leveraging the `MakeAssociative` function and extracting the keys, which represent the unique values.

**Realm:**  
`Shared`

**Parameters:**  

- `tab` (`table`):  
  The table to process.

**Returns:**  
`table` - The table of unique values.

**Example Usage:**
```lua
local numbers = {1, 2, 2, 3, 4, 4, 5}
local uniqueNumbers = lia.table.Unique(numbers)
for _, num in ipairs(uniqueNumbers) do
    print(num)
end
-- Output:
-- 1
-- 2
-- 3
-- 4
-- 5
```

---

### **lia.table.FullCopy**

**Description:**  
Creates a deep copy of a table. This function recursively copies all nested tables, as well as vectors and angles, ensuring that the original table remains unaltered when the copy is modified.

**Realm:**  
`Shared`

**Parameters:**  

- `tab` (`table`):  
  The table to copy.

**Returns:**  
`table` - A deep copy of the table.

**Example Usage:**
```lua
local original = {
    name = "Alice",
    stats = {health = 100, mana = 50},
    position = Vector(10, 20, 30)
}
local copy = lia.table.FullCopy(original)
copy.stats.health = 80
print(original.stats.health) -- Output: 100
print(copy.stats.health)     -- Output: 80
```

---

### **lia.table.Filter**

**Description:**  
Filters a table in-place based on a callback function. This function modifies the original table by removing elements for which the callback returns `false`, retaining only those that pass the test.

**Realm:**  
`Shared`

**Parameters:**  

- `tab` (`table`):  
  The table to filter in-place.

- `func` (`function`):  
  The function to call for each element; if it returns `true`, the element is kept.

**Returns:**  
`table` - The modified (filtered) table.

**Example Usage:**
```lua
local numbers = {1, 2, 3, 4, 5, 6}
-- Filter out even numbers
lia.table.Filter(numbers, function(n)
    return n % 2 ~= 0
end)
for _, num in ipairs(numbers) do
    print(num)
end
-- Output:
-- 1
-- 3
-- 5
```

---

### **lia.table.FilterCopy**

**Description:**  
Creates a copy of the table containing only elements that pass the callback function. This function does not modify the original table; instead, it returns a new table with the filtered elements.

**Realm:**  
`Shared`

**Parameters:**  

- `tab` (`table`):  
  The table to filter.

- `func` (`function`):  
  The function to call for each element; if it returns `true`, the element is added to the result.

**Returns:**  
`table` - A new table containing the filtered elements.

**Example Usage:**
```lua
local numbers = {1, 2, 3, 4, 5, 6}
-- Create a new table with only even numbers
local evenNumbers = lia.table.FilterCopy(numbers, function(n)
    return n % 2 == 0
end)
for _, num in ipairs(evenNumbers) do
    print(num)
end
-- Output:
-- 2
-- 4
-- 6
```

---

### **lia.table.Unique**

**Description:**  
Returns a table of unique values from the input table by converting it into an associative table and extracting the keys. This function ensures that all values in the resulting table are distinct.

**Realm:**  
`Shared`

**Parameters:**  

- `tab` (`table`):  
  The table to process.

**Returns:**  
`table` - The table of unique values.

**Example Usage:**
```lua
local items = {"sword", "shield", "sword", "potion", "shield"}
local uniqueItems = lia.table.Unique(items)
for _, item in ipairs(uniqueItems) do
    print(item)
end
-- Output:
-- sword
-- shield
-- potion
```

---