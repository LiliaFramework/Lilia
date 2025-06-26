## Center

**Description:**
    Returns the midpoint between this vector and the supplied vector.

---

### Parameters

    * vec2 (Vector) – The vector to average with this vector.

---

### Returns

    * Vector – The center point of the two vectors.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local midpoint = Vector(0, 0, 0):Center(Vector(10, 10, 10))
    print(midpoint) -- Vector(5, 5, 5)
    ```

## Distance

**Description:**
    Calculates the distance between this vector and another vector.

---

### Parameters

    * vec2 (Vector) – The other vector.

---

### Returns

    * number – The distance between the two vectors.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local dist = Vector(0, 0, 0):Distance(Vector(3, 4, 0))
    print(dist) -- 5
    ```

## RotateAroundAxis

**Description:**
    Rotates the vector around an axis by the specified degrees and returns the new vector.

---

### Parameters

    * axis (Vector) – Axis to rotate around.
    * degrees (number) – Angle in degrees.

---

### Returns

    * Vector – The rotated vector.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local rotated = Vector(1, 0, 0):RotateAroundAxis(Vector(0, 0, 1), 90)
    print(rotated) -- Vector(0, 1, 0)
    ```

## Right

**Description:**
    Returns a normalized right-direction vector relative to this vector.

---

### Parameters

    * vUp (Vector, optional) – Up direction to compare against. Defaults to vector_up.

---

### Returns

    * Vector – The calculated right vector.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local rightVec = Vector(0, 1, 0):Right()
    print(rightVec)
    ```

## Up

**Description:**
    Returns a normalized up-direction vector relative to this vector.

---

### Parameters

    * vUp (Vector, optional) – Up direction to compare against. Defaults to vector_up.

---

### Returns

    * Vector – The calculated up vector.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local upVec = Vector(1, 0, 0):Up()
    print(upVec)
    ```

