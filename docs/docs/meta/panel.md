# Panel Meta

This document describes the methods available on panel objects.

---

## Overview

These meta functions extend standard panel objects with convenience helpers used throughout Lilia.

---

### `liaListenForInventoryChanges(inventory)`

    Description:
        Subscribes this panel to updates for a specific inventory.

    Parameters:
        inventory (Inventory) – Inventory to watch for changes.

    Realm:
        Client

    Example Usage:
        panel:liaListenForInventoryChanges(player:getChar():getInv())

### `liaDeleteInventoryHooks(id)`

    Description:
        Removes inventory update hooks created by `liaListenForInventoryChanges`.

    Parameters:
        id (number) – ID of the inventory to stop listening to.

    Realm:
        Client

### `SetScaledPos(x, y)`

    Description:
        Positions the panel using screen scale units.

    Parameters:
        x (number) – Horizontal position using `ScreenScale`.
        y (number) – Vertical position using `ScreenScaleH`.

    Realm:
        Client

### `SetScaledSize(w, h)`

    Description:
        Sizes the panel using screen scale units.

    Parameters:
        w (number) – Width using `ScreenScale`.
        h (number) – Height using `ScreenScaleH`.

    Realm:
        Client
