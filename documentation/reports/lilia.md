## Executive Summary

### Function Documentation
- **Total Functions:** 643
- **Documented:** 0 (0.0%)
- **Missing Functions:** 643 unique (643 total occurrences)
  - **Library Functions:** 464
  - **Hook Functions:** 179
  - **Meta Functions:** 0

### Hooks Documentation
- **Missing Hooks:** 445 (used but undocumented)
- **Unused Hooks:** 0 (documented but unused)
- **Total Documented Hooks:** 0
- **Total Registered Hooks:** 445

### Localization Analysis
- **Undefined Calls:** 5 unique
- **@xxxxx Patterns:** 0 unique
- **Module Key Conflicts:** 0 keys
- **Argument Mismatches:** 1

### Net Message Analysis
- **Defined Net Messages:** 216
- **Used Net Messages:** 215
- **Defined But Unused:** 1
- **Used But Undefined:** 0

### Config Analysis
- **Undefined lia.config.get Keys:** 0

---

## Function Documentation Analysis

### Summary
- **Files Analyzed:** 42
- **Missing Documentation:** 643 unique functions

### Missing Library Functions
Total: 464 functions

#### lia
Count: 6 functions

- `lia.bootstrap(section, msg)`
- `lia.debug(...)`
- `lia.error(msg)`
- `lia.information(msg)`
- `lia.relaydiscordMessage(embed)`
- `lia.warning(msg)`

#### lia.admin
Count: 26 functions

- `lia.admin.addPermission(groupName, permission, silent)`
- `lia.admin.applyInheritance(groupName)`
- `lia.admin.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)`
- `lia.admin.createGroup(groupName, info)`
- `lia.admin.execCommand(cmd, victim, dur, reason)`
- `lia.admin.getCommandPrivilegeID(cmd)`
- `lia.admin.getDefaultUserGroup()`
- `lia.admin.getExternalPrivilegeName(id)`
- `lia.admin.hasAccess(ply, privilege)`
- `lia.admin.hasChanges()`
- `lia.admin.isProtectedStaffTarget(cmd, target)`
- `lia.admin.isValidGroup(groupName)`
- `lia.admin.load()`
- `lia.admin.normalizePrivilege(privilege)`
- `lia.admin.notifyAdmin(notification)`
- `lia.admin.notifyProtectedStaffTarget(admin)`
- `lia.admin.registerPrivilege(priv)`
- `lia.admin.removeGroup(groupName)`
- `lia.admin.removePermission(groupName, permission, silent)`
- `lia.admin.renameGroup(oldName, newName)`
- `lia.admin.save(noNetwork)`
- `lia.admin.serverExecCommand(cmd, victim, dur, reason, admin)`
- `lia.admin.setPlayerUsergroup(ply, newGroup, source)`
- `lia.admin.setSteamIDUsergroup(steamId, newGroup, source)`
- `lia.admin.sync(c)`
- `lia.admin.unregisterPrivilege(id)`

#### lia.attribs
Count: 3 functions

- `lia.attribs.loadFromDir(directory)`
- `lia.attribs.register(uniqueID, data)`
- `lia.attribs.setup(client)`

#### lia.bar
Count: 6 functions

- `lia.bar.add(getValue, color, priority, identifier)`
- `lia.bar.drawAction(text, duration)`
- `lia.bar.drawAll()`
- `lia.bar.drawBar(x, y, w, h, pos, max, color)`
- `lia.bar.get(identifier)`
- `lia.bar.remove(identifier)`

#### lia.char
Count: 22 functions

- `lia.char.addCharacter(id, character)`
- `lia.char.cleanUpForPlayer(client)`
- `lia.char.create(data, callback)`
- `lia.char.delete(id, client)`
- `lia.char.getAll()`
- `lia.char.getBySteamID(steamID)`
- `lia.char.getCharBanned(charID)`
- `lia.char.getCharData(charID, key)`
- `lia.char.getCharDataRaw(charID, key)`
- `lia.char.getCharacter(charID, client, callback)`
- `lia.char.getOwnerByID(ID)`
- `lia.char.getTeamColor(client)`
- `lia.char.hookVar(varName, hookName, func)`
- `lia.char.isLoaded(charID)`
- `lia.char.loadSingleCharacter(charID, client, callback)`
- `lia.char.new(data, id, client, steamID)`
- `lia.char.registerVar(key, data)`
- `lia.char.removeCharacter(id)`
- `lia.char.restore(client, callback, id)`
- `lia.char.setCharDatabase(charID, field, value)`
- `lia.char.unloadCharacter(charID)`
- `lia.char.unloadUnusedCharacters(client, activeCharID)`

#### lia.chat
Count: 4 functions

- `lia.chat.parse(client, message, noSend)`
- `lia.chat.register(chatType, data)`
- `lia.chat.send(speaker, chatType, text, anonymous, receivers)`
- `lia.chat.timestamp(ooc)`

#### lia.class
Count: 11 functions

- `lia.class.canBe(client, class)`
- `lia.class.get(identifier)`
- `lia.class.getBodygroups(class)`
- `lia.class.getMergedBodygroups(character)`
- `lia.class.getPlayerCount(class)`
- `lia.class.getPlayers(class)`
- `lia.class.hasWhitelist(class)`
- `lia.class.loadFromDir(directory)`
- `lia.class.register(uniqueID, data)`
- `lia.class.retrieveClass(class)`
- `lia.class.retrieveJoinable(client)`

#### lia.color
Count: 16 functions

- `lia.color.adjust(color, rOffset, gOffset, bOffset, aOffset)`
- `lia.color.applyTheme(themeName, useTransition)`
- `lia.color.calculateNegativeColor(mainColor)`
- `lia.color.darken(color, factor)`
- `lia.color.getAllThemes()`
- `lia.color.getCurrentTheme()`
- `lia.color.getCurrentThemeName()`
- `lia.color.getMainColor()`
- `lia.color.isColor(v)`
- `lia.color.isTransitionActive()`
- `lia.color.lerp(frac, col1, col2)`
- `lia.color.register(name, color)`
- `lia.color.registerTheme(name, themeData)`
- `lia.color.returnMainAdjustedColors()`
- `lia.color.startThemeTransition(name)`
- `lia.color.testThemeTransition(themeName)`

#### lia.command
Count: 9 functions

- `lia.command.add(command, data)`
- `lia.command.buildSyntaxFromArguments(args)`
- `lia.command.extractArgs(text)`
- `lia.command.hasAccess(client, command, data)`
- `lia.command.openArgumentPrompt(cmdKey, missing, prefix, definitions)`
- `lia.command.parse(client, text, realCommand, arguments)`
- `lia.command.run(client, command, arguments)`
- `lia.command.send(command, ...)`

#### lia.config
Count: 14 functions

- `lia.config.add(key, name, value, callback, data)`
- `lia.config.forceSet(key, value, noSave)`
- `lia.config.get(key, default)`
- `lia.config.getChangedValues(includeDefaults)`
- `lia.config.getDisplayCategory(key)`
- `lia.config.getDisplayDesc(key)`
- `lia.config.getDisplayName(key)`
- `lia.config.getOptions(key)`
- `lia.config.load()`
- `lia.config.reset()`
- `lia.config.save()`
- `lia.config.send(client)`
- `lia.config.set(key, value)`
- `lia.config.setDefault(key, value)`

#### lia.currency
Count: 2 functions

- `lia.currency.get(amount)`
- `lia.currency.spawn(pos, amount, angle)`

#### lia.darkrp
Count: 7 functions

- `lia.darkrp.createCategory()`
- `lia.darkrp.createEntity(name, data)`
- `lia.darkrp.findEmptyPos(startPos, entitiesToIgnore, maxDistance, searchStep, checkArea)`
- `lia.darkrp.formatMoney(amount)`
- `lia.darkrp.isEmpty(position, entitiesToIgnore)`
- `lia.darkrp.notify(client, notifyType, duration, message)`
- `lia.darkrp.textWrap(text, fontName, maxLineWidth)`

#### lia.data
Count: 16 functions

- `lia.data.addEquivalencyMap(map1, map2)`
- `lia.data.decode(value)`
- `lia.data.decodeAngle(raw)`
- `lia.data.decodeVector(raw)`
- `lia.data.delete(key, global, ignoreMap)`
- `lia.data.deserialize(raw)`
- `lia.data.encodetable(value)`
- `lia.data.get(key, default)`
- `lia.data.getEquivalencyMap(map)`
- `lia.data.getPersistence()`
- `lia.data.loadPersistence()`
- `lia.data.loadPersistenceData(callback)`
- `lia.data.loadTables()`
- `lia.data.savePersistence(entities)`
- `lia.data.serialize(value)`
- `lia.data.set(key, value, global, ignoreMap)`

#### lia.db
Count: 30 functions

