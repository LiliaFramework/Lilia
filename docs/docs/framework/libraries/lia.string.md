# lia.string

---

## Various useful string-related functions.

The `lia.string` library provides a collection of utility functions for performing common string operations within the Lilia Framework. These functions facilitate tasks such as case conversion with special character handling, random string generation, string quoting, reversal, capitalization, number formatting, digit-to-string conversion, string cleaning, and introducing gibberish into strings. By utilizing these utilities, developers can streamline string manipulations and enhance the functionality of their schemas and plugins.

---

## Functions

### **lia.string.lower**

**Description:**  
Converts all uppercase letters in a string to lowercase, including special characters. This function ensures that UTF-8 text characters are handled correctly during the conversion.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to convert.

**Returns:**  
`string` - The string with all letters converted to lowercase.

**Example Usage:**
```lua
local originalStr = "HELLO WORLD!"
local lowerStr = lia.string.lower(originalStr)
print(lowerStr)
-- Output: "hello world!"
```

---

### **lia.string.upper**

**Description:**  
Converts all lowercase letters in a string to uppercase, including special characters. This function ensures that UTF-8 text characters are handled correctly during the conversion.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to convert.

**Returns:**  
`string` - The string with all letters converted to uppercase.

**Example Usage:**
```lua
local originalStr = "hello world!"
local upperStr = lia.string.upper(originalStr)
print(upperStr)
-- Output: "HELLO WORLD!"
```

---

### **lia.string.generateRandom**

**Description:**  
Generates a random string of a given length using uppercase letters, lowercase letters, and numbers. This function is useful for creating random identifiers, passwords, or tokens.

**Realm:**  
`Shared`

**Parameters:**  

- `length` (`number`, optional):  
  The length of the random string to generate. Defaults to `16` if not provided.

**Returns:**  
`string` - The generated random string.

**Example Usage:**
```lua
local randomStr = lia.string.generateRandom(12)
print(randomStr)
-- Output: e.g., "A1b2C3d4E5f6"
```

---

### **lia.string.quote**

**Description:**  
Safely quotes a string by escaping backslashes and double quotes, then wrapping the entire string in double quotes. This function ensures that the string is properly escaped, preventing potential syntax errors or injection vulnerabilities.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to quote.

**Returns:**  
`string` - The quoted and escaped string.

**Example Usage:**
```lua
local unsafeStr = 'He said, "Hello, World!"'
local safeStr = lia.string.quote(unsafeStr)
print(safeStr)
-- Output: "\"He said, \\\"Hello, World!\\\"\""
```

---

### **lia.string.reverse**

**Description:**  
Reverses the characters in a string, including special characters. This function ensures that UTF-8 text characters are handled correctly during the reversal process.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to reverse.

**Returns:**  
`string` - The reversed string.

**Example Usage:**
```lua
local originalStr = "Hello, World!"
local reversedStr = lia.string.reverse(originalStr)
print(reversedStr)
-- Output: "!dlroW ,olleH"
```

---

### **lia.string.FirstToUpper**

**Description:**  
Capitalizes the first letter of a string using `lia.string.upper`. This function ensures that the first character is converted to uppercase while leaving the rest of the string unchanged.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to capitalize.

**Returns:**  
`string` - The string with the first letter capitalized.

**Example Usage:**
```lua
local originalStr = "hello world"
local capitalizedStr = lia.string.FirstToUpper(originalStr)
print(capitalizedStr)
-- Output: "Hello world"
```

---

### **lia.string.CommaNumber**

**Description:**  
Formats a number with commas for thousands separation. This function enhances the readability of large numbers by inserting commas at appropriate intervals.

**Realm:**  
`Shared`

**Parameters:**  

- `amount` (`number`):  
  The number to format.

**Returns:**  
`string` - The formatted number with commas.

**Example Usage:**
```lua
local number = 1234567
local formattedNumber = lia.string.CommaNumber(number)
print(formattedNumber)
-- Output: "1,234,567"
```

---

### **lia.string.DigitToString**

**Description:**  
Converts a single digit to its English word representation. If the input is not a valid digit (0-9), the function returns "invalid".

**Realm:**  
`Shared`

**Parameters:**  

- `digit` (`number`):  
  The digit to convert.

**Returns:**  
`string` - The word representation of the digit, or "invalid" if not a digit.

**Example Usage:**
```lua
local word = lia.string.DigitToString(5)
print(word)
-- Output: "five"

local invalidWord = lia.string.DigitToString(12)
print(invalidWord)
-- Output: "invalid"
```

---

### **lia.string.Clean**

**Description:**  
Removes non-printable ASCII characters from a string. This function ensures that the string contains only printable characters, enhancing data integrity and preventing display issues.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to clean.

**Returns:**  
`string` - The cleaned string.

**Example Usage:**
```lua
local dirtyStr = "Hello\x00World\x1F!"
local cleanStr = lia.string.Clean(dirtyStr)
print(cleanStr)
-- Output: "HelloWorld!"
```

---

### **lia.string.Gibberish**

**Description:**  
Randomly introduces gibberish characters into a string based on a specified probability. This function can be used to obfuscate text or simulate corruption in strings.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`):  
  The string to modify.

- `prob` (`number`):  
  The probability (1-100) of introducing gibberish.

**Returns:**  
`string` - The modified string with possible gibberish.

**Example Usage:**
```lua
local originalStr = "Hello, World!"
local gibberishStr = lia.string.Gibberish(originalStr, 30)
print(gibberishStr)
-- Output: "He@l#o, Wo$rld!"
```

---