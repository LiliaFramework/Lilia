# Lilia Module Ownership and Placement Audit

Audit base: `03b20ced7f3bf8a17807a2c2e086fe566c73ccb1` (`main`, 2026-08-12)

Audit branch: `module-audit-reorg-20260824`

Scope: `LiliaFramework/Lilia` only. `LiliaFramework/Modules`, forks, schemas, addons, workshop content, and other repositories were excluded.

The first version of this file was committed as `a8a2c092a1a6b066201619da93cd4ba03c272efb` before any Lua change. This final version records the applied moves and verification.

## Audit rules

Ownership and placement were evaluated separately.

- **Module-only:** created for and exclusively used by one module scope.
- **Shared:** used by multiple module scopes or owned by Lilia core/framework. Shared code remains unchanged.
- **Ambiguous:** exclusive ownership, direction, realm, load order, or dependency scope cannot be proven. Ambiguous code remains unchanged.
- Module-owned `vgui.Register` definitions belong in the owning module's `derma` directory.
- Module-owned static `net.Receive` handlers belong in `netcalls/server.lua` or `netcalls/client.lua` when realm and dependencies are provable.
- Module-owned command registrations belong in `commands.lua` when moving them preserves realm, scope, and registration behavior.
- Module-owned reusable libraries remain under `libraries/server.lua`, `libraries/shared.lua`, or `libraries/client.lua`.
- Module-owned meta extensions belong under `meta`.
- Module entry and registration code remains in `module.lua`.
- Entity/SWEP lifecycle code is not extracted merely because it performs a net send.
- A mixed file is split only when all moved lexical dependencies can be preserved exactly.

## Lilia loader behavior used as structural authority

`gamemode/core/libraries/modularity.lua` establishes the relevant load model:

- `module.lua` loads first.
- `MODULE.Dependencies` load before normal extras.
- `libraries` load before `commands`, `netcalls`, `meta`, and `derma`.
- Root `pim.lua` is an explicit server-only module extra.
- Root `config.lua`, `commands.lua`, `networking.lua`, and `items.lua` are explicit extras with defined realms.
- `submodules/*` load as nested modules.
- `MODULE.NetworkStrings` are registered server-side.
- Functions stored on `MODULE` are registered as hooks by the loader after inclusion.

Therefore root `pim.lua`, explicit inventory dependency files, and `MODULE` hook methods are not placement errors.

## Dashboard/scanner reference

A repository-wide search for `dashboard` at the audited SHA found documentation only; this repository contains no persisted module-placement dashboard implementation or saved dashboard report to execute. Because the requested scope is this repository only, no external dashboard data was imported.

The dashboard-style checks were reproduced directly from repository structure and signatures: `vgui.Register`, `vgui.Create`, `net.Receive`, `lia.net.readBigTable`, `net.Start`, `lia.command.add`, `concommand.Add`, meta definitions, module entries, explicit dependencies, root extras, and nested module folders.

Important scanner limitations:

- `vgui.Create` is dynamic construction, not panel registration. It is a false positive if reported as a misplaced panel definition.
- A scanner that only finds `net.Receive` misses `lia.net.readBigTable` receive registrations.
- `MODULE:HookName` methods are registered as hooks by Lilia even without literal `hook.Add`.
- Root `pim.lua` is intentionally loaded server-side.
- `gridinv.lua` and `weightinv.lua` are explicit `MODULE.Dependencies`; moving them to `libraries` would alter required load order.
- A net name used by a module is not necessarily owned by that module. Main Menu and inventory types use core/shared character and inventory messages.
- Dynamic request-local `net.Receive` closures cannot be converted to static netcall files without redesigning state/correlation.

## Complete module inventory

All 18 module scopes present at the audit base were analyzed.