- `lia.db.addDatabaseFields()`
- `lia.db.bulkInsert(dbTable, rows)`
- `lia.db.bulkUpsert(dbTable, rows)`
- `lia.db.connect(callback, reconnect)`
- `lia.db.convertDataType(value, noEscape)`
- `lia.db.count(dbTable, condition)`
- `lia.db.createColumn(tableName, columnName, columnType, defaultValue)`
- `lia.db.createSnapshot(tableName)`
- `lia.db.createTable(dbName, primaryKey, schema)`
- `lia.db.delete(dbTable, condition)`
- `lia.db.escapeIdentifier(id)`
- `lia.db.exists(dbTable, condition)`
- `lia.db.fieldExists(tbl, field)`
- `lia.db.getCharacterTable(callback)`
- `lia.db.getTables()`
- `lia.db.insertOrIgnore(value, dbTable)`
- `lia.db.insertTable(value, callback, dbTable)`
- `lia.db.loadSnapshot(fileName)`
- `lia.db.loadTables()`
- `lia.db.removeColumn(tableName, columnName)`
- `lia.db.removeTable(tableName)`
- `lia.db.select(fields, dbTable, condition, limit)`
- `lia.db.selectOne(fields, dbTable, condition)`
- `lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)`
- `lia.db.tableExists(tbl)`
- `lia.db.transaction(queries)`
- `lia.db.updateTable(value, callback, dbTable, condition)`
- `lia.db.upsert(value, dbTable)`
- `lia.db.waitForTablesToLoad()`
- `lia.db.wipeTables(callback)`

#### lia.derma
Count: 48 functions

- `lia.derma.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)`
- `lia.derma.approachExp(current, target, speed, dt)`
- `lia.derma.circle(x, y, r)`
- `lia.derma.clampMenuPosition(panel)`
- `lia.derma.createTableUI(title, columns, data, options, charID)`
- `lia.derma.dermaMenu()`
- `lia.derma.draw(radius, x, y, w, h, col, flags)`
- `lia.derma.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)`
- `lia.derma.drawBlur(panel, amount, passes, alpha)`
- `lia.derma.drawBlurAt(x, y, w, h, amount, passes, alpha)`
- `lia.derma.drawBoxWithText(text, x, y, options)`
- `lia.derma.drawCircle(x, y, radius, col, flags)`
- `lia.derma.drawCircleMaterial(x, y, radius, col, mat, flags)`
- `lia.derma.drawCircleOutlined(x, y, radius, col, thickness, flags)`
- `lia.derma.drawCircleTexture(x, y, radius, col, texture, flags)`
- `lia.derma.drawEntText(ent, text, posY, alphaOverride)`
- `lia.derma.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)`
- `lia.derma.drawMaterial(radius, x, y, w, h, col, mat, flags)`
- `lia.derma.drawOutlined(radius, x, y, w, h, col, thickness, flags)`
- `lia.derma.drawShadows(radius, x, y, w, h, col, spread, intensity, flags)`
- `lia.derma.drawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)`
- `lia.derma.drawShadowsOutlined(radius, x, y, w, h, col, thickness, spread, intensity, flags)`
- `lia.derma.drawSurfaceTexture(material, color, x, y, w, h)`
- `lia.derma.drawText(text, x, y, color, alignX, alignY, font, alpha)`
- `lia.derma.drawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)`
- `lia.derma.drawTexture(radius, x, y, w, h, col, texture, flags)`
- `lia.derma.drawTip(x, y, w, h, text, font, textCol, outlineCol)`
- `lia.derma.easeInOutCubic(t)`
- `lia.derma.easeOutCubic(t)`
- `lia.derma.interactionTooltip(rawOptions, config)`
- `lia.derma.openOptionsMenu(title, options)`
- `lia.derma.optionsMenu(rawOptions, config)`
- `lia.derma.radialMenu(options)`
- `lia.derma.rect(x, y, w, h)`
- `lia.derma.requestArguments(title, argTypes, onSubmit, defaults)`
- `lia.derma.requestBinaryQuestion(title, question, callback, yesText, noText)`
- `lia.derma.requestButtons(title, buttons, callback, description)`
- `lia.derma.requestColorPicker(func, colorStandard)`
- `lia.derma.requestDropdown(title, options, callback, defaultValue)`
- `lia.derma.requestOptions(title, subTitle, options, callback, onCancel)`
- `lia.derma.requestPlayerSelector(doClick)`
- `lia.derma.requestPopupQuestion(question, buttons)`
- `lia.derma.requestString(title, description, callback, defaultValue, maxLength)`
- `lia.derma.setDefaultShape(shape)`
- `lia.derma.setFlag(flags, flag, bool)`
- `lia.derma.shadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)`
- `lia.derma.skinFunc(name, panel, a, b, c, d, e, f, g)`
- `lia.derma.wrapText(text, width, font)`

#### lia.dialog
Count: 14 functions

- `lia.dialog.getAvailableConfigurations(ply, npc, npcID)`
- `lia.dialog.getConfiguration(uniqueID)`
- `lia.dialog.getNPCData(npcID)`
- `lia.dialog.getOriginalNPCData(npcID)`
- `lia.dialog.isTableEqual(tbl1, tbl2, checked)`
- `lia.dialog.openConfigurationPicker(npc, npcID)`
- `lia.dialog.openCustomizationUI(npc, configID)`
- `lia.dialog.openDialog(client, npc, npcID)`
- `lia.dialog.registerConfiguration(uniqueID, data)`
- `lia.dialog.registerNPC(uniqueID, data, shouldSync)`
- `lia.dialog.resolveDialogTypeIdentifier(value)`
- `lia.dialog.submitConfiguration(configID, npc, payload)`
- `lia.dialog.syncDialogs()`
- `lia.dialog.syncToClients(client)`

#### lia.doors
Count: 12 functions

- `lia.doors.addPreset(mapName, presetData)`
- `lia.doors.cleanupCorruptedData()`
- `lia.doors.getCachedData(door)`
- `lia.doors.getData(door)`
- `lia.doors.getDoorDefaultValues()`
- `lia.doors.getPreset(mapName)`
- `lia.doors.setCachedData(door, data)`
- `lia.doors.setData(door, data)`
- `lia.doors.syncAllDoorsToClient(client)`
- `lia.doors.syncDoorData(door)`
- `lia.doors.updateCachedData(doorID, data)`
- `lia.doors.verifyDatabaseSchema()`

#### lia.faction
Count: 29 functions

- `lia.faction.cacheModels(models)`
- `lia.faction.formatModelData()`
- `lia.faction.get(identifier)`
- `lia.faction.getAll()`
- `lia.faction.getAllowedBodygroups(faction, modelData, modelKey)`
- `lia.faction.getAllowedSkins(faction, modelData, modelKey)`
- `lia.faction.getBodygroupNameToIndex(modelPath)`
- `lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName, modelData, modelKey)`
- `lia.faction.getCategories(teamName)`
- `lia.faction.getCharacterCreationClass(faction, class)`
- `lia.faction.getCharacterCreationModelChoices(faction, class)`
- `lia.faction.getCharacterCreationModelInfo(faction, class, selectedModel)`
- `lia.faction.getCharacterCreationModelSource(faction, class)`
- `lia.faction.getClasses(faction)`
- `lia.faction.getDefaultAllowedSkinForFaction(faction, fallback, modelData, modelKey)`
- `lia.faction.getDefaultClass(id)`
- `lia.faction.getIndex(uniqueID)`
- `lia.faction.getModelCustomizationAllowed(client, faction, context)`
- `lia.faction.getModelData(modelKey, modelData)`
- `lia.faction.getModelsFromCategory(teamName, category)`
- `lia.faction.getPlayerCount(faction)`
- `lia.faction.getPlayers(faction)`
- `lia.faction.hasWhitelist(faction)`
- `lia.faction.isBodygroupValueAllowed(faction, modelPath, bodygroupIndex, value, bodygroupName, modelData, modelKey)`
- `lia.faction.isFactionCategory(faction, categoryFactions)`
- `lia.faction.isSkinAllowedForFaction(faction, skin, modelData, modelKey)`
- `lia.faction.jobGenerate(index, name, color, default, models)`
- `lia.faction.loadFromDir(directory)`
- `lia.faction.register(uniqueID, data)`

#### lia.flag
Count: 2 functions

- `lia.flag.add(flag, desc, callback)`
- `lia.flag.onSpawn(client)`

#### lia.font
Count: 5 functions

- `lia.font.getAvailableFonts()`
- `lia.font.getBoldFontName(fontName)`
- `lia.font.loadFonts()`
- `lia.font.register(fontName, fontData)`
- `lia.font.registerFonts(fontName)`

#### lia.inventory
Count: 17 functions

- `lia.inventory.checkOverflow(inv, character, oldW, oldH)`
- `lia.inventory.cleanUpForCharacter(character)`
- `lia.inventory.deleteByID(id)`
- `lia.inventory.getAllStorage(includeTrunks)`
- `lia.inventory.getAllTrunks()`
- `lia.inventory.getStorage(model)`
- `lia.inventory.getTrunk(vehicleClass)`
- `lia.inventory.instance(typeID, initialData)`
- `lia.inventory.loadAllFromCharID(charID)`
- `lia.inventory.loadByID(id, noCache)`
- `lia.inventory.loadFromDefaultStorage(id, noCache)`
- `lia.inventory.new(typeID)`
- `lia.inventory.newType(typeID, invTypeStruct)`
- `lia.inventory.registerStorage(model, data)`
- `lia.inventory.registerTrunk(vehicleClass, data)`
- `lia.inventory.show(inventory, parent)`
- `lia.inventory.showDual(inventory1, inventory2, parent)`

