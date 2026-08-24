# Lilia Module Ownership and Placement Audit

Audit base: `03b20ced7f3bf8a17807a2c2e086fe566c73ccb1` (`main`, 2026-08-12)

Scope: `LiliaFramework/Lilia` only. The separate `LiliaFramework/Modules` repository, forks, schema repositories, addons, and external workshop content are excluded.

This report was created before any Lua file was changed on `module-audit-reorg-20260824`.

## Audit rules

Ownership and placement are separate questions.

- **Module-only** means the definition/registration is created for and consumed by one module scope. Calling shared Lilia APIs does not by itself make code shared.
- **Shared** means the same definition/behavior is consumed by multiple module scopes or is Lilia core/framework behavior. Shared code is not moved.
- **Ambiguous** means exclusive ownership, realm, sender/receiver direction, required load order, or lexical dependencies cannot be proven from this repository. Ambiguous code is not moved.
- Module entry/registration remains in `module.lua`.
- Module-owned `vgui.Register` definitions belong under the owning module's `derma` directory.
- Module-owned `net.Receive` definitions belong under `netcalls/server.lua` or `netcalls/client.lua` when their realm and dependencies are provable.
- Module-owned commands belong in `commands.lua` only when extraction preserves realm, lexical scope, and registration timing.
- Module-owned reusable libraries remain in the appropriate `libraries/server.lua`, `libraries/shared.lua`, or `libraries/client.lua`.
- Meta extensions belong under `meta` when they are actually module-owned meta definitions.
- Entity/SWEP lifecycle code remains with the entity/SWEP unless a networking/registration block is independently separable without changing behavior.

## Lilia loader facts used by the audit

`gamemode/core/libraries/modularity.lua` is the primary structural reference.

- `module.lua` is included before module extras.
- `MODULE.Dependencies` are loaded before normal module extras.
- `libraries` are loaded before `commands`, `netcalls`, `meta`, and `derma`.
- `pim.lua` is a recognized root-level module extra and is loaded server-side.
- `config.lua`, `commands.lua`, `networking.lua`, and `items.lua` are also recognized root-level extras with explicit realms.
- `submodules/*` are loaded as nested modules.
- `MODULE.NetworkStrings` are registered server-side after module extras are loaded.
- Functions assigned to `MODULE` are registered as hooks by the module loader after inclusion completes.

These rules make several apparent dashboard/scanner findings intentional load-order constructs rather than safe move candidates.

## Dashboard/scanner reference

A repository-wide search for `dashboard` at the audited SHA finds documentation only; no persisted module-placement dashboard implementation or saved dashboard report is present in this repository. No external dashboard data was consulted because the requested scope is the Lilia repository only.

The requested dashboard-style structural signatures were reproduced directly against the repository: `vgui.Register`, `net.Receive`, network send sites, `lia.command.add`, `concommand.Add`, meta definitions, module entries, explicit dependency files, root extras, and module folder placement.

Scanner limitations that matter here:

- `vgui.Create` is dynamic panel construction and does **not** establish ownership of a panel class. Only registrations/definitions prove a panel class placement issue.
- `lia.net.readBigTable` is a networking receive registration but is not found by a scanner that only searches `net.Receive`.
- `MODULE` methods become hooks through the Lilia loader, so absence of a literal `hook.Add` does not mean hook registration is missing.
- Root `pim.lua` is an explicit loader convention, not a misplaced library.
- `MODULE.Dependencies` such as GridInv/WeightInv implementation files intentionally load before normal libraries and must not be moved based on filename heuristics alone.
- Dynamic `net.Receive` closures can depend on request-local state and cannot be moved merely because a scanner reports `module.lua`.

## Module inventory

The audit covers 18 module scopes.

