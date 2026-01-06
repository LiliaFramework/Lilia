# PermaProps Compatibility

Provides compatibility and control mechanisms for the PermaProps addon within the Lilia framework.

---

Overview

The PermaProps compatibility module controls the usage of the PermaProps addon, which allows props to persist across map changes. It implements restrictions on which entities can be made persistent and provides overlap detection.
The module operates on the server side to validate persistence attempts, preventing Lilia-specific entities and map-created objects from being made permanent without authorization.
It includes overlap detection and warning systems to prevent prop crowding and performance issues.
The module integrates with Lilia's permission system to control who can create persistent props and under what conditions.

---