#### lia.item
Count: 30 functions

- `lia.item.addRarities(name, color)`
- `lia.item.addWeaponOverride(className, data)`
- `lia.item.addWeaponToBlacklist(className)`
- `lia.item.applyRuntimeOverridePath(wepTable, dotPath, value)`
- `lia.item.applyWeaponOverride(uniqueID)`
- `lia.item.createInv(w, h, id)`
- `lia.item.deleteByID(id)`
- `lia.item.get(identifier)`
- `lia.item.getInstancedItemByID(itemID)`
- `lia.item.getInv(invID)`
- `lia.item.getItemByID(itemID)`
- `lia.item.getItemDataByID(itemID)`
- `lia.item.getRuntimeValue(wepTable, dotPath)`
- `lia.item.instance(index, uniqueID, itemData, x, y, callback)`
- `lia.item.isItem(object)`
- `lia.item.load(path, baseID, isBaseItem)`
- `lia.item.loadFromDir(directory)`
- `lia.item.loadItemByID(itemIndex)`
- `lia.item.loadWeaponOverrides()`
- `lia.item.loadWeaponRuntimeOverrides()`
- `lia.item.localizeDefinition(itemDef)`
- `lia.item.new(uniqueID, id)`
- `lia.item.newInv(owner, invType, callback)`
- `lia.item.overrideItem(uniqueID, overrides)`
- `lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)`
- `lia.item.registerInv(invType, w, h)`
- `lia.item.registerItem(id, base, properties)`
- `lia.item.restoreInv(invID, w, h, callback)`
- `lia.item.setItemDataByID(itemID, key, value, receivers, noSave, noCheckEntity)`
- `lia.item.spawn(uniqueID, position, callback, angles, data)`

#### lia.keybind
Count: 8 functions

- `lia.keybind.add(k, d, desc, cb)`
- `lia.keybind.buildReservedKeys()`
- `lia.keybind.get(a, df)`
- `lia.keybind.getDisplayCategory(action)`
- `lia.keybind.getDisplayDescription(action)`
- `lia.keybind.isKeyReserved(keyCode)`
- `lia.keybind.load()`
- `lia.keybind.save()`

#### lia.lang
Count: 8 functions

- `lia.lang.addTable(name, tbl)`
- `lia.lang.cleanupCache()`
- `lia.lang.clearCache()`
- `lia.lang.generateCacheKey(lang, key, ...)`
- `lia.lang.getLanguages()`
- `lia.lang.getLocalizedString(key, ...)`
- `lia.lang.loadFromDir(directory)`
- `lia.lang.resolveToken(value, ...)`

#### lia.loader
Count: 6 functions

- `lia.loader.checkForUpdates()`
- `lia.loader.include(path, realm)`
- `lia.loader.includeDir(dir, raw, deep, realm)`
- `lia.loader.includeEntities(path)`
- `lia.loader.includeGroupedDir(dir, raw, recursive, forceRealm)`
- `lia.loader.initializeGamemode(isReload)`

#### lia.log
Count: 3 functions

- `lia.log.add(client, logType, ...)`
- `lia.log.addType(logType, func, category)`
- `lia.log.getString(client, logType, ...)`

#### lia.menu
Count: 4 functions

- `lia.menu.add(opts, pos, onRemove)`
- `lia.menu.drawAll()`
- `lia.menu.getActiveMenu()`
- `lia.menu.onButtonPressed(id, cb)`

#### lia.module
Count: 4 functions

- `lia.module.get(identifier)`
- `lia.module.initialize()`
- `lia.module.load(uniqueID, path, variable, skipSubmodules)`
- `lia.module.loadFromDir(directory, group, skip)`

#### lia.net
Count: 8 functions

- `lia.net.addToCache(name, args)`
- `lia.net.checkBadType(name, object)`
- `lia.net.getNetVar(key, default)`
- `lia.net.isCacheHit(name, args)`
- `lia.net.profiler.log(direction, messageName, size, sender, receiver)`
- `lia.net.readBigTable(netStr, callback)`
- `lia.net.setNetVar(key, value, receiver)`
- `lia.net.writeBigTable(targets, netStr, tbl, chunkSize)`

#### lia.notices
Count: 10 functions

- `lia.notices.notify(client, message, notifType)`
- `lia.notices.notifyAdminLocalized(client, key, ...)`
- `lia.notices.notifyErrorLocalized(client, key, ...)`
- `lia.notices.notifyInfoLocalized(client, key, ...)`
- `lia.notices.notifyLocalized(client, key, notifType, ...)`
- `lia.notices.notifyMoneyLocalized(client, key, ...)`
- `lia.notices.notifySuccessLocalized(client, key, ...)`
- `lia.notices.notifyWarningLocalized(client, key, ...)`
- `lia.notices.receiveNotify()`
- `lia.notices.receiveNotifyL()`

#### lia.option
Count: 9 functions

- `lia.option.add(key, name, desc, default, callback, data)`
- `lia.option.get(key, default)`
- `lia.option.getDisplayCategory(key)`
- `lia.option.getDisplayDesc(key)`
- `lia.option.getDisplayName(key)`
- `lia.option.getOptions(key)`
- `lia.option.load()`
- `lia.option.save()`
- `lia.option.set(key, value)`

#### lia.playerinteract
Count: 9 functions

- `lia.playerinteract.addAction(name, data)`
- `lia.playerinteract.addInteraction(name, data)`
- `lia.playerinteract.getActions(client)`
- `lia.playerinteract.getCategorizedOptions(options)`
- `lia.playerinteract.getInteractions(client)`
- `lia.playerinteract.hasChanges()`
- `lia.playerinteract.isWithinRange(client, entity, customRange)`
- `lia.playerinteract.openMenu(options, isInteraction, titleText, closeKey, netMsg, preFiltered)`
- `lia.playerinteract.sync(client)`

#### lia.time
Count: 5 functions

- `lia.time.formatDHM(seconds)`
- `lia.time.getDate()`
- `lia.time.getHour()`
- `lia.time.timeSince(strTime)`
- `lia.time.toNumber(str)`

#### lia.util
Count: 39 functions

- `lia.util.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)`
- `lia.util.applyBodygroups(target, bodygroups)`
- `lia.util.canFit(pos, mins, maxs, filter)`
- `lia.util.clampMenuPosition(panel)`
- `lia.util.createTableUI(title, columns, data, options, charID)`
- `lia.util.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)`
- `lia.util.drawBlur(panel, amount, passes, alpha)`
- `lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)`
- `lia.util.drawESPStyledText(text, x, y, espColor, font, fadeAlpha)`
- `lia.util.drawEntText(ent, text, posY, alphaOverride)`
- `lia.util.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)`
- `lia.util.drawLookText(text, posY, alphaOverride, maxDist)`
- `lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)`
- `lia.util.findFaction(client, name)`
- `lia.util.findPlayer(client, identifier)`
- `lia.util.findPlayerBySteamID(SteamID)`
- `lia.util.findPlayerBySteamID64(SteamID64)`
- `lia.util.findPlayerEntities(client, class)`
- `lia.util.findPlayerItems(client)`
- `lia.util.findPlayerItemsByClass(client, class)`
- `lia.util.findPlayersInBox(mins, maxs)`
- `lia.util.findPlayersInSphere(origin, radius)`
- `lia.util.formatStringNamed(format, ...)`
- `lia.util.generateRandomName(firstNames, lastNames)`
- `lia.util.getAdmins()`
- `lia.util.getBySteamID(steamID)`
- `lia.util.getMaterial(materialPath, materialParameters)`
- `lia.util.normalizeBodygroups(bodygroups)`
- `lia.util.openOptionsMenu(title, options)`
- `lia.util.playerInRadius(pos, dist)`
- `lia.util.removeFeaturePosition(pos, typeId)`
- `lia.util.requestEntityInformation(client, entity, argTypes, callback)`
- `lia.util.resolveBodygroupIndex(target, identifier)`
- `lia.util.resolveBodygroups(target, bodygroups)`
- `lia.util.sendTableUI(client, title, columns, data, options, characterID)`
- `lia.util.setFeaturePosition(pos, typeId)`
- `lia.util.setPositionCallback(name, data)`
- `lia.util.stringMatches(a, b)`
- `lia.util.wrapText(text, width, font)`

#### lia.vendor
Count: 6 functions

- `lia.vendor.addPreset(name, items)`
- `lia.vendor.getAllVendorData(entity)`
- `lia.vendor.getPreset(name)`
- `lia.vendor.getVendorProperty(entity, property)`
- `lia.vendor.setVendorProperty(entity, property, value)`
- `lia.vendor.syncVendorProperty(entity, property, value, isDefault)`

#### lia.webimage
Count: 5 functions

- `lia.webimage.clearCache(skipReRegister)`
- `lia.webimage.download(n, u, cb, flags)`
- `lia.webimage.get(n, flags)`
- `lia.webimage.getStats()`
- `lia.webimage.register(n, u, cb, flags)`