| Scope | Entry | Libraries | Netcalls | Derma | Other module-owned structure |
| --- | --- | --- | --- | --- | --- |
| `administration` | `gamemode/modules/administration/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua`, `server.lua` | none | `entities/weapons/lia_distance/*`, four nested submodules |
| `administration/adminstick` | `.../adminstick/module.lua` | `libraries/client.lua`, `server.lua` | none at audit base | none | `entities/weapons/lia_adminstick/*` |
| `administration/logs` | `.../logs/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua`, `server.lua` | none | none |
| `administration/tickets` | `.../tickets/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua`, `server.lua` | none | none |
| `administration/warnings` | `.../warnings/module.lua` | `libraries/server.lua` | `netcalls/client.lua`, `server.lua` | none | none |
| `attributes` | `gamemode/modules/attributes/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | none | none | none |
| `chatbox` | `gamemode/modules/chatbox/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua`, `server.lua` | none | none |
| `doors` | `gamemode/modules/doors/module.lua` | `libraries/client.lua`, `server.lua` | none | none | `entities/weapons/lia_keys/*` |
| `inventory` | `gamemode/modules/inventory/module.lua` | none | none | none | dynamically loads one inventory type as a module |
| `inventory/gridinv` | `.../types/gridinv/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/server.lua` | `derma/cl_grid_inventory.lua`, `cl_grid_inventory_item.lua`, `cl_grid_inventory_panel.lua` | `gridinv.lua` dependency, `config.lua`, items, nested Storage module |
| `inventory/gridinv/storage` | `.../storage/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua`, `server.lua`, `shared.lua` | none | `entities/entities/lia_storage/*` |
| `inventory/weightinv` | `.../types/weightinv/module.lua` | `libraries/client.lua`, `server.lua` | none | `derma/cl_list_inventory.lua`, `cl_list_inventory_panel.lua`, `cl_list_storage.lua` | `weightinv.lua` dependency, `config.lua`, items |
| `mainmenu` | `gamemode/modules/mainmenu/module.lua` | `libraries/server.lua` | `netcalls/client.lua`, `server.lua` | none | module entry also contains client/server module API methods |
| `protection` | `gamemode/modules/protection/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua` | none | none |
| `recognition` | `gamemode/modules/recognition/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua` | none | root `pim.lua` |
| `spawns` | `gamemode/modules/spawns/module.lua` | `libraries/client.lua`, `server.lua` | none | none | none |
| `teams` | `gamemode/modules/teams/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/server.lua` | none | root `pim.lua` |
| `vendor` | `gamemode/modules/vendor/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua`, `server.lua` | `derma/client.lua` | `entities/entities/lia_vendor/*` |

## Per-module ownership and placement findings

### Administration

**Entry:** `gamemode/modules/administration/module.lua` is correctly placed.

**Module-only network strings declared by the entry:** `liaAdminSetCharProperty`, `liaAllFlags`, `liaAllPks`, `liaAllPlayers`, `liaFeaturePositions`, `liaFeaturePositionsRequest`, `liaFullCharList`, `liaFullCharListPage`, `liaManagesitroomsAction`, `liaMapEntities`, `liaMapEntityAction`, `liaModifyCharacterFlags`, `liaNetProfilerLogs`, `liaNetProfilerSnapshot`, `liaOnlineStaffData`, `liaPksCount`, `liaRequestAllFlags`, `liaRequestFullCharList`, `liaRequestFullCharListPage`, `liaRequestMapEntities`, `liaRequestNetProfilerLogs`, `liaRequestNetProfilerSnapshot`, `liaRequestPksCount`, `liaRequestPlayers`, `liaRequestStaffCases`, `liaRequestStaffSummary`, `liaRequestToolPermissionTiers`, `liaRequestStaffCharacterConfiguration`, `liaSetFeaturePosition`, `liaSetStaffCharacterFlag`, `liaSetStaffCharacterPermission`, `liaSetToolPermissionTier`, `liaSetToolPermissionTiersBatch`, `liaResetStaffCharacterConfiguration`, `liaResetToolPermissionTiers`, `liaSpawnMenuGiveItem`, `liaSpawnMenuSpawnItem`, `liaStaffCasesSnapshot`, `liaStaffCharacterConfiguration`, `liaStaffSummary`, `liaToolPermissionTiers`.

**Receivers:** most literal receivers are already under `netcalls/client.lua` or `netcalls/server.lua`. `libraries/client.lua` also contains client networking UI consumers, including `net.Receive("liaNetProfilerSnapshot")` and multiple `lia.net.readBigTable(...)` handlers. The snapshot receiver is structurally misplaced, but it is embedded in the large administration UI/network consumer section adjacent to the profiler big-table handler. Extraction would change registration order and split a cohesive receive path; no safe extraction is applied in this pass.

**Commands:** `lia.command.add("sayall", ...)` is in `libraries/shared.lua`. It is module-specific, but the file is a large mixed shared registration file containing properties, position callbacks, and cross-module Spawn integration. Moving only the command changes its execution point from the shared library pass to the later commands pass. No in-repository requirement proves that timing change is safe, so it remains an intentional exception.

**Panels:** no Administration-owned `vgui.Register` definition was found outside nested Admin Stick. Dynamic `vgui.Create` calls are UI construction, not misplaced panel definitions.

**Libraries:** realm placement is otherwise correct. `libraries/shared.lua` contains integrations that call the Spawns module and therefore must not be treated as a file wholly owned by one isolated feature.

**Meta:** no confirmed module-owned meta definition.

### Administration / Admin Stick

**Entry:** `gamemode/modules/administration/submodules/adminstick/module.lua` is correctly placed.

**Module-only network strings:** `liaAdminStickRequestPlayerState`, `liaAdminStickPlayerState`.

**Server receiver:** `net.Receive("liaAdminStickRequestPlayerState", ...)` is in `libraries/server.lua`. Its two private helpers and receiver form a self-contained block. This is a valid placement defect and is safe to move to `netcalls/server.lua` while leaving `PostPlayerLoadout` in the library.

**Client receiver:** `net.Receive("liaAdminStickPlayerState", ...)` is in `libraries/client.lua`. It closes over `adminStickPlayerStates`, `AdminStickMenu`, and client UI state from the same large lexical scope. Moving the receiver alone is not safe.

**Panels:** `vgui.Register("liaAdminStickActionCollector", ...)` and `vgui.Register("liaAdminStickPanel", ...)` are in `libraries/client.lua`. This is a valid placement defect, but both registrations depend on a very large set of private helpers/state defined in the same client file. Moving only the panel blocks would break lexical scope; moving the whole file would incorrectly move non-panel module logic. Intentional mixed-file exception.

**Commands/meta:** no module-owned command or meta definition found.

### Administration / Logs

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaSendLogs`, `liaSendLogsCategories`, `liaSendLogsCategoriesRequest`, `liaSendLogsRequest`.

**Receivers:** client/server receivers are already under `netcalls/client.lua` and `netcalls/server.lua`.

**Libraries:** client/server log UI/storage behavior is correctly under realm libraries.

**Panels/commands/meta:** no misplaced module-owned registrations found.

### Administration / Tickets

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaActiveTickets`, `liaClearAllTicketFrames`, `liaRequestActiveTickets`, `liaRequestTicketsCount`, `liaTicketsCount`, `liaTicketSystem`, `liaTicketSystemClaim`, `liaTicketSystemClose`, `liaViewClaims`.

**Receivers:** literal receivers are under `netcalls/client.lua` and `netcalls/server.lua`.

**Command:** `lia.command.add("ticket", ...)` is in `libraries/server.lua`. The command calls private local `SendPopup`, which is also used by `MODULE:PlayerSay`; the same helper performs ticket sends, active-ticket mutation, and hook emission. Extracting the command without redesigning helper scope is unsafe. Intentional mixed-file exception.

**Related sends:** ticket broadcast/close sends remain in `libraries/server.lua` because they are embedded in ticket lifecycle hooks and the same private state. Moving calls alone would not create an independent networking unit.

**Panels/meta:** no module-owned `vgui.Register` or meta definition found.

### Administration / Warnings

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaAllWarnings`, `liaPlayerWarnings`, `liaRequestAllWarnings`, `liaRequestRemoveWarning`, `liaRequestWarningsCount`, `liaWarningsCount`.

**Receivers:** already separated under `netcalls/client.lua` and `netcalls/server.lua`.

**Libraries:** warning persistence/business logic is server-only and correctly placed.

**Panels/commands/meta:** no misplaced module-owned registrations found.

### Attributes

**Entry:** correctly placed in `module.lua`.

No module-owned network-string declaration, command registration, `vgui.Register`, or meta definition was found. Client/server/shared attribute libraries are correctly realm-separated.

### Chatbox

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaChatboxAddFilteredWord`, `liaChatboxRemoveFilteredWord`, `liaChatboxRequestFilteredWords`, `liaChatboxSyncFilteredWords`.

**Receivers:** already separated under `netcalls/client.lua` and `netcalls/server.lua`.

**Libraries:** chat parsing, UI helpers, filtering, and send helpers are realm-separated. Network sends embedded in chat business logic are left in place when no independent extraction can preserve the surrounding helper scope and order.

**Panels/commands/meta:** no misplaced module-owned registrations found.

### Doors

**Entry:** correctly placed in `module.lua`.

No module-owned network-string declaration, command registration, `vgui.Register`, or meta definition was found. Door libraries are correctly realm-separated. The `lia_keys` SWEP remains in its entity/SWEP folder; its interaction behavior is entity lifecycle code, not a standalone module netcall unit.

### Inventory

**Entry:** `gamemode/modules/inventory/module.lua` is correctly placed and intentionally loads the configured inventory type with `lia.module.load(...)`.

The parent contains no independent module-owned receivers, commands, panels, or meta definitions. Ownership of type-specific behavior belongs to the selected GridInv or WeightInv module scope, not the parent.

### Inventory / GridInv

**Entry:** correctly placed in `module.lua`.

**Module-only network string:** `liaRestoreOverflowItems`.

**Receiver:** restore-overflow handling is already under `netcalls/server.lua`.

**Panels:** all confirmed GridInv registrations are correctly under `derma`:

- `liaGridInventory` -> `derma/cl_grid_inventory.lua`
- `liaGridInventoryMenu` -> `derma/cl_grid_inventory.lua`
- `liaGridInvItem` -> `derma/cl_grid_inventory_item.lua`
- `liaGridInventoryPanel` -> `derma/cl_grid_inventory_panel.lua`

**Dependency/library exception:** `gridinv.lua` is explicitly declared as a shared `MODULE.Dependencies` file. It defines/registers the GridInv inventory class and intentionally loads before normal extras. Moving it under `libraries` would change required load order, so it remains at the type root.

**Related sends:** `liaTransferItem`/`liaInvAct` usage is shared/core inventory networking rather than a GridInv-exclusive message definition. Those calls are not re-owned or moved.

**Meta/commands:** no module-owned command or meta definition found.

### Inventory / GridInv / Storage

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaStorageExit`, `liaStorageSetPassword`, `liaStorageTransfer`, `liaStorageUnlock`, `liaTrunkInitStorage`.

**Receivers:** server/client handlers are under `netcalls/server.lua` and `netcalls/client.lua`. `netcalls/shared.lua` contains `net.Receive("liaTrunkInitStorage", ...)`, which calls the explicitly shared `InitializeStorage` hook. No sender for `liaTrunkInitStorage` exists elsewhere in the audited repository. Moving it to one realm would guess direction; duplicating it into both realm files would alter definition count/maintenance semantics. It remains an intentional realm exception.

**Libraries/entities:** realm-specific storage behavior and `lia_storage` entity lifecycle files remain in place.

**Panels/commands/meta:** no module-owned `vgui.Register`, command, or meta definition found.

### Inventory / WeightInv

**Entry:** correctly placed in `module.lua`.

No module-owned network-string declaration or command registration was found.

**Panels:** all confirmed WeightInv registrations are correctly under `derma`:

- `liaListInventory` -> `derma/cl_list_inventory.lua`
- `liaListInventoryPanel` -> `derma/cl_list_inventory_panel.lua`
- `liaListStorage` -> `derma/cl_list_storage.lua`

**Dependency/library exception:** `weightinv.lua` is explicitly declared as a shared `MODULE.Dependencies` file. Moving it under `libraries` would alter dependency load order, so it remains at the type root.

**Meta:** no confirmed module-owned meta definition.

### Main Menu

**Entry:** `gamemode/modules/mainmenu/module.lua` is correctly placed and intentionally contains module API/hook methods.

**Module-only network string:** `liaMainCharacterSet`.

Main Menu also uses shared/core character networking (`liaCharChoose`, `liaCharCreate`, `liaCharDelete`, `liaCharList`, and related character messages). Those names are not reclassified as Main Menu-owned solely because this module sends/receives them.

**Dynamic receiver exceptions:** `MODULE:ChooseCharacter` installs a `net.Receive("liaCharChoose", ...)` closure that captures request-local deferred `d` and character `id`; `MODULE:CreateCharacter` similarly installs `net.Receive("liaCharCreate", ...)` around request-local deferred state. Moving those closures to a static client netcall file would require new pending-request state/correlation and would change the module API implementation. They remain in `module.lua` as intentional mixed entry/network exceptions.

**Other receivers:** module-owned static main-character handling remains in the existing `netcalls/client.lua`/`server.lua` files.

**Panels:** `vgui.Create("liaCharacter")` is dynamic construction of a panel registered elsewhere; it is not a Main Menu `vgui.Register` definition and is a dashboard/scanner false positive if treated as one.

**Commands/meta:** no module-owned command or meta definition found.

### Protection

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaVerifyCheats`, `liaRequestEntityTabData`, `liaEntityTabData`.

**Server receiver:** `net.Receive("liaRequestEntityTabData", ...)` plus private `getEntityOwner` are a self-contained top block in `libraries/server.lua`. This is a valid placement defect and is safe to move to `netcalls/server.lua`.

**Client receiver:** anti-cheat/client networking already has `netcalls/client.lua`.

**Console command:** `concommand.Add("lia_backdoorcheck", ...)` and all of its implementation/helpers occupy the entirety of `libraries/shared.lua`. The file has no reusable Protection library API and search finds no external reference to the command implementation helpers. Moving the complete file to root `commands.lua` preserves its shared realm while putting command-only code in the command location. This is a safe placement fix.

**Panels/meta:** no module-owned `vgui.Register` or meta definition found.

### Recognition

**Entry:** correctly placed in `module.lua`.

**Module-only network string:** `liaRgnDone`.

**Receiver:** client completion handling is already under `netcalls/client.lua`.

**PIM:** root `pim.lua` is module-only recognition interaction registration and is correctly placed according to Lilia's special module loader. Its `liaRgnDone` send is part of the interaction execution closure and remains there.

**Libraries/panels/commands/meta:** libraries are realm-separated; no misplaced command, panel registration, or meta definition found.

### Spawns

**Entry:** correctly placed in `module.lua`.

No module-owned network-string declaration, command registration, `vgui.Register`, or meta definition was found. Client/server spawn libraries are correctly realm-separated. Administration invokes the Spawns module API for staff spawn-position tooling; that consumer relationship does not make Spawns library definitions Administration-owned.

### Teams

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaFactionMembers`, `liaFactionMemberDetails`, `liaKickCharacterToBase`, `liaRequestFactionMembers`, `liaRequestFactionMemberDetails`, `liaSaveFactionNote`.

**Receivers:** literal server receivers are under `netcalls/server.lua`.

**Command:** `lia.command.add("speed", ...)` is in `libraries/server.lua`. The command block itself is small, but it is interleaved in a very large server library between module hook/API definitions. Moving it to the later commands pass changes its registration point relative to the rest of the Teams library. No requirement in this repository proves that registration-order change is harmless, so it remains an intentional mixed-file/load-order exception rather than being moved speculatively.

**PIM:** root `pim.lua` is a recognized server-only loader extra and correctly contains Teams player-interaction registrations.

**Related sends:** `liaClassUpdate` and other core/shared team/class sends embedded in module hooks are not moved merely because they use `net.Start`; moving the call alone would split hook business logic and can re-own shared/core messages incorrectly.

**Panels/meta:** no module-owned `vgui.Register` or meta definition found.

### Vendor

**Entry:** correctly placed in `module.lua`.

**Module-only network strings:** `liaVendorAllowClass`, `liaVendorAllowFaction`, `liaVendorBuyPrice`, `liaVendorDeletePreset`, `liaVendorExit`, `liaVendorFaction`, `liaVendorFactionBuyScale`, `liaVendorFactionSellScale`, `liaVendorInitialSync`, `liaVendorLoadPreset`, `liaVendorMaxStock`, `liaVendorMode`, `liaVendorOpen`, `liaVendorRequestData`, `liaVendorSavePreset`, `liaVendorSellPrice`, `liaVendorStock`, `liaVendorSync`, `liaVendorSyncMessages`, `liaVendorTrade`.

**Receivers:** static client/server receivers are already under `netcalls/client.lua` and `netcalls/server.lua`.

**Panels:** all confirmed Vendor registrations are correctly under `derma/client.lua`:

- `liaVendor`
- `liaVendorItem`
- `liaVendorEditorItemRow`
- `liaVendorEditor`

Network sends inside Vendor panel/entity actions remain with those actions when moving the send alone would split entity/UI behavior from its lifecycle method. The actual static receive routing is already in `netcalls`.

**Commands/meta:** no module-owned command or meta definition found.

## Meta audit

Repository-wide `FindMetaTable`/meta-definition signatures do not identify a confirmed module-owned meta extension under `gamemode/modules`. Lilia core meta definitions under `gamemode/core/meta` are shared framework code and are intentionally untouched. A `FindMetaTable` occurrence inside the Storage entity client file is not, by itself, proof of a module-owned meta definition that can be moved.

## Confirmed placement defects

| Finding | Ownership | Safety | Action |
| --- | --- | --- | --- |
| Protection `lia_backdoorcheck` command implementation in `libraries/shared.lua` | Module-only | Safe: whole file is command implementation and can keep shared realm | Move whole file to `gamemode/modules/protection/commands.lua` |
| Protection `liaRequestEntityTabData` receiver/helper in `libraries/server.lua` | Module-only | Safe: self-contained top block | Move block to `gamemode/modules/protection/netcalls/server.lua` |
| Admin Stick `liaAdminStickRequestPlayerState` receiver/helpers in `libraries/server.lua` | Module-only | Safe: self-contained block, independent of `PostPlayerLoadout` | Move block to `.../adminstick/netcalls/server.lua` |
| Admin Stick client receiver in `libraries/client.lua` | Module-only | Unsafe: closes over private client state | Leave; document exception |
| Admin Stick `vgui.Register` definitions in `libraries/client.lua` | Module-only | Unsafe: extensive private lexical dependencies | Leave; document exception |
| Administration `liaNetProfilerSnapshot` receiver in `libraries/client.lua` | Module-only | Not proven safe: coupled to adjacent profiler UI/big-table handlers and current registration order | Leave; document exception |
| Administration `sayall` in `libraries/shared.lua` | Module-only registration inside mixed file | Not proven safe under required load-order preservation | Leave; document exception |
| Tickets `ticket` in `libraries/server.lua` | Module-only | Unsafe: closes over shared private `SendPopup` used by hooks | Leave; document exception |
| Teams `speed` in `libraries/server.lua` | Module-only | Not proven safe under required load-order preservation | Leave; document exception |
| Main Menu dynamic `liaCharChoose`/`liaCharCreate` receivers in `module.lua` | Uses shared/core character messages | Unsafe: request-local closure/deferred state | Leave; document exception |
| Storage `liaTrunkInitStorage` receiver in `netcalls/shared.lua` | Storage-only name | Realm/direction ambiguous in-repo | Leave; document exception |

## Shared code intentionally left unchanged

- All `gamemode/core/**` networking, meta, Derma, loader, item, character, and utility code.
- Core/shared character networking used by Main Menu (`liaCharChoose`, `liaCharCreate`, `liaCharDelete`, `liaCharList`, related character flow).
- Core/shared inventory networking used by GridInv/WeightInv (`liaTransferItem`, `liaInvAct`, and shared inventory APIs).
- Administration shared registration code that integrates with the Spawns module.
- Entity/SWEP lifecycle behavior whose networking calls are inseparable from entity methods without changing APIs/load behavior.
- Module hook methods on `MODULE`; Lilia registers these automatically and moving them based on `hook.Add` heuristics would change module API layout.

## Ambiguous code not moved

- Storage `liaTrunkInitStorage`: receiver is intentionally shared, `InitializeStorage` is documented shared, and no in-repo sender proves one-way realm ownership.
- Main Menu dynamic character request receivers: shared/core message ownership plus request-local deferred closures.
- Root `gridinv.lua` and `weightinv.lua`: explicit dependencies whose early load order is part of module initialization.
- Root `recognition/pim.lua` and `teams/pim.lua`: explicit Lilia special extras.
- Administration and Admin Stick large client files: network/UI definitions share local state with surrounding UI implementation.
- Ticket command/send code: one private helper is consumed by both the command and module hook path.

## Dashboard-style findings: valid issues

- `vgui.Register` outside `derma`: Admin Stick has two real registrations in `libraries/client.lua`.
- `net.Receive` outside `netcalls`: Admin Stick server/client, Protection server entity-tab receiver, Administration profiler snapshot receiver, and Main Menu dynamic request receivers are real signatures. Only the two self-contained server blocks are safe to move in this pass.
- Command registration outside `commands.lua`: Protection backdoor checker, Administration `sayall`, Tickets `ticket`, and Teams `speed` are real signatures. Only the whole-file Protection command is moved because the other mixed files do not satisfy the required load-order/scope proof.
- `netcalls/shared.lua`: Storage has a real realm-separation exception that cannot be resolved without guessing message direction.

## Dashboard/scanner false positives or incomplete signals

- Any warning based only on `vgui.Create` is a false positive for panel-definition placement. Dynamic construction does not define/register the panel.
- Root `pim.lua` findings are false positives; Lilia explicitly loads `pim.lua` server-side.
- Root GridInv/WeightInv implementation files are false positives if treated as ordinary misplaced libraries; they are explicit `MODULE.Dependencies` and require earlier loading.
- A scanner that only checks literal `net.Receive` misses `lia.net.readBigTable` receive registrations in Administration and elsewhere.
- A scanner that assumes every network name used in a module is owned by that module misclassifies core character/inventory messages used by Main Menu and inventory types.
- A scanner that treats every `MODULE:HookName` method as unregistered misses Lilia's automatic module-hook registration step.

## Mixed files intentionally left unchanged

- `gamemode/modules/administration/libraries/shared.lua`
- `gamemode/modules/administration/libraries/client.lua`
- `gamemode/modules/administration/submodules/adminstick/libraries/client.lua`
- `gamemode/modules/administration/submodules/tickets/libraries/server.lua`
- `gamemode/modules/teams/libraries/server.lua`
- `gamemode/modules/mainmenu/module.lua`
- `gamemode/modules/inventory/types/gridinv/submodules/storage/netcalls/shared.lua`

Each is left unchanged because safe extraction of the reported registration/handler cannot be proven while preserving lexical scope, realm, load order, shared ownership, or request state.

## Planned safe code changes after this audit commit

1. Move `gamemode/modules/protection/libraries/shared.lua` to `gamemode/modules/protection/commands.lua` without changing its contents.
2. Move `getEntityOwner` plus `net.Receive("liaRequestEntityTabData", ...)` from the top of `gamemode/modules/protection/libraries/server.lua` into new `gamemode/modules/protection/netcalls/server.lua`.
3. Move Admin Stick's `canManageAdminStickPlayer`, `buildAdminStickPlayerState`, and `net.Receive("liaAdminStickRequestPlayerState", ...)` from `.../adminstick/libraries/server.lua` into new `.../adminstick/netcalls/server.lua`.
4. Do not alter any shared or ambiguous files listed above.

## Verification requirements after code changes

The final pass must verify:

- no stale old-path references to `protection/libraries/shared.lua`;
- no duplicate `lia_backdoorcheck`, `liaRequestEntityTabData`, or `liaAdminStickRequestPlayerState` definitions;
- every moved file is discovered exactly once by Lilia's loader;
- command realm remains shared and both moved receivers remain server-only;
- `liaRequestEntityTabData` remains paired with `liaEntityTabData` output and `liaAdminStickRequestPlayerState` remains paired with `liaAdminStickPlayerState` output;
- all `vgui.Register` and command registration counts outside the intentionally documented exceptions remain unchanged;
- module hook names and public `MODULE` APIs remain unchanged;
- available Lua/static syntax checks are run where tooling permits;
- `git diff --check` or an equivalent whitespace/error check is run where tooling permits;
- final diff contains no changes to shared or ambiguous code other than this audit document.

## Files moved or modified

Pre-change state: only `MODULE_AUDIT.md` has been created. This section will be refreshed after the safe code changes and verification are complete.
