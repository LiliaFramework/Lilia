    --[[
    lia.data.set(key, value, global, ignoreMap)

      Description:
         Saves the provided value under the specified key to persistent storage.
         The data is written to a file whose path is constructed based on the folder, map, and flags.
         Also caches the value in lia.data.stored.

      Parameters:
         key (string) - The key under which the data is stored.
         value (any) - The value to store.
         global (boolean) - If true, uses a global path; otherwise, includes folder and map.
         ignoreMap (boolean) - If true, ignores the map directory.

    Returns:
        string - The path where the data was saved.

    Realm:
        Shared
    
    Example Usage:
        lia.data.set("spawn_pos", Vector(0, 0, 0))
   ]]

    --[[
    lia.data.delete(key, global, ignoreMap)

      Description:
         Deletes the stored data file corresponding to the specified key.
         Also removes the value from the cached storage.

      Parameters:
         key (string) - The key corresponding to the data to be deleted.
         global (boolean) - If true, uses a global path; otherwise, includes folder and map.
         ignoreMap (boolean) - If true, ignores the map directory.

    Returns:
        boolean - True if the file was deleted, false otherwise.

    Realm:
        Shared

    Example Usage:
        lia.data.delete("spawn_pos")
   ]]

--[[
    lia.data.get(key, default, global, ignoreMap, refresh)

   Description:
      Retrieves the stored data for the specified key.
      If refresh is not set and data exists in cache, returns the cached data.
      Otherwise, reads from the file, decodes, and caches the value.

   Parameters:
      key (string) - The key corresponding to the data.
      default (any) - The default value to return if no data is found.
      global (boolean) - If true, uses a global path; otherwise, includes folder and map.
      ignoreMap (boolean) - If true, ignores the map directory.
      refresh (boolean) - If true, forces reading from file instead of cache.

    Returns:
        any - The stored value, or the default if not found.

    Realm:
        Shared

    Example Usage:
        local pos = lia.data.get("spawn_pos", Vector(0, 0, 0))
]]