#### lia.websound
Count: 6 functions

- `lia.websound.clearCache(skipReRegister)`
- `lia.websound.download(name, url, cb)`
- `lia.websound.get(name)`
- `lia.websound.getStats()`
- `lia.websound.playButtonSound(customSound, callback)`
- `lia.websound.register(name, url, cb)`

#### lia.workshop
Count: 5 functions

- `lia.workshop.addWorkshop(id)`
- `lia.workshop.gather()`
- `lia.workshop.hasContentToDownload()`
- `lia.workshop.mountContent()`
- `lia.workshop.send(ply)`

### Missing Hook Functions
Total: 179 functions

- `characterMeta:addBoost(boostID, attribID, boostAmount)`
- `characterMeta:ban(time)`
- `characterMeta:clearAllBoosts()`
- `characterMeta:delete()`
- `characterMeta:destroy()`
- `characterMeta:doesFakeRecognize(id)`
- `characterMeta:doesRecognize(id)`
- `characterMeta:getAttrib(key, default)`
- `characterMeta:getData(key, default)`
- `characterMeta:getDisplayedName(client)`
- `characterMeta:getID()`
- `characterMeta:getPlayer()`
- `characterMeta:giveFlags(flags)`
- `characterMeta:giveMoney(amount)`
- `characterMeta:hasFlags(flagStr)`
- `characterMeta:hasMoney(amount)`
- `characterMeta:isBanned()`
- `characterMeta:isMainCharacter()`
- `characterMeta:joinClass(class, isForced)`
- `characterMeta:kick()`
- `characterMeta:kickClass()`
- `characterMeta:recognize(character, name)`
- `characterMeta:removeBoost(boostID, attribID)`
- `characterMeta:save(callback)`
- `characterMeta:setAttrib(key, value)`
- `characterMeta:setData(k, v, noReplication, receiver)`
- `characterMeta:setFlags(flags)`
- `characterMeta:setup(noNetworking)`
- `characterMeta:sync(receiver)`
- `characterMeta:takeFlags(flags)`
- `characterMeta:takeMoney(amount)`
- `characterMeta:updateAttrib(key, value)`
- `entityMeta:EmitSound(soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)`
- `entityMeta:checkDoorAccess(client, access)`
- `entityMeta:clearNetVars(receiver)`
- `entityMeta:getDoorOwner()`
- `entityMeta:getDoorPartner()`
- `entityMeta:getLocalVar(key, default)`
- `entityMeta:getNetVar(key, default)`
- `entityMeta:isDoor()`
- `entityMeta:isDoorLocked()`
- `entityMeta:isFemale()`
- `entityMeta:isItem()`
- `entityMeta:isLocked()`
- `entityMeta:isMoney()`
- `entityMeta:isProp()`
- `entityMeta:isSimfphysCar()`
- `entityMeta:keysLock()`
- `entityMeta:keysOwn(client)`
- `entityMeta:keysUnLock()`
- `entityMeta:playFollowingSound(soundPath, volume, shouldFollow, maxDistance, startDelay, minDistance, pitch, soundLevel, dsp)`
- `entityMeta:removeDoorAccessData()`
- `entityMeta:sendNetVar(key, receiver)`
- `entityMeta:setKeysNonOwnable(state)`
- `entityMeta:setLocalVar(key, value)`
- `entityMeta:setLocked(state)`
- `entityMeta:setNetVar(key, value, receiver)`
- `panelMeta:AvatarMask(mask)`
- `panelMeta:Background(col, rad, rtl, rtr, rbl, rbr)`
- `panelMeta:BarHover(col, height, speed)`
- `panelMeta:Blur(amount)`
- `panelMeta:Circle(col)`
- `panelMeta:CircleAvatar()`
- `panelMeta:CircleCheckbox(inner, outer, speed)`
- `panelMeta:CircleClick(col, speed, trad)`
- `panelMeta:CircleExpandHover(col, speed)`
- `panelMeta:CircleFadeHover(col, speed)`
- `panelMeta:CircleHover(col, speed, trad)`
- `panelMeta:ClearAppendOverwrite()`
- `panelMeta:ClearPaint()`
- `panelMeta:ClearTransitionFunc()`
- `panelMeta:DivTall(frac, target)`
- `panelMeta:DivWide(frac, target)`
- `panelMeta:DualText(toptext, topfont, topcol, bottomtext, bottomfont, bottomcol, alignment, centerSpacing)`
- `panelMeta:FadeHover(col, speed, rad)`
- `panelMeta:FadeIn(time, alpha)`
- `panelMeta:FillHover(col, dir, speed, mat)`
- `panelMeta:Gradient(col, dir, frac, op)`
- `panelMeta:HideVBar()`
- `panelMeta:LinedCorners(col, cornerLen)`
- `panelMeta:Material(mat, col)`
- `panelMeta:NetMessage(name, data)`
- `panelMeta:On(name, fn)`
- `panelMeta:Outline(col, width)`
- `panelMeta:ReadyTextbox()`
- `panelMeta:SetAppendOverwrite(fn)`
- `panelMeta:SetOpenURL(url)`
- `panelMeta:SetRemove(target)`
- `panelMeta:SetTransitionFunc(fn)`
- `panelMeta:SetupTransition(name, speed, fn)`
- `panelMeta:SideBlock(col, size, side)`
- `panelMeta:SquareCheckbox(inner, outer, speed)`
- `panelMeta:SquareFromHeight()`
- `panelMeta:SquareFromWidth()`
- `panelMeta:Stick(dock, margin, dontInvalidate)`
- `panelMeta:Text(text, font, col, alignment, ox, oy, paint)`
- `panelMeta:TiledMaterial(mat, tw, th, col)`
- `panelMeta:liaDeleteInventoryHooks(id)`
- `panelMeta:liaListenForInventoryChanges(inventory)`
- `panelMeta:setScaledPos(x, y)`
- `panelMeta:setScaledSize(w, h)`
- `playerMeta:Name()`
- `playerMeta:addMoney(amount)`
- `playerMeta:addPart(partID)`
- `playerMeta:banPlayer(reason, duration, banner)`
- `playerMeta:canAfford(amount)`
- `playerMeta:canEditVendor(vendor)`
- `playerMeta:consumeStamina(amount)`
- `playerMeta:createRagdoll(freeze)`
- `playerMeta:doGesture(a, b, c)`
- `playerMeta:doStaredAction(entity, callback, time, onCancel, distance)`
- `playerMeta:getAllLiliaData()`
- `playerMeta:getChar()`
- `playerMeta:getClassData()`
- `playerMeta:getDarkRPVar(var)`
- `playerMeta:getFlags()`
- `playerMeta:getItemDropPos()`
- `playerMeta:getItemWeapon()`
- `playerMeta:getItems()`
- `playerMeta:getLiliaData(key, default)`
- `playerMeta:getLocalVar(key, default)`
- `playerMeta:getMainCharacter()`
- `playerMeta:getMoney()`
- `playerMeta:getParts()`
- `playerMeta:getPlayTime()`
- `playerMeta:getRagdoll()`
- `playerMeta:getTracedEntity(distance)`
- `playerMeta:giveFlags(flags)`
- `playerMeta:hasFlags(flags)`
- `playerMeta:hasPrivilege(privilegeName)`
- `playerMeta:hasSkillLevel(skill, level)`
- `playerMeta:hasWhitelist(faction)`
- `playerMeta:isFamilySharedAccount()`
- `playerMeta:isStaff()`
- `playerMeta:isStaffOnDuty()`
- `playerMeta:isStuck()`
- `playerMeta:loadLiliaData(callback)`
- `playerMeta:meetsRequiredSkills(requiredSkillLevels)`
- `playerMeta:networkAnimation(active, boneData)`
- `playerMeta:notify(message, notifType)`
- `playerMeta:notifyAdmin(message)`
- `playerMeta:notifyAdminLocalized(key, ...)`
- `playerMeta:notifyError(message)`
- `playerMeta:notifyErrorLocalized(key, ...)`
- `playerMeta:notifyInfo(message)`
- `playerMeta:notifyInfoLocalized(key, ...)`
- `playerMeta:notifyLocalized(message, notifType, ...)`
- `playerMeta:notifyMoney(message)`
- `playerMeta:notifyMoneyLocalized(key, ...)`
- `playerMeta:notifySuccess(message)`
- `playerMeta:notifySuccessLocalized(key, ...)`
- `playerMeta:notifyWarning(message)`
- `playerMeta:notifyWarningLocalized(key, ...)`
- `playerMeta:playTimeGreaterThan(time)`
- `playerMeta:removePart(partID)`
- `playerMeta:removeRagdoll()`
- `playerMeta:requestArguments(title, argTypes, callback)`
- `playerMeta:requestBinaryQuestion(question, option1, option2, manualDismiss, callback)`
- `playerMeta:requestButtons(title, buttons)`
- `playerMeta:requestDropdown(title, subTitle, options, callback)`
- `playerMeta:requestOptions(title, subTitle, options, limit, callback, onCancel)`
- `playerMeta:requestPopupQuestion(question, buttons)`
- `playerMeta:requestString(title, subTitle, callback, default)`
- `playerMeta:resetParts()`
- `playerMeta:restoreStamina(amount)`
- `playerMeta:saveLiliaData()`
- `playerMeta:setAction(text, time, callback)`
- `playerMeta:setLiliaData(key, value, noNetworking, noSave)`
- `playerMeta:setLocalVar(key, value)`
- `playerMeta:setMainCharacter(charID)`
- `playerMeta:setNetVar(key, value)`
- `playerMeta:setRagdolled(state, time, getUpGrace)`
- `playerMeta:setWaypoint(name, vector, logo, onReach)`
- `playerMeta:stopAction()`
- `playerMeta:syncParts()`
- `playerMeta:syncVars()`
- `playerMeta:takeFlags(flags)`
- `playerMeta:takeMoney(amount)`
- `playerMeta:tostring()`