| Scope | Entry | Libraries | Netcalls | Derma / special files |
| --- | --- | --- | --- | --- |
| `administration` | `gamemode/modules/administration/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua`, `server.lua` | `entities/weapons/lia_distance/*`; four submodules |
| `administration/adminstick` | `.../adminstick/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/server.lua` after this audit | `entities/weapons/lia_adminstick/*` |
| `administration/logs` | `.../logs/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua`, `server.lua` | none |
| `administration/tickets` | `.../tickets/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua`, `server.lua` | none |
| `administration/warnings` | `.../warnings/module.lua` | `libraries/server.lua` | `netcalls/client.lua`, `server.lua` | none |
| `attributes` | `gamemode/modules/attributes/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | none | none |
| `chatbox` | `gamemode/modules/chatbox/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua`, `server.lua` | none |
| `doors` | `gamemode/modules/doors/module.lua` | `libraries/client.lua`, `server.lua` | none | `entities/weapons/lia_keys/*` |
| `inventory` | `gamemode/modules/inventory/module.lua` | none | none | dynamically loads configured inventory type |
| `inventory/gridinv` | `.../types/gridinv/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/server.lua` | `derma/*`, `gridinv.lua`, `config.lua`, items, Storage submodule |
| `inventory/gridinv/storage` | `.../storage/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua`, `server.lua`, `shared.lua` | `entities/entities/lia_storage/*` |
| `inventory/weightinv` | `.../types/weightinv/module.lua` | `libraries/client.lua`, `server.lua` | none | `derma/*`, `weightinv.lua`, `config.lua`, items |
| `mainmenu` | `gamemode/modules/mainmenu/module.lua` | `libraries/server.lua` | `netcalls/client.lua`, `server.lua` | module entry also implements request-local API methods |
| `protection` | `gamemode/modules/protection/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua` | root `commands.lua` after this audit |
| `recognition` | `gamemode/modules/recognition/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/client.lua` | root `pim.lua` |
| `spawns` | `gamemode/modules/spawns/module.lua` | `libraries/client.lua`, `server.lua` | none | none |
| `teams` | `gamemode/modules/teams/module.lua` | `libraries/client.lua`, `server.lua`, `shared.lua` | `netcalls/server.lua` | root `pim.lua` |
| `vendor` | `gamemode/modules/vendor/module.lua` | `libraries/client.lua`, `server.lua` | `netcalls/client.lua`, `server.lua` | `derma/client.lua`, `entities/entities/lia_vendor/*` |

## Module-by-module findings

### Administration

Entry and realm-specific libraries/netcalls are structurally valid.

Module-only network strings declared by the entry:

`liaAdminSetCharProperty`, `liaAllFlags`, `liaAllPks`, `liaAllPlayers`, `liaFeaturePositions`, `liaFeaturePositionsRequest`, `liaFullCharList`, `liaFullCharListPage`, `liaManagesitroomsAction`, `liaMapEntities`, `liaMapEntityAction`, `liaModifyCharacterFlags`, `liaNetProfilerLogs`, `liaNetProfilerSnapshot`, `liaOnlineStaffData`, `liaPksCount`, `liaRequestAllFlags`, `liaRequestFullCharList`, `liaRequestFullCharListPage`, `liaRequestMapEntities`, `liaRequestNetProfilerLogs`, `liaRequestNetProfilerSnapshot`, `liaRequestPksCount`, `liaRequestPlayers`, `liaRequestStaffCases`, `liaRequestStaffSummary`, `liaRequestToolPermissionTiers`, `liaRequestStaffCharacterConfiguration`, `liaSetFeaturePosition`, `liaSetStaffCharacterFlag`, `liaSetStaffCharacterPermission`, `liaSetToolPermissionTier`, `liaSetToolPermissionTiersBatch`, `liaResetStaffCharacterConfiguration`, `liaResetToolPermissionTiers`, `liaSpawnMenuGiveItem`, `liaSpawnMenuSpawnItem`, `liaStaffCasesSnapshot`, `liaStaffCharacterConfiguration`, `liaStaffSummary`, `liaToolPermissionTiers`.

Static handlers are principally under `netcalls/client.lua` and `netcalls/server.lua`. `libraries/client.lua` also contains `net.Receive("liaNetProfilerSnapshot")` and adjacent `lia.net.readBigTable` consumers tied to the same profiler/admin UI state. This remains a mixed-file exception because safe extraction and unchanged registration order cannot be proven.

Module-only command registration: `sayall` is in `libraries/shared.lua`. The file also contains properties, position callbacks, and cross-module Spawns integration. Moving only the command would change its loader phase, so it is intentionally unchanged.

No Administration-owned `vgui.Register` definition was found outside the Admin Stick submodule. Dynamic panel creation is not a registration defect.

### Administration / Admin Stick

Entry: `module.lua`.

Module-only network strings: `liaAdminStickRequestPlayerState`, `liaAdminStickPlayerState`.

`liaAdminStickRequestPlayerState` and its two private helpers were moved from `libraries/server.lua` to `netcalls/server.lua`. The handler remains server-only and still replies with `liaAdminStickPlayerState`.

The client `liaAdminStickPlayerState` receiver remains in `libraries/client.lua` because it closes over `adminStickPlayerStates`, `AdminStickMenu`, and surrounding private UI state.

Module-only panels `liaAdminStickActionCollector` and `liaAdminStickPanel` remain in `libraries/client.lua`. This is a valid placement issue but unsafe to split: both depend on a large private lexical helper/state graph in that file. It is an intentional mixed-file exception.

No module-owned command or meta definition was found.

### Administration / Logs

Entry, client/server libraries, and client/server netcalls are correctly placed.

Module-only network strings: `liaSendLogs`, `liaSendLogsCategories`, `liaSendLogsCategoriesRequest`, `liaSendLogsRequest`.

Handlers are under the module's `netcalls/client.lua` and `netcalls/server.lua`. No misplaced module-only command, panel registration, or meta definition was found.

### Administration / Tickets

Entry, client/server libraries, and client/server netcalls are correctly placed.

Module-only network strings: `liaActiveTickets`, `liaClearAllTicketFrames`, `liaRequestActiveTickets`, `liaRequestTicketsCount`, `liaTicketsCount`, `liaTicketSystem`, `liaTicketSystemClaim`, `liaTicketSystemClose`, `liaViewClaims`.

Module-only command `ticket` remains in `libraries/server.lua` because it calls private local `SendPopup`, also used by `MODULE:PlayerSay` and ticket lifecycle state. Extracting it would require redesigning helper scope. Intentional mixed-file exception.

No module-owned `vgui.Register` or meta definition was found.

### Administration / Warnings

Entry and server library are correctly placed. Client/server handlers are already under `netcalls/client.lua` and `netcalls/server.lua`.

Module-only network strings: `liaAllWarnings`, `liaPlayerWarnings`, `liaRequestAllWarnings`, `liaRequestRemoveWarning`, `liaRequestWarningsCount`, `liaWarningsCount`.

No misplaced module-only command, panel registration, or meta definition was found.

### Attributes

Entry and `libraries/client.lua`, `server.lua`, `shared.lua` are correctly placed. No module-owned network-string declaration, command registration, panel registration, or meta definition was found.

### Chatbox

Entry and realm libraries/netcalls are correctly placed.

Module-only network strings: `liaChatboxAddFilteredWord`, `liaChatboxRemoveFilteredWord`, `liaChatboxRequestFilteredWords`, `liaChatboxSyncFilteredWords`.

Handlers are under `netcalls/client.lua` and `netcalls/server.lua`. Sends embedded in chat business logic remain with that logic when extracting the send alone would split its helper/hook behavior.

No misplaced module-only command, panel registration, or meta definition was found.

### Doors

Entry and client/server libraries are correctly placed. The `lia_keys` SWEP remains with SWEP lifecycle code. No module-owned network-string declaration, command registration, panel registration, or meta definition was found.

### Inventory

`module.lua` intentionally selects and loads one inventory type. The parent does not own the implementation details of GridInv or WeightInv and contains no independent misplaced receiver, command, panel registration, or meta definition.

### Inventory / GridInv

Entry: `module.lua`.

Module-only network string: `liaRestoreOverflowItems`; its server receiver is already in `netcalls/server.lua`.

Module-only panels are correctly under `derma`:

- `liaGridInventory` -> `derma/cl_grid_inventory.lua`
- `liaGridInventoryMenu` -> `derma/cl_grid_inventory.lua`
- `liaGridInvItem` -> `derma/cl_grid_inventory_item.lua`
- `liaGridInventoryPanel` -> `derma/cl_grid_inventory_panel.lua`

`gridinv.lua` is an explicit shared dependency, not a misplaced normal library. Core/shared inventory messages such as `liaTransferItem` and `liaInvAct` are not re-owned by GridInv.

No module-owned command or meta definition was found.

### Inventory / GridInv / Storage

Entry and realm libraries are correctly placed.

Module-only network strings: `liaStorageExit`, `liaStorageSetPassword`, `liaStorageTransfer`, `liaStorageUnlock`, `liaTrunkInitStorage`.

Normal client/server handlers are under `netcalls/client.lua` and `netcalls/server.lua`. `netcalls/shared.lua` contains `liaTrunkInitStorage`, which invokes the shared `InitializeStorage` hook. No sender in this repository proves one-way realm ownership. Moving it to one realm would guess direction; duplicating it would change registration count. It remains an intentional realm exception.

The `lia_storage` entity files remain entity lifecycle code. No module-owned command, `vgui.Register`, or meta definition was found.

### Inventory / WeightInv

Entry and client/server libraries are correctly placed.

Module-only panels are correctly under `derma`:

- `liaListInventory` -> `derma/cl_list_inventory.lua`
- `liaListInventoryPanel` -> `derma/cl_list_inventory_panel.lua`
- `liaListStorage` -> `derma/cl_list_storage.lua`

`weightinv.lua` is an explicit shared dependency and remains at the type root to preserve dependency load order.

No module-owned network-string declaration, command registration, or meta definition was found.

### Main Menu

Entry: `module.lua`; static module netcalls also exist under `netcalls/client.lua` and `netcalls/server.lua`.

Module-only network string: `liaMainCharacterSet`.

Main Menu also participates in core/shared character networking such as `liaCharChoose`, `liaCharCreate`, `liaCharDelete`, and `liaCharList`. Those names are not Main Menu-owned merely because this module uses them.

`MODULE:ChooseCharacter` and `MODULE:CreateCharacter` install request-local `liaCharChoose`/`liaCharCreate` receivers that capture deferred/request state. Moving them into static netcall files would require new pending-request state and correlation behavior. They remain intentional module-entry/network exceptions.

`vgui.Create("liaCharacter")` is dynamic construction of a panel registered elsewhere and is a scanner false positive if treated as a Main Menu panel definition.

No module-owned command or meta definition was found.

### Protection

Entry: `module.lua`.

Module-only network strings: `liaVerifyCheats`, `liaRequestEntityTabData`, `liaEntityTabData`.

`concommand.Add("lia_backdoorcheck", ...)` and its implementation occupied all of former `libraries/shared.lua`. The entire blob was moved unchanged to root `commands.lua`, preserving its shared realm and command name while fixing placement.

`net.Receive("liaRequestEntityTabData", ...)` and its private `getEntityOwner` helper form a module-only server block in `libraries/server.lua`, so the current location is a valid placement issue. The connected repository writer only supports whole-file replacement for that large mixed library; available reads are truncated. Reconstructing the unrelated server hooks would not satisfy exact-preservation requirements. The file is therefore intentionally unchanged in this pass and flagged as a preservation/tooling exception rather than rewritten speculatively.

Client anti-cheat/net handling already has `netcalls/client.lua`. No module-owned panel registration or meta definition was found.

### Recognition

Entry, realm libraries, and client netcall are correctly placed.

Module-only network string: `liaRgnDone`; the client handler is under `netcalls/client.lua`.

Root `pim.lua` contains Recognition-only player-interaction registration and associated `liaRgnDone` sends. It is an explicit server-only Lilia loader extra and remains unchanged.

No module-owned command, panel registration, or meta definition was found.

### Spawns

Entry and client/server libraries are correctly placed. No module-owned network-string declaration, command registration, panel registration, or meta definition was found.

Administration calls the Spawns module API for staff spawn-position tooling; that consumer relationship does not transfer ownership of the Spawns library.

### Teams

Entry, realm libraries, server netcalls, and root `pim.lua` are structurally recognized.

Module-only network strings: `liaFactionMembers`, `liaFactionMemberDetails`, `liaKickCharacterToBase`, `liaRequestFactionMembers`, `liaRequestFactionMemberDetails`, `liaSaveFactionNote`.

Static handlers are under `netcalls/server.lua`.

Module-only command `speed` remains in `libraries/server.lua`. It is interleaved in a large server library and moving it to the later command loader phase would alter registration timing; no repository evidence proves that timing change is harmless. Intentional mixed-file/load-order exception.

Net sends using core/shared team/class messages remain inside their owning hook/business logic instead of being moved based on `net.Start` alone.

No module-owned panel registration or meta definition was found.

### Vendor

Entry, realm libraries, and client/server netcalls are correctly placed.

Module-only network strings: `liaVendorAllowClass`, `liaVendorAllowFaction`, `liaVendorBuyPrice`, `liaVendorDeletePreset`, `liaVendorExit`, `liaVendorFaction`, `liaVendorFactionBuyScale`, `liaVendorFactionSellScale`, `liaVendorInitialSync`, `liaVendorLoadPreset`, `liaVendorMaxStock`, `liaVendorMode`, `liaVendorOpen`, `liaVendorRequestData`, `liaVendorSavePreset`, `liaVendorSellPrice`, `liaVendorStock`, `liaVendorSync`, `liaVendorSyncMessages`, `liaVendorTrade`.

Static handlers are under `netcalls/client.lua` and `netcalls/server.lua`.

Module-only panel registrations are correctly under `derma/client.lua`:

- `liaVendor`
- `liaVendorItem`
- `liaVendorEditorItemRow`
- `liaVendorEditor`

Net sends inside Vendor UI/entity methods remain with those lifecycle actions; moving a send alone is not a safe networking extraction.

No module-owned command or meta definition was found.

## Meta audit

No confirmed module-owned meta extension was found under `gamemode/modules`. Lilia core meta definitions under `gamemode/core/meta` are shared framework code and were intentionally untouched. A `FindMetaTable` use inside module/entity code is not sufficient evidence of a movable module meta definition.

## Valid placement findings

| Finding | Classification | Final action |
| --- | --- | --- |
| Protection command implementation in `libraries/shared.lua` | Module-only, safely separable as an entire file | Moved byte-identically to `protection/commands.lua` |
| Admin Stick `liaAdminStickRequestPlayerState` receiver/helpers in `libraries/server.lua` | Module-only, self-contained | Moved to `adminstick/netcalls/server.lua` |
| Protection `liaRequestEntityTabData` receiver/helper in `libraries/server.lua` | Module-only, semantically separable | Left unchanged because exact whole-file preservation cannot be guaranteed through the available repository writer |
| Admin Stick client state receiver in `libraries/client.lua` | Module-only | Left; private UI-state dependency |
| Admin Stick `vgui.Register` definitions in `libraries/client.lua` | Module-only | Left; extensive private lexical dependencies |
| Administration profiler snapshot receiver in `libraries/client.lua` | Module-only | Left; coupled to adjacent profiler receive/UI state and load ordering |
| Administration `sayall` in `libraries/shared.lua` | Module-only registration in mixed file | Left; loader-phase change not proven safe |
| Tickets `ticket` in `libraries/server.lua` | Module-only | Left; shares private `SendPopup` with hooks |
| Teams `speed` in `libraries/server.lua` | Module-only | Left; loader-phase change not proven safe |
| Main Menu dynamic character receivers in `module.lua` | Shared/core character-message use | Left; request-local deferred closure state |
| Storage `liaTrunkInitStorage` in `netcalls/shared.lua` | Storage-only name, realm ambiguous | Left; sender direction cannot be proven |

## Shared code intentionally left unchanged

- `gamemode/core/**`, including core networking, meta, Derma, loader, character, item, and utility code.
- Shared/core character messages used by Main Menu.
- Shared/core inventory messages and APIs used by GridInv/WeightInv.
- Administration code that integrates with Spawns.
- Entity/SWEP lifecycle methods whose networking calls are inseparable from the action lifecycle.
- All module hook APIs and public `MODULE` methods other than moving the independent Admin Stick net receiver helpers out of its library.

## Ambiguous code intentionally left unchanged

- Storage `liaTrunkInitStorage` realm/direction.
- Main Menu request-local character receive closures and core/shared message ownership.
- `gridinv.lua` and `weightinv.lua` explicit dependency files.
- Recognition/Teams root `pim.lua` special loader files.
- Large Administration/Admin Stick client mixed files with private UI state.
- Tickets command/helper mixed file.
- Teams command/library timing case.
- Protection server entity-tab extraction, because exact unrelated-file preservation cannot be guaranteed by the available writer.

## Dashboard findings and false positives

Valid dashboard-style findings were the misplaced Admin Stick panel registrations, misplaced static receivers listed above, command registrations outside `commands.lua`, and the Storage shared-netcall realm exception.

False positives/incomplete results include:

- treating `vgui.Create` as a panel registration;
- treating root `pim.lua` as a misplaced library;
- treating GridInv/WeightInv explicit dependencies as ordinary libraries;
- assuming every net name used by a module is owned by it;
- scanning only `net.Receive` and missing `lia.net.readBigTable`;
- treating `MODULE` methods as unregistered hooks because no literal `hook.Add` appears.

## Files moved or modified

- `MODULE_AUDIT.md`: created before Lua changes, then finalized after verification.
- `gamemode/modules/protection/libraries/shared.lua` -> `gamemode/modules/protection/commands.lua`: byte-identical rename; blob SHA remained `a3eaabfde6943de523b1514fe1e2b3ec2813d039`.
- `gamemode/modules/administration/submodules/adminstick/libraries/server.lua`: removed only the self-contained request receiver and its two private helpers; `MODULE:PostPlayerLoadout` remains.
- `gamemode/modules/administration/submodules/adminstick/netcalls/server.lua`: added the moved helpers and `liaAdminStickRequestPlayerState` receiver.

No shared or ambiguous Lua code was modified.

## Verification

- **Audit-first order:** PASS. Initial audit commit `a8a2c092a1a6b066201619da93cd4ba03c272efb` precedes both Lua commits.
- **Stale path:** PASS for the applied Protection move. `protection/libraries/shared.lua` no longer exists and `protection/commands.lua` resolves to the original blob.
- **Duplicate definitions:** PASS for applied changes. The old Protection file is deleted; Admin Stick's request receiver was removed from `libraries/server.lua` and exists in the new `netcalls/server.lua`.
- **Loaded exactly once:** PASS by loader structure. Root `commands.lua` is one recognized module extra; `netcalls/server.lua` is loaded once through the module netcalls directory.
- **Realm separation:** PASS. Protection command remains shared through root `commands.lua`; Admin Stick request receiver is now server-only by path/filename.
- **Net pairing:** PASS. `liaAdminStickRequestPlayerState` still reads the same target and replies with `liaAdminStickPlayerState`; declared network names were not changed.
- **Panel registration count:** PASS for the diff. No panel file or `vgui.Register` definition was modified.
- **Command registration count:** PASS for the applied Protection command. The same command blob was renamed with zero content changes and the old path was removed.
- **Hooks/module APIs:** PASS for the diff. `MODULE:PostPlayerLoadout` remains byte-for-byte in behavior and module entries/public APIs were not changed.
- **Lua/static syntax tools:** no Lua, LuaJIT, `luac`, `luacheck`, GLua linter, or StyLua executable is available in the provided runtime. The Protection command bytes are unchanged; the Admin Stick moved block was reviewed directly and its diff is a pure extraction.
- **`git diff --check`:** PASS on a local Git reconstruction of the exact applied rename/split.
- **Final diff scope:** PASS. Code diff from the audit commit consists only of the Protection rename and Admin Stick extraction; no unrelated/shared/ambiguous Lua file is changed.

## Result

The audit found multiple structurally imperfect placements, but only two were changed because they satisfied both exclusive ownership and preservation requirements. All other valid findings remain documented exceptions rather than speculative moves.