## Hooks Documentation Analysis

### Summary
- **Missing Hooks:** 445 (used in code but not documented)
- **Documented Hooks:** 0
- **Registered Hooks:** 445
- **Unused Hooks:** 0 (documented but not registered)

### Missing Hook Documentation:
These hooks are registered in code but missing from documentation:
- `AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)`
- `AddReservedKeybinds(reserved)`
- `AddSection(sectionName, color, priority, location)`
- `AddTextField(sectionName, fieldName, labelText, valueFunc)`
- `AddToAdminStickHUD(client, target, information)`
- `AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)`
- `AdjustCreationData(client, data, newData, originalData)`
- `AdjustPACPartData(wearer, id, data)`
- `AdjustStaminaOffset(client, offset)`
- `AdminPrivilegesUpdated()`
- `AdminStickAddModels(allModList, tgt)`
- `AdvDupe_FinishPasting(tbl)`
- `AttachPart(client, id)`
- `BagInventoryReady(self, inventory)`
- `BagInventoryRemoved(self, inv)`
- `CanCharBeTransfered(tChar, faction, arg3)`
- `CanDeleteChar(client, character)`
- `CanDisplayCharInfo(name)`
- `CanDrawEntityHoverInfo(e, category)`
- `CanInviteToClass(client, target)`
- `CanInviteToFaction(client, target)`
- `CanItemBeTransfered(item, inventory, VendorInventoryMeasure, client)`
- `CanOpenBagPanel(item)`
- `CanOutfitChangeModel(self)`
- `CanPerformVendorEdit(self, vendor)`
- `CanPersistEntity(entity)`
- `CanPickupMoney(activator, self)`
- `CanPlayerAccessDoor(client, self, access)`
- `CanPlayerAccessVendor(client, vendor)`
- `CanPlayerChooseWeapon(weapon)`
- `CanPlayerCreateChar(client, data)`
- `CanPlayerDropItem(client, item)`
- `CanPlayerEarnSalary(client)`
- `CanPlayerEquipItem(client, item)`
- `CanPlayerHoldObject(client, entity)`
- `CanPlayerInteractItem(client, action, self, data)`
- `CanPlayerJoinClass(client, class, info)`
- `CanPlayerKnock(arg1)`
- `CanPlayerLock(client, door)`
- `CanPlayerModifyConfig(client, key)`
- `CanPlayerOpenScoreboard(arg1)`
- `CanPlayerRespawn(client, timePassed, baseTime, lastDeath)`
- `CanPlayerRotateItem(client, item)`
- `CanPlayerSeeLog(client)`
- `CanPlayerSeeLogCategory(client, category)`
- `CanPlayerSpawnStorage(client, entity, info)`
- `CanPlayerSwitchChar(client, currentCharacter, newCharacter)`
- `CanPlayerTakeItem(client, item)`
- `CanPlayerThrowPunch(client)`
- `CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)`
- `CanPlayerUnequipItem(client, item)`
- `CanPlayerUnlock(client, door)`
- `CanPlayerUseAmmoBox(activator, self)`
- `CanPlayerUseChar(client, character)`
- `CanPlayerUseCommand(client, command)`
- `CanPlayerUseDoor(client, door)`
- `CanPlayerViewInventory()`
- `CanRunItemAction(tempItem, key)`
- `CanSaveData(ent, inventory)`
- `CanTakeEntity(client, targetEntity, itemUniqueID)`
- `CharCleanUp(character)`
- `CharDeleted(client, character)`
- `CharForceRecognized(ply, range)`
- `CharHasFlags(self, flags)`
- `CharListColumns(columns)`
- `CharListEntry(entry, row)`
- `CharListExtraDetails(client, entry, stored)`
- `CharListLoaded(newCharList)`
- `CharListUpdated(oldCharList, newCharList)`
- `CharLoaded(character)`
- `CharMenuClosed()`
- `CharMenuOpened(self)`
- `CharPostSave(self)`
- `CharPreSave(character)`
- `CharRestored(character)`
- `ChatAddText(text, ...)`
- `ChatParsed(client, chatType, message, anonymous)`
- `ChatboxPanelCreated(arg1)`
- `ChatboxTextAdded(arg1)`
- `CheckFactionLimitReached(faction, character, client)`
- `ChooseCharacter(id)`
- `CollectDoorDataFields(extras)`
- `CommandAdded(command, data)`
- `CommandRan(client, command, arg3, results)`
- `ConfigChanged(key, value, oldValue, client)`
- `ConfigureCharacterCreationSteps(self)`
- `CreateCharacter(data)`
- `CreateChatboxPanel()`
- `CreateDefaultInventory(character)`
- `CreateInformationButtons(pages)`
- `CreateInventoryPanel(inventory, parent)`
- `CreateLogsUI(panel, categories)`
- `CreateMenuButtons(tabs)`
- `CreateSalaryTimers()`
- `CreateTicketFrame(requester, message, claimed)`
- `DatabaseConnected()`
- `DeleteCharacter(id)`
- `DermaSkinChanged(newSkin)`
- `DiscordRelaySend(embed)`
- `DiscordRelayUnavailable()`
- `DiscordRelayed(embed)`
- `DisplayPlayerHUDInformation(client, hudInfos)`
- `DoModuleIncludes(path, MODULE)`
- `DoorDataReceived(door, syncData)`
- `DoorEnabledToggled(client, door, newState)`
- `DoorHiddenToggled(client, entity, newState)`
- `DoorLockToggled(client, door, state)`
- `DoorOwnableToggled(client, door, newState)`
- `DoorPriceSet(client, door, price)`
- `DoorTitleSet(client, door, name)`
- `DrawCharInfo(client, character, info)`
- `DrawEntityInfo(e, a, pos)`
- `DrawItemEntityInfo(self, item, infoTable, alpha)`
- `DrawLiliaModelView(client, entity)`
- `DrawPlayerInfoBackground(e, panelX, panelY, panelWidth, panelHeight, a)`
- `DrawPlayerRagdoll(entity)`
- `F1MenuClosed()`
- `F1MenuOpened(self)`
- `FetchSpawns()`
- `FilterCharModels(arg1)`
- `FilterDoorInfo(entity, doorData, doorInfo)`
- `ForceRecognizeRange(ply, range, fakeName)`
- `GetAdjustedPartData(wearer, id)`
- `GetAdminESPTarget(ent, client)`
- `GetAdminStickLists(tgt, lists)`
- `GetAllCaseClaims()`
- `GetAttributeMax(client, id)`
- `GetAttributeStartingMax(client, attribute)`
- `GetBotModel(client, faction)`
- `GetCharMaxStamina(char)`
- `GetCharacterCreateButtonTooltip(client, currentChars, maxChars)`
- `GetCharacterCreationSummary(arg1)`
- `GetCharacterDisconnectButtonTooltip(client)`
- `GetCharacterDiscordButtonTooltip(client, discordURL)`
- `GetCharacterLoadButtonTooltip(client)`
- `GetCharacterLoadMainButtonTooltip(client)`
- `GetCharacterMountButtonTooltip(client)`
- `GetCharacterReturnButtonTooltip(client)`
- `GetCharacterStaffButtonTooltip(client, hasStaffChar)`
- `GetCharacterWorkshopButtonTooltip(client, workshopURL)`
- `GetDamageScale(hitgroup, dmgInfo, damageScale)`
- `GetDefaultCharDesc(client, arg2, data)`
- `GetDefaultCharName(client, faction, data)`
- `GetDefaultInventorySize(client, char)`
- `GetDefaultInventoryType(character)`
- `GetDisplayedDescription(client, isHUD)`
- `GetDisplayedName(speaker, chatType)`
- `GetDoorInfo(entity, doorData, doorInfo)`
- `GetDoorInfoForAdminStick(target, extraInfo)`
- `GetEntitySaveData(ent)`
- `GetHandsAttackSpeed(arg1)`
- `GetInjuredText(c)`
- `GetInventoryMaxWeight(self, maxWeight)`
- `GetItemDropModel(itemTable, self)`
- `GetMainCharacterID()`
- `GetMainMenuPosition(character)`
- `GetMaxPlayerChar(client)`
- `GetMaxStartingAttributePoints(client, default)`
- `GetModelGender(model)`
- `GetMoneyModel(arg1)`
- `GetNPCDialogOptions(arg1)`
- `GetOOCDelay(speaker)`
- `GetPlayTime(self)`
- `GetPlayerDeathSound(client, isFemale)`
- `GetPlayerPainSound(client, paintype, isFemale)`
- `GetPlayerPunchDamage(arg1)`
- `GetPlayerPunchRagdollTime(arg1)`
- `GetPlayerRespawnLocation(client, character)`
- `GetPlayerSpawnLocation(client, character)`
- `GetPrestigePayBonus(client, char, pay, charFaction, class)`
- `GetPriceOverride(client, self, uniqueID, price, isSellingToVendor)`
- `GetRagdollTime(self, time)`
- `GetSalaryAmount(client, charFaction, class)`
- `GetWarnings(charID)`
- `GetWeaponName(wep)`
- `HandleItemTransferRequest(client, itemID, x, y, invID)`
- `InitializeStorage(entity)`
- `InitializedConfig()`
- `InitializedItems()`
- `InitializedKeybinds()`
- `InitializedModules()`
- `InitializedOptions()`
- `InitializedSchema()`
- `InteractionMenuClosed()`
- `InteractionMenuOpened(frame)`
- `InterceptClickItemIcon(self, itemIcon, keyCode)`
- `InventoryClosed(self, inventory)`
- `InventoryDataChanged(instance, key, oldValue, value)`
- `InventoryDeleted(instance)`
- `InventoryInitialized(instance)`
- `InventoryItemAdded(inventory, item)`
- `InventoryItemIconCreated(icon, item, self)`
- `InventoryItemRemoved(self, instance, preserveItem)`
- `InventoryOpened(panel, inventory)`
- `InventoryPanelCreated(panel, inventory, parent)`
- `IsCharFakeRecognized(character, id)`
- `IsCharRecognized(a, arg2)`
- `IsCharacterCreationOverridden()`
- `IsRecognizedChatType(chatType)`
- `IsSuitableForTrunk(ent)`
- `ItemCombine(client, item, target)`
- `ItemDataChanged(item, key, oldValue, newValue)`
- `ItemDefaultFunctions(arg1)`
- `ItemDeleted(instance)`
- `ItemDraggedOutOfInventory(client, item)`
- `ItemFunctionCalled(self, method, client, entity, results)`
- `ItemInitialized(item)`
- `ItemPaintOver(self, itemTable, w, h)`
- `ItemQuantityChanged(item, oldValue, quantity)`
- `ItemShowEntityMenu(entity)`
- `ItemTransfered(context)`
- `KeyLock(client, door, time)`
- `KeyUnlock(client, door, time)`
- `KickedFromChar(characterID, isCurrentChar)`
- `LiliaLoaded()`
- `LiliaModelPanelPostDrawModel(self, ent)`
- `LiliaNoticeOverride(msg, ntype)`
- `LoadCharInformation()`
- `LoadData()`
- `LoadMainCharacter()`
- `LoadMainMenuInformation(info, character)`
- `ModifyCharacterCreationSummary(arg1)`
- `ModifyCharacterModel(arg1, context)`
- `ModifyScoreboardModel(arg1, ply)`
- `ModifyVoiceIndicatorText(client, voiceText, voiceType)`
- `NetVarChanged(arg1, key, oldValue, value)`
- `OnAdminStickMenuClosed()`
- `OnAdminSystemLoaded(arg1, arg2)`
- `OnAmmoBoxUsed(activator, self, weapon, ammoType, givenAmount)`
- `OnCharAttribBoosted(client, self, attribID, boostID, arg5)`
- `OnCharAttribUpdated(client, self, key, arg4)`
- `OnCharCreated(client, character, originalData)`
- `OnCharDelete(client, id)`
- `OnCharDisconnect(client, character)`
- `OnCharFallover(self, entity, arg3)`
- `OnCharFlagsGiven(ply, self, addedFlags)`
- `OnCharFlagsTaken(ply, self, removedFlags)`
- `OnCharGetup(target, entity)`
- `OnCharKick(self, client)`
- `OnCharNetVarChanged(character, key, oldVar, value)`
- `OnCharPermakilled(self, arg2)`
- `OnCharRecognized(client, arg2)`
- `OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)`
- `OnCharVarChanged(character, varName, oldVar, newVar)`
- `OnCharacterCreationModelIconSet(icon, model, skin, bodyGroups)`
- `OnChatReceived(client, chatType, text, anonymous)`
- `OnCheaterCaught(client)`
- `OnConfigUpdated(key, oldValue, newValue)`
- `OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)`
- `OnCreateItemInteractionMenu(self, menu, itemTable)`
- `OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)`
- `OnDataSet(key, value, gamemode, map)`
- `OnDatabaseLoaded()`
- `OnDeathSoundPlayed(client, deathSound)`
- `OnDialogNPCTypeSet(client, npc)`
- `OnEntityLoaded(ent, data)`
- `OnEntityPersistUpdated(ent, data)`
- `OnEntityPersisted(ent, entData)`
- `OnItemAdded(owner, item)`
- `OnItemCreated(itemTable, self)`
- `OnItemOverridden(item, overrides)`
- `OnItemRegistered(ITEM)`
- `OnItemSpawned(self)`
- `OnLoadTables()`
- `OnLocalVarSet(key, value)`
- `OnLocalizationLoaded()`
- `OnModelPanelSetup(self)`
- `OnNPCTypeSet(client, npc, npcID, filteredData)`
- `OnOOCMessageSent(client, message)`
- `OnOpenVendorMenu(self, vendor)`
- `OnPAC3PartTransfered(part)`
- `OnPainSoundPlayed(entity, painSound)`
- `OnPickupMoney(activator, self)`
- `OnPlayerDroppedItem(client, spawnedItem)`
- `OnPlayerInteractItem(client, action, self, result, data)`
- `OnPlayerJoinClass(target, arg2, oldClass)`
- `OnPlayerLostStackItem(itemTypeOrItem)`
- `OnPlayerObserve(ply, enabled)`
- `OnPlayerPurchaseDoor(client, door, arg3)`
- `OnPlayerRotateItem(arg1, item, newRot)`
- `OnPlayerSwitchClass(client, class, oldClass)`
- `OnPlayerTakeItem(client, item)`
- `OnPrivilegeRegistered(arg1, arg2, arg3, arg4)`
- `OnPrivilegeUnregistered(arg1, arg2)`
- `OnRequestItemTransfer(self, arg2)`
- `OnRespawnKeyPressed(ply, key, left, baseTime, lastDeath)`
- `OnSalaryAdjust(client)`
- `OnSalaryGiven(client, char, pay, charFaction, class)`
- `OnSavedItemLoaded(loadedItems)`
- `OnServerLog(client, logType, logString, category)`
- `OnSetUsergroup(sid, new, source, ply)`
- `OnThemeChanged(themeName, useTransition)`
- `OnTicketClaimed(client, requester, ticketMessage)`
- `OnTicketClosed(client, requester, ticketMessage)`
- `OnTicketCreated(client, message)`
- `OnTransferred(target)`
- `OnUsergroupCreated(groupName, arg2)`
- `OnUsergroupPermissionsChanged(groupName, arg2)`
- `OnUsergroupRemoved(groupName)`
- `OnUsergroupRenamed(oldName, newName)`
- `OnVendorEdited(client, vendor, key)`
- `OnVoiceTypeChanged(client)`
- `OnWeaponOverrideUpdated(className, key, value)`
- `OnWeaponOverridesBulkSynced(overrides)`
- `OnWeaponRuntimeOverrideUpdated(className, dotPath, value)`
- `OnWeaponRuntimeOverridesBulkSynced(overrides)`
- `OnlineStaffDataReceived(staffData)`
- `OpenAdminStickUI(tgt)`
- `OpenCharacterMenu()`
- `OpenCharacterMenuOverride()`
- `OptionAdded(key, name, option)`
- `OptionChanged(key, old, value)`
- `OptionReceived(arg1, key, value)`
- `OverrideFactionDesc(uniqueID, arg2)`
- `OverrideFactionModelCustomization(client, faction, context, skinAllowed, bodygroupsAllowed)`
- `OverrideFactionModels(uniqueID, arg2)`
- `OverrideFactionName(uniqueID, arg2)`
- `OverrideSpawnTime(ply, baseTime)`
- `OverrideVoiceHearingStatus(listener, speaker, arg3)`
- `PaintItem(item)`
- `PlayerAccessVendor(client, vendor)`
- `PlayerBodyGroupChanged(client, oldVar, appliedGroups)`
- `PlayerCheatDetected(client)`
- `PlayerGagged(target, admin)`
- `PlayerLiliaDataLoaded(client)`
- `PlayerLoadedChar(client, character, currentChar)`
- `PlayerMessageSend(speaker, chatType, text, anonymous, receivers)`
- `PlayerModelChanged(client, newVar)`
- `PlayerMuted(target, admin)`
- `PlayerShouldPermaKill(client, inflictor, attacker)`
- `PlayerSpawnPointSelected(client, pos, ang)`
- `PlayerStaminaGained(client)`
- `PlayerStaminaLost(client)`
- `PlayerThrowPunch(client)`
- `PlayerUngagged(target, admin)`
- `PlayerUnmuted(target, admin)`
- `PlayerUseDoor(client, door)`
- `PopulateAdminStick(currentMenu, currentTarget, currentStores)`
- `PopulateAdminTabs(pages)`
- `PopulateConfigurationButtons(pages)`
- `PopulateFactionRosterOptions(list, members)`
- `PostBotSetup(client, character, inventory)`
- `PostDoorDataLoad(ent, doorData)`
- `PostDrawInventory(mainPanel, parentPanel)`
- `PostLoadData()`
- `PostLoadFonts(mainFont, mainFont)`
- `PostPlayerInitialSpawn(client)`
- `PostPlayerLoadedChar(client, character, currentChar)`
- `PostPlayerLoadout(client)`
- `PostPlayerSay(client, message, chatType, anonymous)`
- `PostScaleDamage(hitgroup, dmgInfo, damageScale)`
- `PreCharDelete(id)`
- `PreDoorDataSave(door, doorData)`
- `PreLiliaLoaded()`
- `PrePlayerInteractItem(client, action, self)`
- `PrePlayerLoadedChar(client, character, currentChar)`
- `PreSalaryGive(client, char, pay, charFaction, class)`
- `PreScaleDamage(hitgroup, dmgInfo, damageScale)`
- `ReadLogEntries(category, page)`
- `RefreshFonts()`
- `RemovePart(client, id)`
- `RemoveWarning(charID, index)`
- `ResetCharacterPanel()`
- `RunAdminSystemCommand(cmd, admin, victim, dur, reason)`
- `SAM.LoadedRanks()`
- `SaveData()`
- `ScoreboardClosed(self)`
- `ScoreboardOpened(self)`
- `ScoreboardRowCreated(slot, ply)`
- `ScoreboardRowRemoved(self, ply)`
- `SetMainCharacter(charID)`
- `SetupBagInventoryAccessRules(inventory)`
- `SetupBotPlayer(client)`
- `SetupDatabase()`
- `SetupPACDataFromItems()`
- `SetupPlayerModel(client, self)`
- `SetupQuickMenu(self)`
- `ShouldAllowScoreboardOverride(client, var)`
- `ShouldBarDraw(bar)`
- `ShouldDataBeSaved()`
- `ShouldDeleteSavedItems()`
- `ShouldDisableThirdperson(client)`
- `ShouldDrawAmmo(wpn)`
- `ShouldDrawCrosshair(client, wpn)`
- `ShouldDrawEntityInfo(e)`
- `ShouldDrawPlayerInfo(e)`
- `ShouldDrawWepSelect(client)`
- `ShouldEntityLoad(ent)`
- `ShouldEntitySave(ent)`
- `ShouldHideBars()`
- `ShouldMenuButtonShow(arg1)`
- `ShouldOverrideSalaryTimers()`
- `ShouldPlayDeathSound(client, deathSound)`
- `ShouldPlayPainSound(entity, painSound)`
- `ShouldRespawnScreenAppear(ply, left, baseTime, lastDeath)`
- `ShouldSaveItem(itemTable, self)`
- `ShouldShowCharVarInCreation(key)`
- `ShouldShowClassOnScoreboard(clsData)`
- `ShouldShowFactionOnScoreboard(ply)`
- `ShouldShowPlayerOnScoreboard(ply)`
- `ShouldShowQuickMenu()`
- `ShouldSpawnClientRagdoll(client)`
- `ShowPlayerOptions(target, options)`
- `StorageCanTransferItem(client, storage, item)`
- `StorageEntityRemoved(self, inventory)`
- `StorageInventorySet(entity, inventory, isCar)`
- `StorageItemRemoved()`
- `StorageOpen(storage, isCar)`
- `StorageRestored(ent, inventory)`
- `StorageUnlockPrompt(entity)`
- `StoreSpawns(spawns)`
- `SuppressHint(hint)`
- `SyncCharList(client)`
- `ThirdPersonToggled(arg1)`
- `TicketSystemClaim(client, requester, ticketMessage)`
- `TicketSystemClose(client, requester, ticketMessage)`
- `TooltipInitialize(var, panel)`
- `TooltipLayout(var)`
- `TooltipPaint(var, w, h)`
- `TryViewModel(entity)`
- `UpdateEntityPersistence(ent)`
- `VendorClassUpdated(vendor, id, allowed)`
- `VendorEdited(liaVendorEnt, key)`
- `VendorExited()`
- `VendorFactionBuyScaleUpdated(vendor, factionID, scale)`
- `VendorFactionSellScaleUpdated(vendor, factionID, scale)`
- `VendorFactionUpdated(vendor, id, allowed)`
- `VendorItemBuyPriceUpdated(vendor, itemType, value)`
- `VendorItemMaxStockUpdated(vendor, itemType, value)`
- `VendorItemModeUpdated(vendor, itemType, value)`
- `VendorItemSellPriceUpdated(vendor, itemType, value)`
- `VendorItemStockUpdated(vendor, itemType, value)`
- `VendorMessagesUpdated(vendor)`
- `VendorOpened(vendor)`
- `VendorPropertyUpdated(vendor, propertyName, propertyValue)`
- `VendorSynchronized(vendor)`
- `VendorTradeEvent(client, vendor, itemType, isSellingToVendor)`
- `VerifyCheats()`
- `VoiceToggled(enabled)`
- `WarningIssued(client, target, reason, severity, count, warnerSteamID, arg7)`
- `WarningRemoved(client, targetClient, arg3, arg4, arg5, arg6)`
- `WeaponCycleSound()`
- `WeaponSelectSound()`
- `WebImageDownloaded(n, arg2)`
- `WebSoundDownloaded(name, path)`

## Localization Analysis

- **Unique Keys:** 3833
- **Undefined Calls:** 5
- **Argument Mismatch:** 1

### Undefined Calls

- **salaryReceived** in core\meta\player.lua:504
  - Context: client:notifyLocalized("salaryReceived", "money", 250)
- **storageNearlyFull** in core\meta\player.lua:724
  - Context: client:notifyWarningLocalized("storageNearlyFull")
- **questUpdated** in core\meta\player.lua:753
  - Context: client:notifyInfoLocalized("questUpdated")
- **craftingFinished** in core\meta\player.lua:782
  - Context: client:notifySuccessLocalized("craftingFinished")
- **staffDutyEnabled** in core\meta\player.lua:840
  - Context: client:notifyAdminLocalized("staffDutyEnabled")

### Argument Mismatches

- **Total Mismatches:** 1


#### modules\administration\entities\weapons\lia_mapconfigurer\cl_init.lua
- **Line 181:** removedPoint(1)
  - Expected: 0 args, Provided: 1 args
  - Context: LocalPlayer():notifyLocalized("removedPoint", pt.label or L("pointNumber", idx))

### Undefined or Unlocalized Inferred Localization Values

These string literals are stored in localization-by-convention fields (e.g. `ITEM.name`, `lia.config.add` name arg, `lia.option.add` name/desc) and either reference a missing language key or use plain unlocalized text.

| Field | Issue | Value | File | Line |
|---|---|---|---|---:|
| `data.category` | Unlocalized string | `.. lia.db.convertDataType(category),` | modules\administration\submodules\logs\libraries\server.lua | 16 |
| `data.desc` | Unlocalized string | `Usergroup assigned to players when Lilia does not already have one stored for their SteamID.` | modules\administration\admin.lua | 34 |
| `lia.config.add:name` | Unlocalized string | `Default User Group` | modules\administration\admin.lua | 33 |

## Language File Comparison

### Summary
- **Languages Compared:** 6
- **Total Missing Keys:** 0

## Net Message Analysis

### Summary
- **Defined Net Messages:** 216
- **Used Net Messages:** 215
- **Defined But Unused:** 1
- **Used But Undefined:** 0

### Used But Undefined

None

### Module-Specific Registration Issues

- **Module-Specific But Registered Outside Module:** 3
- **Module-Specific Used But Undefined:** 0

- Note: A message is treated as module-specific when all detected literal usage sites belong to one module.
- Note: Valid in-module registrations include literal `MODULE.NetworkStrings`, `SCHEMA.NetworkStrings`, and `util.AddNetworkString(...)` sites inside that module root.

#### Module-Specific But Registered Outside Module

- `liaUpdateAdminPrivileges` in module `administration`
  - Reason: Used only by module "administration" but defined outside that module
  - Usage sites: lia.net.readBigTable at modules/administration/admin.lua:1599; lia.net.writeBigTable at modules/administration/admin.lua:903
  - Definition sites: init.lua networkStrings at init.lua:2
- `liaVendorEdit` in module `vendor`
  - Reason: Used only by module "vendor" but defined outside that module
  - Usage sites: net.Start at modules/vendor/derma/client.lua:2009; net.Start at modules/vendor/entities/entities/lia_vendor/init.lua:113; net.Start at modules/vendor/entities/entities/lia_vendor/init.lua:196; net.Start at modules/vendor/entities/entities/lia_vendor/init.lua:205; net.Start at modules/vendor/entities/entities/lia_vendor/init.lua:215
  - Definition sites: init.lua networkStrings at init.lua:2
- `liaVendorPropertySync` in module `vendor`
  - Reason: Used only by module "vendor" but defined outside that module
  - Usage sites: net.Start at modules/vendor/libraries/server.lua:177; net.Start at modules/vendor/libraries/server.lua:186; net.Receive at modules/vendor/netcalls/client.lua:191; net.Start at modules/vendor/netcalls/server.lua:107; net.Start at modules/vendor/netcalls/server.lua:116
  - Definition sites: init.lua networkStrings at init.lua:2

#### Module-Specific Used But Undefined

None

### Direction / Flow Issues

Total suspicious patterns: **27**

- `liaAdminSetCharProperty`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/administration/netcalls/server.lua:2
- `liaButtonRequestCancel`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: core/netcalls/server.lua:859
- `liaDoorData`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:1410
- `liaItemData`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:546
- `liaJobNpcCloseDialog`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:1579
- `liaKickCharacter`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: core/netcalls/server.lua:197
- `liaMapEntities`
  - Reason: Message has senders but no detected receivers
  - Send sides: server
  - Receive sides: none
  - Sender sites: modules/administration/netcalls/server.lua:571
  - Receiver sites: None
- `liaNetMessage`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client, server
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:1220; core/netcalls/server.lua:1104
- `liaNPCWeaponChange`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: core/netcalls/server.lua:640
- `liaPksCount`
  - Reason: Message has senders but no detected receivers
  - Send sides: server
  - Receive sides: none
  - Sender sites: modules/administration/netcalls/server.lua:286
  - Receiver sites: None
- `liaPopupQuestionRequestCancel`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: core/netcalls/server.lua:844
- `liaProvideServerPassword`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:365
- `liaRequestMapEntities`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/administration/netcalls/server.lua:547
- `liaRequestPksCount`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/administration/netcalls/server.lua:282
- `liaRequestRemoveWarning`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/administration/submodules/warnings/netcalls/server.lua:2
- `liaRequestTicketsCount`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/administration/submodules/tickets/netcalls/server.lua:102
- `liaRequestWarningsCount`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/administration/submodules/warnings/netcalls/server.lua:53
- `liaRunInteraction`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: core/netcalls/server.lua:906
- `liaSeqSet`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:397
- `liaSetWaypointWithLogo`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: core/netcalls/client.lua:8
- `liaStorageTransfer`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: server
  - Sender sites: None
  - Receiver sites: modules/inventory/types/gridinv/submodules/storage/netcalls/server.lua:34
- `liaTicketsCount`
  - Reason: Message has senders but no detected receivers
  - Send sides: server
  - Receive sides: none
  - Sender sites: modules/administration/submodules/tickets/netcalls/server.lua:109
  - Receiver sites: None
- `liaTrunkInitStorage`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: shared
  - Sender sites: None
  - Receiver sites: modules/inventory/types/gridinv/submodules/storage/netcalls/shared.lua:1
- `liaVendorBuyPrice`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: modules/vendor/netcalls/client.lua:62
- `liaVendorFaction`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: modules/vendor/netcalls/client.lua:57
- `liaVendorSellPrice`
  - Reason: Message has receivers but no detected senders
  - Send sides: none
  - Receive sides: client
  - Sender sites: None
  - Receiver sites: modules/vendor/netcalls/client.lua:73
- `liaWarningsCount`
  - Reason: Message has senders but no detected receivers
  - Send sides: server
  - Receive sides: none
  - Sender sites: modules/administration/submodules/warnings/netcalls/server.lua:57
  - Receiver sites: None

---

## Derma Panel Analysis

### Summary
- **Registered Panels:** 69
- **Referenced Panels:** 66
- **Module Panels Outside derma:** 0
- **Registered But Unused:** 30

### Module Panels Outside derma

None

### Registered But Unused Panels

| Panel | Module | Location |
|---|---|---|
| `liaAttribBar` | `framework` | `core/derma/panels/attribs.lua:124` |
| `liaBlurredDFrame` | `framework` | `core/derma/panels/panels.lua:50` |
| `liaCategory` | `framework` | `core/derma/panels/category.lua:116` |
| `liaCharacterAttribs` | `framework` | `core/derma/panels/attribs.lua:199` |
| `liaCharacterAttribsRow` | `framework` | `core/derma/panels/attribs.lua:321` |
| `liaCharacterCreation` | `framework` | `core/derma/mainmenu/creation.lua:392` |
| `liaClasses` | `framework` | `core/derma/panels/f1menu.lua:978` |
| `liaHeaderPanel` | `framework` | `core/derma/panels/headerpanel.lua:22` |
| `liaHorizontalScroll` | `framework` | `core/derma/panels/horizontal_scroll.lua:70` |
| `liaHorizontalScrollBar` | `framework` | `core/derma/panels/horizontal_scroll.lua:128` |
| `liaItemList` | `framework` | `core/derma/panels/genericitemlist.lua:63` |
| `liaItemSelector` | `framework` | `core/derma/panels/genericitemlist.lua:150` |
| `liaMarkupPanel` | `framework` | `core/libraries/thirdparty/cl_markup.lua:540` |
| `liaModelPanel` | `framework` | `core/derma/panels/modelpanel.lua:90` |
| `liaPrivilegeRow` | `framework` | `core/derma/panels/privilege_row.lua:101` |
| `liaSemiTransparentDFrame` | `framework` | `core/derma/panels/panels.lua:69` |
| `liaSimpleCheckbox` | `framework` | `core/derma/panels/checkbox.lua:176` |
| `liaSlider` | `framework` | `core/derma/panels/slider.lua:179` |
| `liaTable` | `framework` | `core/derma/panels/table.lua:633` |
| `liaUserGroupButton` | `framework` | `core/derma/panels/usergroup_button.lua:57` |
| `liaUserGroupList` | `framework` | `core/derma/panels/usergroup_list.lua:113` |
| `liaVoicePanel` | `framework` | `core/derma/panels/voice.lua:111` |
| `liaGridInventoryPanel` | `gridinv` | `modules/inventory/types/gridinv/derma/cl_grid_inventory_panel.lua:250` |
| `liaGridInvItem` | `gridinv` | `modules/inventory/types/gridinv/derma/cl_grid_inventory_item.lua:133` |
| `liaVendorBodygroupEditor` | `vendor` | `modules/vendor/derma/client.lua:2752` |
| `liaVendorEditorItemRow` | `vendor` | `modules/vendor/derma/client.lua:2000` |
| `liaVendorFactionEditor` | `vendor` | `modules/vendor/derma/client.lua:2700` |
| `liaVendorItem` | `vendor` | `modules/vendor/derma/client.lua:1080` |
| `liaListInventory` | `weightinv` | `modules/inventory/types/weightinv/derma/cl_list_inventory.lua:27` |
| `liaListInventoryPanel` | `weightinv` | `modules/inventory/types/weightinv/derma/cl_list_inventory_panel.lua:157` |

---

## Module File Placement Analysis

### Summary
- **Net Handlers Outside netcalls:** 2
- **UI / Derma Code Outside derma:** 8

### Net Handlers Outside netcalls

| Module | Location | Expected Folder | Reason |
|---|---|---|---|
| `mainmenu` | `modules/mainmenu/module.lua:47` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\mainmenu\netcalls` | Module net handler is outside the netcalls folder |
| `mainmenu` | `modules/mainmenu/module.lua:90` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\mainmenu\netcalls` | Module net handler is outside the netcalls folder |

### UI / Derma Code Outside derma

| Module | Location | Expected Folder | Reason |
|---|---|---|---|
| `administration` | `modules/administration/admin.lua:1623` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\administration\derma` | Module UI-heavy code is outside the derma folder |
| `administration` | `modules/administration/entities/weapons/lia_mapconfigurer/cl_init.lua:146` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\administration\derma` | Module UI-heavy code is outside the derma folder |
| `administration` | `modules/administration/libraries/client.lua:581` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\administration\derma` | Module UI-heavy code is outside the derma folder |
| `administration` | `modules/administration/netcalls/client.lua:91` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\administration\derma` | Module UI-heavy code is outside the derma folder |
| `adminstick` | `modules/administration/submodules/adminstick/libraries/client.lua:427` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\administration\submodules\adminstick\derma` | Module UI-heavy code is outside the derma folder |
| `protection` | `modules/protection/libraries/client.lua:3166` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\protection\derma` | Module UI-heavy code is outside the derma folder |
| `storage` | `modules/inventory/types/gridinv/submodules/storage/libraries/client.lua:89` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\inventory\types\gridinv\submodules\storage\derma` | Module UI-heavy code is outside the derma folder |
| `tickets` | `modules/administration/submodules/tickets/libraries/client.lua:42` | `D:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\modules\administration\submodules\tickets\derma` | Module UI-heavy code is outside the derma folder |

---

## Config: Undefined lia.config.get Keys

_No undefined `lia.config.get` calls detected._

---
