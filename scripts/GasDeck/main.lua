-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 bliatun-code and Ethos Widgets contributors.
-- GasDeck: receiver power, gasoline engines and fuel telemetry for ETHOS.
-- Read-only instrumentation. This widget NEVER controls ignition or throttle.
local VERSION = "2026.10-v1"
local MAX_IMAGE_PIXELS, BITMAP_RESERVE = 160000, 65536
local FLIGHT_SESSION
local HISTORY_POINTS, GRAPH_BINS = 180, 48
local GRAPH_SOURCE_STEPS, GRAPH_BIN_STEPS = 24, 16
local BITMAP_CACHE = setmetatable({}, {__mode = "v"})
local VALUE_FONTS = {FONT_XXL, FONT_XL, FONT_L_BOLD, FONT_L, FONT_M_BOLD, FONT_M, FONT_S, FONT_XS}
local SMALL_FONTS = {FONT_S, FONT_XS}
local SURFACE_WIDTH,SURFACE_HEIGHT=800,480
local COLORS = {
    black=lcd.RGB(0,0,0), white=lcd.RGB(244,247,251), muted=lcd.RGB(145,160,175),
    accent=lcd.RGB(247,188,82), green=lcd.RGB(53,220,139), yellow=lcd.RGB(255,211,63),
    orange=lcd.RGB(255,151,48), red=lcd.RGB(255,73,91), border=lcd.RGB(106,122,139),
    track=lcd.RGB(112,127,144,0.14),
    ignitionOn=lcd.RGB(24,96,64), ignitionOff=lcd.RGB(104,30,42),
    ignitionUnknown=lcd.RGB(41,50,60),
}
local TYPES = {{name="LiPo",full=4.20,empty=3.30},{name="LiFe",full=3.65,empty=2.80}}
local SETTING_DEFS = {
    {"engineBrand",""},
    {"engineCC",60,0,1000},
    {"engineCount",1,1,4},
    {"backgroundMode",1,1,3},
    {"backgroundColor",COLORS.black},
    {"accentColor",COLORS.accent},
    {"imageMode",1,1,3},
    {"imageName",""},
    {"fontPath",""},
    {"preview",false},
    {"rpmCount",1,0,4},
    {"tempCount",2,0,4},
    {"meterStyle",2,1,2},
    {"rpmMaximum",10000,1000,100000},
    {"redZone",85,10,100},
    {"tempWarning",150,30,300},
    {"tempCritical",180,31,350},
    {"tempUnit",1,1,2},
    {"fuelMethod",1,1,4},
    {"tankCapacity",500,10,20000},
    {"fuelLoaded",500,10,20000},
    {"fuelBaselineCenti",0,0,100000000},
    {"flowUnit",1,1,4},
    {"volumeUnit",1,1,3},
    {"flowCorrection",100,10,300},
    {"fuelWarning",20,1,50},
    {"fuelAlarm",true},
    {"fuelSound",""},
    {"rxAlarm",true},
    {"rxSound",""},
    {"alarmEstimate",false},
    {"audioFolder","/audio"},
    {"alertInterval",15,1,600},
    {"rfCount",2,1,3},
    {"signalMinimum",0,-150,199},
    {"signalMaximum",100,-149,200},
    {"logEnabled",false},
    {"flightMinimum",60,60,3600},
    {"throttleThreshold",50,10,100},
    {"highThrottleSeconds",5,1,120},
    {"endDelay",10,3,120},
    {"throttleMinimum",-1024,-2048,2047},
    {"throttleMaximum",1024,-2047,2048},
    {"autoLogEnabled",false},
    {"autoLogDelay",5,0,120},
    {"timerMode",1,1,2},
    {"ignitionThreshold",0,-2048,2048},
    {"rx1Chemistry",1,1,2},
    {"rx1Cells",2,1,8},
    {"rx1Capacity",2500,100,20000},
    {"rx1Method",1,1,3},
    {"rx2Chemistry",1,1,2},
    {"rx2Cells",2,1,8},
    {"rx2Capacity",2500,100,20000},
    {"rx2Method",1,1,3},
    {"rf1Profile",1,1,3},
    {"rfWarnDB",35,-149,200},
    {"rfCriticalDB",32,-150,199},
    {"rfWarnPercent",95,1,100},
    {"rfCriticalPercent",50,0,99},
    {"rf2Profile",1,1,3},
    {"rf2WarnDB",35,-149,200},
    {"rf2CriticalDB",32,-150,199},
    {"rf2WarnPercent",95,1,100},
    {"rf2CriticalPercent",50,0,99},
    {"rf3Profile",1,1,3},
    {"rf3WarnDB",35,-149,200},
    {"rf3CriticalDB",32,-150,199},
    {"rf3WarnPercent",95,1,100},
    {"rf3CriticalPercent",50,0,99},
}
local SETTING_MAP = {}
for _, definition in ipairs(SETTING_DEFS) do SETTING_MAP[definition[1]] = definition end
local SETTINGS = {}
for _,definition in ipairs(SETTING_DEFS) do SETTINGS[#SETTINGS+1]=definition[1] end
local SOURCE_KEYS = {"rx1Source","rx2Source","currentSource","consumptionSource","rx1CurrentSource","rx2CurrentSource","rx1UsedSource","rx2UsedSource","rx1PercentSource","rx2PercentSource","flowSource","fuelUsedSource","fuelRemainingSource","rssi1Source","rssi2Source","rssi3Source","graph1Source","graph2Source","graph3Source","rpm1Source","rpm2Source","rpm3Source","rpm4Source","temp1Source","temp2Source","temp3Source","temp4Source","ignitionSource","armSource","throttleSource","airborneSource","powerSource","timerSource","txSource"}
-- The source layout is fixed. armSource is a reserved, unused slot.
local CONFIG_LIMIT, CONFIG_STATE = 8192, nil
-- SPDX-License-Identifier: MIT
-- Shared build-time code. Bundled into each widget; no runtime dependency.
local DeckCore = (function()
    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, value))
    end
    local function round(value) return math.floor(value + 0.5) end
    local function finite(value)
        return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
    end
    local function selectedSource(source)
        if source == nil or source == false or source == "" then return nil end
        local ok, category = pcall(function() return source:category() end)
        if ok and CATEGORY_NONE ~= nil and category == CATEGORY_NONE then return nil, category end
        return source, ok and category or nil
    end
    local function getSource(parameters)
        local ok, source = pcall(system.getSource, parameters)
        if ok then return selectedSource(source) end
    end
    local function restoreSource(value)
        if type(value) == "string" and value ~= "" then return getSource(value)
        elseif type(value) == "number" then return getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = value})
        elseif type(value) == "userdata" or type(value) == "table" then return selectedSource(value) end
    end
    local function validWidget(widget)
        return type(widget) == "table" and not widget.destroyed and type(widget.data) == "table"
            and type(widget.scratch) == "table" and finite(widget.nextPoll)
    end
    local function sample(source, quantity)
        source = selectedSource(source)
        if not source then return nil end
        local ok, active, value, unit = pcall(function() return source:state(), source:value(), source:unit() end)
        if not ok or not finite(value) then return nil end
        if active == false then
            local categoryOK, category = pcall(function() return source:category() end)
            if not categoryOK then return nil end
            if not (quantity == "timer" and category == CATEGORY_TIMER)
                and not (quantity == "control" and category ~= CATEGORY_TELEMETRY_SENSOR) then return nil end
        end
        if quantity == "signal" and unit ~= UNIT_DB and unit ~= UNIT_PERCENT then return nil end
        if quantity == "rpm" and unit ~= UNIT_RPM and unit ~= UNIT_NONE then return nil end
        if quantity == "voltage" and unit ~= UNIT_VOLT and unit ~= UNIT_MILLIVOLT and unit ~= UNIT_NONE then return nil end
        if quantity == "current" and unit ~= UNIT_AMPERE and unit ~= UNIT_MILLIAMPERE and unit ~= UNIT_NONE then return nil end
        if quantity == "capacity" and unit ~= UNIT_MILLIAMPERE_HOUR and unit ~= UNIT_AMPERE_HOUR and unit ~= UNIT_NONE then return nil end
        if quantity == "percent" then
            -- Accept explicitly labelled raw percent sources, never arbitrary voltage/current.
            if unit ~= UNIT_PERCENT then
                local labelOK, label = pcall(function() return source:stringUnit() end)
                if unit ~= UNIT_NONE or not labelOK or type(label) ~= "string" or label:gsub("%s", "") ~= "%" then return nil end
            end
            if value < 0 or value > 100 then return nil end
        end
        if quantity == "voltage" and unit == UNIT_MILLIVOLT then value = value / 1000
        elseif quantity == "current" and unit == UNIT_MILLIAMPERE then value = value / 1000
        elseif quantity == "capacity" and unit == UNIT_AMPERE_HOUR then value = value * 1000 end
        return value
    end
    local function details(source, name, label)
        source = selectedSource(source)
        local result = {name = name, label = label, decimals = 0, unit = nil}
        if source then
            local ok, n, l, d, u = pcall(function()
                return source:name(), source:stringUnit(), source:decimals(), source:unit()
            end)
            if ok then
                if type(n) == "string" and n ~= "" then result.name = n end
                if type(l) == "string" then result.label = l end
                if finite(d) then result.decimals = clamp(d, 0, 3) end
                result.unit = u
            end
        end
        return result
    end
    local function sourceDetails(source, name, label)
        local value = details(source, name, label)
        return value.name, value.label, value.decimals
    end
    local function rfDetails(source, name)
        source = selectedSource(source)
        if not source then return name, "dB" end
        local value = details(source, name, "")
        return value.name, value.unit == UNIT_PERCENT and "%" or value.unit == UNIT_DB and "dB" or "?"
    end
    local function metadata(widget, slot, source, clock, name, label, rf)
        widget.metadata = widget.metadata or {}
        local cached = widget.metadata[slot]
        if not cached or cached.source ~= source or clock < cached.clock or clock >= cached.clock + 5 then
            cached = details(source, name, label)
            cached.source, cached.clock = source, clock
            widget.metadata[slot] = cached
        end
        if source ~= nil and source ~= false and source ~= "" then
            local ok, unit = pcall(function() return source:unit() end)
            cached.unit = ok and unit or nil -- canonical units must stay live
        end
        local unit = cached.label
        if rf then unit = not source and "dB"
            or cached.unit == UNIT_PERCENT and "%" or cached.unit == UNIT_DB and "dB" or "?" end
        return cached.name, unit, cached.decimals
    end
    -- Monotonic consumed-mAh high-water mark, separate from flight qualification.
    -- A sustained loss of a configured pack voltage is the same boundary as the log.
    local function batteryUsed(widget, slot, source, voltageSource, voltage, used, capacity, clock, key)
        widget.batteryStates = widget.batteryStates or {}
        local state = widget.batteryStates[slot]
        if not state or state.source ~= source or state.voltageSource ~= voltageSource
            or state.capacity ~= capacity or state.key ~= key then
            state = {source = source, voltageSource = voltageSource, capacity = capacity, key = key}
            widget.batteryStates[slot] = state
        end
        if selectedSource(voltageSource) then
            if voltage == nil then
                if not state.lossSince or clock < state.lossSince then state.lossSince = clock end
                if clock - state.lossSince >= widget.endDelay then state.newPack = true end
            else
                if state.newPack then state.high, state.uncertain, state.newPack = nil, nil, nil end
                state.lossSince = nil
            end
        end
        if used ~= nil then
            local tolerance = math.max(1, capacity * 0.001)
            if state.high and used + tolerance < state.high then state.uncertain = true end
            state.high = math.max(state.high or used, used)
        end
        return not state.uncertain and used or nil, state.uncertain == true
    end
    -- Cooldowns survive brief missing data, recovery and appearance edits.
    local function alarmReady(widget, slot, value, threshold, enabled, clock)
        widget.alertStates = widget.alertStates or {}
        local state = widget.alertStates[slot]
        if not state then state = {}; widget.alertStates[slot] = state end
        if value ~= nil then
            if value <= threshold then state.active = true
            elseif value >= threshold + 2 then state.active = false end
        end
        if not enabled or widget.preview or value == nil or value > threshold then return nil end
        if clock < (widget.audioUntil or 0) or clock < (state.nextDue or 0) then return nil end
        return state
    end
    local function alarmPlayed(widget, state, clock, interval, duration)
        duration = (duration or 0) + 0.5
        state.last, state.nextDue = clock, clock + math.max(interval, duration)
        widget.audioUntil = clock + duration
    end
    -- Strict, checksummed and versioned scalar records; unknown future schemas are read-only.
    local function decodeSettings(key, bytes, limit, digest, identityHex, decode, tag, definitions)
        if type(bytes) ~= "string" or #bytes > limit then return nil end
        local body, check = bytes:match("^(.*\n)CHECK=(%d+)\n$")
        if not body or tonumber(check) ~= digest(body) then return nil end
        local format, identity, sequence, payload = body:match("^(%u+%d+)|(%x+)|(%d+)\n(.*)$")
        sequence = tonumber(sequence)
        if identity ~= identityHex(key) or not sequence or sequence > 1000000000 then return nil end
        if format ~= tag then return nil, "Unsupported settings format; do not downgrade" end
        local values, count, position = {}, 0, 1
        while position <= #payload do
            local ending = payload:find("\n", position, true)
            if not ending then return nil end
            local name, kind, value = payload:sub(position, ending - 1):match("^([%a][%w]*)=([nbs]):(.*)$")
            if not name or values[name] ~= nil then return nil end
            if kind == "n" then value = tonumber(value); if not finite(value) then return nil end
            elseif kind == "b" then
                if value ~= "0" and value ~= "1" then return nil end
                value = value == "1"
            else
                if #value > 512 or #value % 2 ~= 0 or value:find("[^%x]") then return nil end
                value = value:lower():gsub("%x%x", decode)
            end
            values[name], count, position = value, count + 1, ending + 1
        end
        if values.schema ~= 1 then return nil, "Unsupported settings schema; do not downgrade" end
        values.schema, count = nil, count - 1
        if count ~= #definitions then return nil end
        for _, definition in ipairs(definitions) do
            if type(values[definition[1]]) ~= type(definition[2]) then return nil end
        end
        return {values = values, sequence = sequence, payload = payload, format = format}
    end
    -- Fixed-size native-font FIFO. Constant-time eviction; no retained custom fonts.
    local fitCache, fitKeys, fitCount, fitCursor = {}, {}, 0, 0
    local nativeFontHeights = {} -- fixed native font constants only
    local function fitText(value, width, height, customFont, small)
        value = tostring(value)
        local key = not customFont and table.concat({width, height, small and 1 or 0, value}, "|") or nil
        local cached = key and fitCache[key]
        if cached then return cached.font, cached.value, cached.w, cached.h end
        local fonts = small and SMALL_FONTS or VALUE_FONTS
        local chosen, tw, th
        if customFont and not small then
            lcd.font(customFont); tw, th = lcd.getTextSize(value)
            if tw <= width and th <= height then return customFont, value, tw, th end
        end
        for index, font in ipairs(fonts) do
            -- Native font heights do not depend on label width. Do not repeatedly
            -- measure fonts that are already known to be too tall for this field.
            local knownHeight = nativeFontHeights[font]
            if not knownHeight or knownHeight <= height or index == #fonts then
                chosen = font; lcd.font(font); tw, th = lcd.getTextSize(value)
                if not knownHeight then
                    nativeFontHeights[font] = th
                end
                if tw <= width and th <= height then break end
            end
        end
        if tw > width then
            local suffix = "..."
            local ew = lcd.getTextSize(suffix)
            if ew > width then value = ""
            else
                local low, high, best = 0, #value, 0
                while low < high do
                    local middle = math.ceil((low + high) / 2)
                    local boundary = middle
                    local byte = value:byte(boundary + 1)
                    while boundary > 0 and byte and byte >= 128 and byte < 192 do
                        boundary = boundary - 1; byte = value:byte(boundary + 1)
                    end
                    local candidate = value:sub(1, boundary) .. suffix
                    local candidateWidth = lcd.getTextSize(candidate)
                    if candidateWidth <= width then low, best = middle, boundary
                    else high = middle - 1 end
                end
                value = value:sub(1, best) .. suffix
            end
            tw, th = lcd.getTextSize(value)
        end
        if key then
            fitCursor = fitCursor % 64 + 1
            local previous = fitKeys[fitCursor]
            if previous then fitCache[previous] = nil else fitCount = fitCount + 1 end
            fitKeys[fitCursor] = key
            fitCache[key] = {font = chosen, value = value, w = tw, h = th}
        end
        return chosen, value, tw, th
    end
    return {clamp = clamp, round = round, finite = finite, selectedSource = selectedSource,
        getSource = getSource, restoreSource = restoreSource, validWidget = validWidget,
        sample = sample, sourceDetails = sourceDetails, rfDetails = rfDetails, metadata = metadata,
        batteryUsed = batteryUsed, alarmReady = alarmReady, alarmPlayed = alarmPlayed,
        decodeSettings = decodeSettings, fitText = fitText,
        cacheSize = function() return fitCount end}
end)()
local clamp, round, finite = DeckCore.clamp, DeckCore.round, DeckCore.finite
local selectedSource, getSource, restoreSource = DeckCore.selectedSource, DeckCore.getSource, DeckCore.restoreSource
local validWidget, sample = DeckCore.validWidget, DeckCore.sample
local sourceDetails, rfDetails = DeckCore.sourceDetails, DeckCore.rfDetails


local function changed(widget, resetAlarm)
    if not validWidget(widget) then return end
    widget.refresh = true
    widget.nextPoll = 0
    widget.metadata = nil
    if resetAlarm then widget.soundCache = nil end
    pcall(model.dirty)
end

local function themeColor(index, fallback)
    if index ~= nil then
        local ok, color = pcall(lcd.themeColor, index)
        if ok and finite(color) then return color end
    end
    return fallback
end

local function palette(widget)
    local background = COLORS.black
    local foreground = COLORS.white
    local secondary = COLORS.muted
    local accent = widget.accentColor
    if widget.backgroundMode == 1 then
        background = themeColor(THEME_PAGE_BGCOLOR or THEME_DEFAULT_BGCOLOR, COLORS.black)
        foreground = themeColor(THEME_PRIMARY_COLOR or THEME_DEFAULT_COLOR, COLORS.white)
        secondary = themeColor(THEME_SECONDARY_COLOR, foreground)
        accent = themeColor(THEME_HIGHLIGHT_COLOR or THEME_FOCUS_COLOR, accent)
    elseif widget.backgroundMode == 3 then
        background = widget.backgroundColor
        local ok, contrast = pcall(lcd.getContrastingColor, background)
        if ok and finite(contrast) then foreground = contrast end
        secondary = foreground
    end
    local colors = widget.colors or {}
    colors.background, colors.foreground, colors.secondary = background, foreground, secondary
    colors.accent, colors.border, colors.track = accent, COLORS.border, COLORS.track
    widget.colors = colors
    return colors
end


local function create()
    local widget = {data={}, scratch={}, nextPoll=0, refresh=true, imageDirty=true, fontDirty=true,
        peakRPM={}, peakTemp={}}
    for _,definition in ipairs(SETTING_DEFS) do widget[definition[1]]=definition[2] end
    widget.timerSource=getSource({category=CATEGORY_TIMER,member=0})
    widget.builtinTx=getSource({category=CATEGORY_SYSTEM,member=SYSTEM_MAIN_VOLTAGE or MAIN_VOLTAGE})
    return widget
end
local function header(path, count)
    local ok, file = pcall(io.open, path, "rb")
    if not ok or not file then return nil end
    local readOK, bytes = pcall(io.read, file, count)
    pcall(io.close, file)
    if readOK and type(bytes) == "string" then return bytes end
end

local function modelKey()
    local ok, path = pcall(model.path)
    if ok and type(path) == "string" and path ~= "" and #path <= 256 then return path end
end

local function digest(value)
    local result, length = 5381, #value
    -- Four DJB2 steps at once, exactly representable below 2^52.
    -- This preserves existing filenames/checksums with far fewer VM instructions.
    local bulk = length - length % 4
    for index = 1, bulk, 4 do
        local a, b, c, d = value:byte(index, index + 3)
        result = (result * 1185921.0 + a * 35937.0 + b * 1089.0 + c * 33.0 + d) % 2147483647
    end
    for index = bulk + 1, length do result = (result * 33.0 + value:byte(index)) % 2147483647 end
    return math.floor(result)
end

local HEX_ENCODE, HEX_DECODE = {}, {}
for byte = 0, 255 do
    local character, encoded = string.char(byte), string.format("%02x", byte)
    HEX_ENCODE[character], HEX_DECODE[encoded] = encoded, character
end

local function identityHex(value)
    -- Table replacement runs inside Lua's string library, not a callback per byte.
    return (value:gsub(".", HEX_ENCODE))
end


-- Scalar settings belong to the model, not to a particular widget instance.
-- Native ETHOS storage retains only compact, strongly typed source references.

-- Separate namespaces: never read/write GasDeck model settings or counters.
local function configRecord(key, bytes)
    return DeckCore.decodeSettings(key, bytes, CONFIG_LIMIT, digest, identityHex, HEX_DECODE,
        "GD2", SETTING_DEFS)
end
local function configLoad(key)
    if not key then return nil, nil, "Model path unavailable" end
    local base = "/scripts/gc1" .. tostring(digest(key))
    local a, b = header(base .. "a.cfg", CONFIG_LIMIT + 1), header(base .. "b.cfg", CONFIG_LIMIT + 1)
    local function generation(bytes)
        if not bytes or #bytes > CONFIG_LIMIT then return -1 end
        local format, identity, sequence = bytes:match("^(GD%d+)|(%x+)|(%d+)\n")
        if identity ~= identityHex(key) then return -1 end
        sequence = tonumber(sequence)
        return sequence and sequence <= 1000000000 and sequence or -1
    end
    -- Fully validate newest first; inspect the older copy only for recovery.
    if generation(b) > generation(a) then a, b = b, a end
    local latest, formatProblem = configRecord(key, a)
    if formatProblem then CONFIG_STATE = nil; return nil, base, formatProblem end
    if not latest then latest, formatProblem = configRecord(key, b) end
    if formatProblem then CONFIG_STATE = nil; return nil, base, formatProblem end
    if not latest and (a or b) then
        CONFIG_STATE = nil
        return nil, base, "Settings files invalid; restore backup"
    end
    CONFIG_STATE = {key = key, base = base, record = latest}
    return latest, base
end

local function configPayload(widget)
    local lines = {}
    for _, key in ipairs(SETTINGS) do
        local value, kind = widget[key]
        if type(value) == "boolean" then kind, value = "b", value and "1" or "0"
        elseif finite(value) then kind, value = "n", string.format("%.0f", value)
        elseif type(value) == "string" and #value <= 256 then kind, value = "s", identityHex(value)
        else return nil end
        lines[#lines + 1] = key .. "=" .. kind .. ":" .. value .. "\n"
    end
    return "schema=n:1\n" .. table.concat(lines)
end

local function configSave(widget)
    local key = modelKey()
    if key ~= widget.configKey or not key then return false, "Model changed; reopen widget" end
    -- Refresh disk state in read(), never reparse both files on every save.
    -- External simulator-file changes are supported only while it is closed.
    if widget.configError and not CONFIG_STATE then return false, widget.configError end
    if not CONFIG_STATE or CONFIG_STATE.key ~= key then return false, "Reopen widget before saving" end
    local record, base = CONFIG_STATE.record, CONFIG_STATE.base
    local payload = configPayload(widget)
    if not payload then return false, "Invalid or oversized setting" end
    if record and record.payload == payload then widget.configPayload = payload; return true end
    if record and record.payload ~= widget.configPayload then return false, "Settings changed in another instance; reopen" end
    local sequence = (record and record.sequence or 0) + 1
    if sequence > 1000000000 then return false, "Settings generation limit reached" end
    local body = "GD2|" .. identityHex(key) .. "|" .. sequence .. "\n" .. payload
    local bytes = body .. "CHECK=" .. tostring(digest(body)) .. "\n"
    if #bytes > CONFIG_LIMIT then return false, "Settings file too large" end
    local path = base .. (sequence % 2 == 1 and "a.cfg" or "b.cfg")
    local ok, handle = pcall(io.open, path, "w")
    if not ok or not handle then return false, "Cannot open settings file" end
    local written = pcall(io.write, handle, bytes)
    local closed = pcall(io.close, handle)
    if not written or not closed or header(path, CONFIG_LIMIT + 1) ~= bytes then
        return false, "Settings write failed; previous copy retained"
    end
    CONFIG_STATE.record = {sequence = sequence, payload = payload}
    widget.configPayload, widget.configPath = payload, path
    print("GasDeck settings saved: " .. path)
    return true
end


local function read(widget)
    if not validWidget(widget) then return end
    local version=storage.read("v")
    if version=="GD1" then
        for index,key in ipairs(SOURCE_KEYS) do widget[key]=restoreSource(storage.read("s"..index)) end
    end
    widget.ignitionSource=selectedSource(widget.ignitionSource)
    widget.armSource=nil -- reserved source slot, never a second flight gate
    widget.configKey=modelKey()
    local record,base,problem=configLoad(widget.configKey)
    widget.configBase,widget.configError=base,problem
    if record then
        for _,definition in ipairs(SETTING_DEFS) do
            local key,default=definition[1],definition[2]
            local value=record.values[key]
            if type(value)==type(default) then
                if finite(value) then
                    widget[key]=definition[3] and round(clamp(value,definition[3],definition[4])) or value
                elseif type(value)=="string" then widget[key]=value:sub(1,256)
                else widget[key]=value end
            end
        end
        widget.configPayload=record.payload
    end
    widget.signalMaximum=math.max(widget.signalMinimum+1,widget.signalMaximum)
    widget.throttleMaximum=math.max(widget.throttleMinimum+1,widget.throttleMaximum)
    widget.tempCritical=math.max(widget.tempWarning,widget.tempCritical)
    widget.fuelLoaded=math.min(widget.fuelLoaded,widget.tankCapacity)
    widget.imageDirty,widget.fontDirty,widget.nextPoll,widget.refresh=true,true,0,true
    widget.fuelState=nil -- integrated fuel is deliberately unknown after module restart
end
local function write(widget)
    if not validWidget(widget) then return end
    local ok,problem=configSave(widget)
    widget.configError=not ok and problem or nil
    if not ok then print("GasDeck settings NOT saved: "..tostring(problem)) end
    storage.write("v","GD1")
    for index,key in ipairs(SOURCE_KEYS) do storage.write("s"..index,widget[key] or "") end
end




-- Source names and canonical units remain available without a live reading.



local function rfLimits(widget,unit,channel)
    local prefix=channel==1 and "rf" or "rf"..channel
    local profile=widget["rf"..channel.."Profile"]
    local warning,critical
    if unit=="%" then
        warning,critical=widget[prefix.."WarnPercent"],widget[prefix.."CriticalPercent"]
        if profile~=3 then warning,critical=95,50 end
    else
        warning,critical=widget[prefix.."WarnDB"],widget[prefix.."CriticalDB"]
        if profile==1 then warning,critical=35,32 elseif profile==2 then warning,critical=45,42 end
    end
    return unit=="%" and 0 or widget.signalMinimum,unit=="%" and 100 or widget.signalMaximum,
        warning,critical,profile==1 and "ACCESS/TD/TW" or profile==2 and "ACCST" or "Custom"
end
-- ETHOS uses io.read(handle, byteCount), not the standard Lua file:read().
-- Only resource changes perform file I/O; no file is left open on an error.
local function integer(bytes, offset, count, little)
    if not bytes or offset + count - 1 > #bytes then return nil end
    local value = 0
    for index = 0, count - 1 do
        local position = little and offset + count - 1 - index or offset + index
        value = value * 256 + bytes:byte(position)
    end
    return value
end

local function imagePath(name)
    if type(name) ~= "string" then return "" end
    name = name:gsub("\\", "/")
    if name == "" or name:sub(-1) == "/" or name:find("..", 1, true) then return "" end
    name = name:gsub("^BITMAPS:/", "/bitmaps/")
    if not name:find("/", 1, true) and not name:find(":", 1, true) then
        name = "/bitmaps/models/" .. name
    end
    return name
end

local function imageSize(bytes)
    if not bytes then return nil, nil, "Image file unavailable" end
    if bytes:sub(1, 8) == "\137PNG\r\n\26\n" and bytes:sub(13, 16) == "IHDR" then
        local depth, kind = bytes:byte(25), bytes:byte(26)
        if depth ~= 8 or (kind ~= 2 and kind ~= 6) then
            return nil, nil, "Use 8-bit RGB/RGBA PNG"
        end
        return integer(bytes, 17, 4), integer(bytes, 21, 4)
    elseif bytes:sub(1, 2) == "BM" then
        local height = integer(bytes, 23, 4, true)
        -- Top-down BITMAPV4 files stalled this simulator's native decoder.
        if height and height >= 2147483648 then
            return nil, nil, "Top-down BMP not supported; use PNG"
        end
        return integer(bytes, 19, 4, true), height
    elseif bytes:sub(1, 2) == "\255\216" then
        -- Bounded JPEG SOF search. Refuse unusual headers instead of a blind allocation.
        local position = 3
        while position + 8 <= #bytes do
            if bytes:byte(position) ~= 255 then return nil, nil, "Invalid JPEG header" end
            local marker = bytes:byte(position + 1)
            if marker == 255 then position = position + 1
            elseif marker == 216 or marker == 1 or (marker >= 208 and marker <= 215) then
                position = position + 2
            else
                local length = integer(bytes, position + 2, 2)
                if not length or length < 2 then break end
                if marker >= 192 and marker <= 207 and marker ~= 196 and marker ~= 200 and marker ~= 204 then
                    return integer(bytes, position + 7, 2), integer(bytes, position + 5, 2)
                end
                if marker == 218 or marker == 217 then break end
                position = position + length + 2
            end
        end
        return nil, nil, "JPEG header too long; use PNG"
    end
    return nil, nil, "Unsupported image header"
end

local function collectResources()
    if type(collectgarbage) == "function" then pcall(collectgarbage, "collect") end
end

local function memory()
    local ok, result = pcall(system.getMemoryUsage)
    if ok and type(result) == "table" then return result end
    return {}
end

local function memorySnapshot(widget)
    if not validWidget(widget) then return end
    local m = memory()
    print(string.format("GasDeck %s LuaFree=%s BitmapFree=%s Image=%s Pixels=%s",
        VERSION, tostring(m.luaRamAvailable), tostring(m.luaBitmapsRamAvailable),
        widget.loadedImagePath or "-", tostring(widget.imagePixels or 0)))
end

local function updateResources(widget)
    local requested = widget.imageName
    if widget.imageMode == 1 then
        local ok, name = pcall(model.bitmap)
        requested = ok and name or ""
    elseif widget.imageMode == 3 then requested = "" end
    local path = imagePath(requested)
    if widget.loadedImagePath ~= path then widget.imageDirty = true end
    if widget.imageDirty then
        widget.modelImage, widget.imageError, widget.imagePixels = nil, nil, 0
        widget.imageDirty, widget.loadedImagePath = false, path
        widget.refresh = true
        collectResources()
        if path ~= "" then
            local width, height, problem = imageSize(header(path, 4096))
            if not width or not height or width < 1 or height < 1 then
                widget.imageError = problem or "Invalid image dimensions"
            elseif width > 800 or height > 480 or width * height > MAX_IMAGE_PIXELS then
                widget.imageError = "Max 160k pixels; try 290x191"
            else
                widget.imagePixels, widget.imageWidth, widget.imageHeight = width * height, width, height
                widget.modelImage = BITMAP_CACHE[path]
                if not widget.modelImage then
                    local available = memory().luaBitmapsRamAvailable
                    -- Allow for transparency/decoder overhead and leave a reserve.
                    if finite(available) and available < width * height * 4 + BITMAP_RESERVE then
                        widget.imageError = "Not enough bitmap memory"
                    else
                        local ok, bitmap = pcall(lcd.loadBitmap, path, false)
                        if ok and bitmap then
                            widget.modelImage, BITMAP_CACHE[path] = bitmap, bitmap
                        else widget.imageError = "Image could not be decoded" end
                    end
                end
            end
            if widget.imageError then print("GasDeck: " .. widget.imageError .. " [" .. path .. "]") end
        end
    end
    if widget.fontDirty then
        widget.valueFont, widget.fontDirty = nil, false
        collectResources()
        if widget.fontPath ~= "" then
            local available = memory().luaRamAvailable
            if not finite(available) or available > 131072 then
                local ok, font = pcall(lcd.loadFont, widget.fontPath)
                if ok and finite(font) then widget.valueFont = font end
            end
        end
    end
end

local function normalizeAudioFolder(folder)
    folder = type(folder) == "string" and folder or ""
    folder = folder:gsub("\\", "/"):gsub("/+$", "")
    if folder == "" then return "/audio" end
    if folder:sub(1, 1) ~= "/" and not folder:match("^%a+:") then folder = "/" .. folder end
    return folder
end

local function audioPath(folder, filename)
    if type(filename) ~= "string" or filename == "" then return "" end
    filename = filename:gsub("\\", "/")
    local path = filename
    if filename:sub(1, 1) ~= "/" and not filename:match("^%a+:") then
        path = normalizeAudioFolder(folder) .. "/" .. filename
    end
    if not path:lower():match("%.wav$") then path = path .. ".wav" end
    return path
end

local function audioInfo(path)
    local bytes = header(path, 4096)
    if not bytes or bytes:sub(1, 4) ~= "RIFF" or bytes:sub(9, 12) ~= "WAVE" then return nil end
    local position, rate, valid = 13, nil, false
    while position + 7 <= #bytes do
        local kind = bytes:sub(position, position + 3)
        local length = integer(bytes, position + 4, 4, true)
        if not length then return nil end
        if kind == "fmt " and length >= 16 then
            valid = integer(bytes, position + 8, 2, true) == 1
                and integer(bytes, position + 10, 2, true) == 1
                and integer(bytes, position + 12, 4, true) == 32000
                and integer(bytes, position + 22, 2, true) == 16
            rate = integer(bytes, position + 16, 4, true)
        elseif kind == "data" then
            if valid and rate == 64000 and length > 0 then return length / rate end
            return nil
        end
        position = position + 8 + length + length % 2
    end
end


local function switchOn(source)
    local category
    source, category = selectedSource(source)
    if not source then return false end
    -- Always on is unconditional, not a positive analog value.
    if CATEGORY_ALWAYS_ON ~= nil and category == CATEGORY_ALWAYS_ON then return true, true end
    local ok, value = pcall(function() return source:value() end)
    if not ok then return false, nil end
    -- Generic state() is validity for some sources: valid does not imply ON.
    return value == true or (finite(value) and value > 0), value
end

local function throttlePercent(widget)
    local value = sample(widget.throttleSource, "control")
    if value == nil then return nil end
    return clamp((value - widget.throttleMinimum) * 100
        / math.max(1, widget.throttleMaximum - widget.throttleMinimum), 0, 100), value
end

local function counterRecord(session, bytes)
    if not bytes then return nil end
    local identity, sequence, count, check = bytes:match("^GD2|(%x+)|(%d+)|(%d+)|(%d+)\n$")
    if not identity then return nil end
    local body = "GD2|" .. identity .. "|" .. sequence .. "|" .. count .. "|"
    if tonumber(check) ~= digest(body) then return nil end
    if identity ~= session.identity then session.storeBlocked = true; return nil end
    sequence, count = tonumber(sequence), tonumber(count)
    if not sequence or sequence > 1000000000 or not count or count > 999999 then return nil end
    return {sequence = sequence, count = count}
end

local function newSession(key)
    local session = {key = key, identity = identityHex(key), count = 0, sequence = 0,
        revision = 0, retryAt = 0, attempts = 0}
    session.basePath = "/scripts/gd" .. string.format("%08x", digest(key))
    local aBytes, bBytes = header(session.basePath .. "a.dat", 1024), header(session.basePath .. "b.dat", 1024)
    local a, b = counterRecord(session, aBytes), counterRecord(session, bBytes)
    local latest = a
    if b and (not a or b.sequence > a.sequence) then latest = b end
    if latest then session.count, session.sequence = latest.count, latest.sequence
    elseif aBytes or bBytes then session.storeBlocked = true end
    if session.storeBlocked then session.error = "Counter file invalid" end
    return session
end

-- Two alternating, checked slots retain the last valid count across an interrupted
-- write/reset. Only the tiny counter is persisted; all graphs and stats stay in RAM.
local function saveCounter(session)
    if session.storeBlocked then return false end
    local sequence = session.sequence + 1
    local body = "GD2|" .. session.identity .. "|" .. sequence .. "|" .. session.count .. "|"
    local bytes = body .. digest(body) .. "\n"
    local path = session.basePath .. (sequence % 2 == 1 and "a.dat" or "b.dat")
    local ok, handle = pcall(io.open, path, "w")
    if not ok or not handle then session.error = "Counter save failed"; return false end
    local wrote = pcall(io.write, handle, bytes)
    local closed = pcall(io.close, handle)
    if wrote and closed and header(path, 1024) == bytes then
        session.sequence, session.error, session.pending = sequence, nil, false
        return true
    end
    session.error = "Counter save failed"
    return false
end


local function minimum(a,b)
    if a==nil then return b end
    if b==nil then return a end
    return math.min(a,b)
end
local function positive(value)
    return value and value>0 and value or nil
end
local function unitLabel(source)
    local ok,unit=pcall(function() return source:stringUnit() end)
    return ok and type(unit)=="string" and unit:lower():gsub("%s","") or ""
end
-- ETHOS source:value() already applies its decimal precision. Never divide again.
local function volumeReading(source,mode)
    local value=sample(source)
    if not value or value<0 then return nil end
    local unit=unitLabel(source)
    if mode==2 or (mode==1 and unit=="ml") then return value end
    if mode==3 or (mode==1 and (unit=="l" or unit=="litre")) then return value*1000 end
end
local function flowReading(source,mode)
    local value=sample(source)
    if not value or value<0 then return nil end
    local unit=unitLabel(source)
    if mode==2 or (mode==1 and (unit=="ml/m" or unit=="ml/min" or unit=="ml/minute")) then return value end
    if mode==3 or (mode==1 and (unit=="l/m" or unit=="l/min")) then return value*1000 end
    if mode==4 or (mode==1 and unit=="ml/s") then return value*60 end
end
local function temperatureReading(source)
    local value=sample(source)
    if value==nil then return nil end
    local unit=unitLabel(source):gsub("[^a-z]","")
    if unit=="c" or unit=="celsius" then return value end
    if unit=="f" or unit=="fahrenheit" then return (value-32)*5/9 end
end
local function percentReading(source)
    return sample(source, "percent")
end
local function rxBattery(widget,data,index,clock,key)
    local prefix="rx"..index
    local voltage=positive(sample(widget[prefix.."Source"],"voltage"))
    local used=sample(widget[prefix.."UsedSource"],"capacity")
    if used and used<0 then used=nil end
    local trustedUsed,reset=used,false
    if not widget.preview then
        trustedUsed,reset=DeckCore.batteryUsed(widget,prefix,widget[prefix.."UsedSource"],
            widget[prefix.."Source"],voltage,used,widget[prefix.."Capacity"],clock,key)
    end
    data[prefix.."CounterReset"]=reset
    local percent,estimated
    if widget[prefix.."Method"]==1 then
        percent=trustedUsed and clamp((widget[prefix.."Capacity"]-trustedUsed)*100/widget[prefix.."Capacity"],0,100) or nil
    elseif widget[prefix.."Method"]==2 then percent=percentReading(widget[prefix.."PercentSource"])
    else
        local chemistry=TYPES[widget[prefix.."Chemistry"]]
        percent=voltage and clamp((voltage/widget[prefix.."Cells"]-chemistry.empty)
            *100/(chemistry.full-chemistry.empty),0,100) or nil
        estimated=true
    end
    if percent~=nil then percent=round(percent) end -- color/alert agree with displayed integer %
    data[prefix],data[prefix.."Used"],data[prefix.."Percent"],data[prefix.."Estimated"]=voltage,used,percent,estimated
    data[prefix.."Current"]=sample(widget[prefix.."CurrentSource"],"current")
    if percent and percent<=30 and (not estimated or widget.alarmEstimate) then data.rxLow=true end
end
local function ignitionReading(widget)
    local source,category=selectedSource(widget.ignitionSource)
    if not source then return nil,"NOT SET" end
    if CATEGORY_ALWAYS_ON~=nil and category==CATEGORY_ALWAYS_ON then return true,"CMD",true end
    local value=sample(source,"control")
    if value==nil then return nil,category==CATEGORY_TELEMETRY_SENSOR and "SENSOR" or "CMD" end
    return value>widget.ignitionThreshold,category==CATEGORY_TELEMETRY_SENSOR and "SENSOR" or "CMD",value
end
local function fuelSignature(widget,key)
    return table.concat({key or "",widget.fuelMethod,tostring(widget.flowSource),tostring(widget.fuelUsedSource),
        tostring(widget.fuelRemainingSource),widget.tankCapacity,widget.fuelLoaded,widget.fuelBaselineCenti,
        widget.flowUnit,widget.volumeUnit,widget.flowCorrection},"|")
end
local function updateFuel(widget,data,clock,key)
    local signature=fuelSignature(widget,key)
    local state=widget.fuelState
    if not state or state.signature~=signature then
        state={signature=signature,used=0,primed=false}
        widget.fuelState=state
    end
    data.fuelSignature=signature
    data.flow=flowReading(widget.flowSource,widget.flowUnit)
    local remaining
    if widget.fuelMethod==1 then
        local used=volumeReading(widget.fuelUsedSource,widget.volumeUnit)
        local baseline=widget.fuelBaselineCenti/100
        if used~=nil then
            -- A counter reset is not evidence of a refilled tank.
            if used+0.5<baseline or (state.previousUsed and used+0.5<state.previousUsed) then state.uncertain=true end
            state.previousUsed=used
            if not state.uncertain then remaining=clamp(widget.fuelLoaded-math.max(0,used-baseline),0,widget.tankCapacity) end
        end
        data.fuelNote=state.uncertain and "COUNTER RESET: REFUEL" or "CAPACITY - USED / EST"
        data.fuelEstimated=true
    elseif widget.fuelMethod==2 then
        local dt=state.clock and clock-state.clock or 0
        if state.primed and state.clock and (dt<0 or dt>2 or data.flow==nil or state.previousFlow==nil) then
            state.uncertain=true
        end
        if state.primed and not state.uncertain and data.flow~=nil then
            if state.previousFlow~=nil and dt>0 and dt<=2 then
                state.used=state.used+(state.previousFlow+data.flow)/2*dt/60*widget.flowCorrection/100
            end
            remaining=clamp(widget.fuelLoaded-state.used,0,widget.tankCapacity)
        end
        state.clock,state.previousFlow=clock,data.flow
        data.fuelEstimated=true
        data.fuelNote=not state.primed and "REFUEL TO START ESTIMATE"
            or state.uncertain and "FLOW GAP: ESTIMATE LOST" or "INTEGRATED FLOW / EST"
    elseif widget.fuelMethod==3 then
        remaining=volumeReading(widget.fuelRemainingSource,widget.volumeUnit)
        if remaining and remaining>widget.tankCapacity then remaining=nil end
        data.fuelNote="REMAINING VOLUME SENSOR"
    else
        local percent=percentReading(widget.fuelRemainingSource)
        remaining=percent and widget.tankCapacity*percent/100 or nil
        data.fuelNote="REMAINING PERCENT SENSOR"
    end
    if remaining~=nil then state.lastKnown=remaining end
    data.fuelRemaining,data.fuelLastKnown=remaining,state.lastKnown
    data.fuelPercent=remaining and remaining/widget.tankCapacity*100 or nil
    data.fuelLow=data.fuelPercent~=nil and data.fuelPercent<=widget.fuelWarning
end
local function graphSample(flight,clock,data)
    local history=flight.history
    for channel=1,flight.rfCount do
        local value=data["graph"..channel]
        history["low"..channel]=minimum(history["low"..channel],value)
        history["gap"..channel]=history["gap"..channel] or value==nil
    end
    if clock<history.next then return false end
    if history.count==HISTORY_POINTS then
        for channel=1,flight.rfCount do
            local values,gaps=history["rf"..channel],history["missing"..channel]
            for index=1,HISTORY_POINTS/2 do
                local a,b=index*2-1,index*2
                values[index]=minimum(values[a],values[b]);gaps[index]=gaps[a] or gaps[b]
            end
            for index=HISTORY_POINTS/2+1,HISTORY_POINTS do values[index],gaps[index]=nil,nil end
        end
        for index=1,HISTORY_POINTS/2 do history.times[index]=history.times[index*2] end
        for index=HISTORY_POINTS/2+1,HISTORY_POINTS do history.times[index]=nil end
        history.count,history.interval=HISTORY_POINTS/2,history.interval*2
        history.compaction=(history.compaction or 0)+1
    end
    local index=history.count+1
    history.count=index
    for channel=1,flight.rfCount do
        history["rf"..channel][index]=history["low"..channel]
        history["missing"..channel][index]=history["gap"..channel]
        history["low"..channel],history["gap"..channel]=nil,false
    end
    history.times[index]=clock-flight.started
    history.next,history.revision=clock+history.interval,(history.revision or 0)+1
    return true
end
local function completeFlight(session,clock)
    local flight=session and session.current
    if not flight then return end
    flight.elapsed,flight.running=clock-flight.started,false
    if flight.counted then
        session.last=flight
        session.completedSerial=(session.completedSerial or 0)+1
        session.completedAt=clock
    end
    session.current,session.revision=nil,session.revision+1
end
local function safeGroundAction(widget)
    if widget.preview then return false,"Exit preview before changing live state." end
    if not selectedSource(widget.ignitionSource) then return false,"Select a valid ignition source first." end
    local on=ignitionReading(widget)
    if on~=false then return false,"Confirm ignition OFF with valid source first." end
    return true
end
local function acceptRxCounters(widget)
    local safe, problem = safeGroundAction(widget)
    if not safe then return false, problem end
    widget.batteryStates, widget.nextPoll, widget.refresh = nil, 0, true
    return true
end
local function finishFlight(widget)
    local safe,problem=safeGroundAction(widget)
    if not safe then return false,problem end
    local session=widget.flightSession
    if session then completeFlight(session,os.clock()) end
    widget.autoLogDue,widget.refresh=nil,true
    return true
end
local function refuel(widget)
    local safe,problem=safeGroundAction(widget)
    if not safe then return false,problem end
    local used
    if widget.fuelMethod==1 then
        used=volumeReading(widget.fuelUsedSource,widget.volumeUnit)
        if used==nil then return false,"Select a valid fuel-used sensor before refuelling." end
    end
    if widget.fuelMethod==2 and flowReading(widget.flowSource,widget.flowUnit)==nil then
        return false,"Select a valid flow sensor before refuelling."
    end
    finishFlight(widget)
    if used~=nil then widget.fuelBaselineCenti=round(used*100) end
    widget.runtimeModel=modelKey()
    widget.fuelState={signature=fuelSignature(widget,widget.runtimeModel),used=0,primed=true,
        clock=os.clock(),previousFlow=flowReading(widget.flowSource,widget.flowUnit)}
    widget.lastFuelAlert,widget.nextPoll,widget.refresh=nil,0,true
    changed(widget,true)
    return true
end
local function updateFlight(widget,data,clock,key)
    data.throttlePercent,data.throttleRaw=throttlePercent(widget)
    -- Retain the internal armed alias; ignition is the only arm/flight gate.
    data.armed,data.armRaw=data.ignition==true,data.ignitionRaw
    local gate=selectedSource(widget.airborneSource)
    if gate then data.airborne,data.gateRaw=switchOn(gate)
    else data.airborne,data.gateOptional=true,true end
    if not widget.logEnabled or widget.preview or not key then
        if FLIGHT_SESSION and FLIGHT_SESSION.owner==widget then
            FLIGHT_SESSION.owner,FLIGHT_SESSION.lastClock=nil,nil
            if FLIGHT_SESSION.current then FLIGHT_SESSION.current.running=false end
        end
        widget.flightSession=nil
        return
    end
    if not FLIGHT_SESSION or FLIGHT_SESSION.key~=key then FLIGHT_SESSION=newSession(key) end
    local session=FLIGHT_SESSION
    widget.flightSession=session
    if session.owner and session.owner~=widget then data.logState="Shared log";data.logCount=session.count;return end
    session.owner=widget
    local dt=session.lastClock and clamp(clock-session.lastClock,0,1) or 0
    session.lastClock=clock
    local ready=selectedSource(widget.ignitionSource)~=nil and data.ignition~=nil
        and data.throttlePercent~=nil and data.voltage~=nil
    if ready and data.armed and data.airborne and not session.current then
        local flight={started=clock,duration=0,highTime=0,counted=false,rfCount=widget.rfCount,
            rpmCount=widget.rpmCount,tempCount=widget.tempCount,maxRPM={},maxTemp={},rpmSources={},tempSources={},
            fuelSignature=data.fuelSignature,startFuel=data.fuelRemaining,
            history={count=0,interval=1,next=clock+1,times={}}}
        for channel=1,flight.rfCount do
            local source=selectedSource(widget["graph"..channel.."Source"]) or selectedSource(widget["rssi"..channel.."Source"])
            flight["source"..channel]=source
            flight["name"..channel],flight["unit"..channel]=rfDetails(source,"RF"..channel)
            flight.history["rf"..channel],flight.history["missing"..channel]={},{}
        end
        for index=1,4 do
            flight.rpmSources[index],flight.tempSources[index]=widget["rpm"..index.."Source"],widget["temp"..index.."Source"]
            flight["rpmName"..index]=sourceDetails(flight.rpmSources[index],"RPM "..index,"")
            flight["tempName"..index]=sourceDetails(flight.tempSources[index],"TEMP "..index,"")
        end
        session.current=flight;dt=0
    end
    local flight=session.current
    if flight then
        if data.voltage==nil then flight.lossSince=flight.lossSince or clock else flight.lossSince=nil end
        local running=data.armed and ready and data.airborne
        if running then
            local progress=flight.running and dt or 0
            flight.duration=flight.duration+progress
            if data.throttlePercent>=widget.throttleThreshold then flight.highTime=flight.highTime+progress end
            if not flight.counted and flight.duration>=widget.flightMinimum and flight.highTime>=widget.highThrottleSeconds then
                flight.counted=true;session.last=nil
                session.count=math.min(999999,session.count+1)
                session.pending,session.attempts,session.retryAt=true,0,clock
            end
        end
        -- Record active power/fuel/engine peaks through inspection pauses as well.
        for index=1,2 do
            local value=data["rx"..index]
            flight["minRX"..index]=minimum(flight["minRX"..index],value)
            if value then flight["maxRX"..index]=math.max(flight["maxRX"..index] or value,value) end
        end
        if data.current then flight.maxCurrent=math.max(flight.maxCurrent or 0,data.current) end
        if data.flow then flight.maxFlow=math.max(flight.maxFlow or 0,data.flow) end
        for index=1,4 do
            local rpm,temp=data["rpm"..index],data["temp"..index]
            if rpm then flight.maxRPM[index]=math.max(flight.maxRPM[index] or 0,rpm) end
            if temp then flight.maxTemp[index]=math.max(flight.maxTemp[index] or temp,temp) end
        end
        if flight.fuelSignature==data.fuelSignature and data.fuelRemaining~=nil then
            flight.startFuel=flight.startFuel or data.fuelRemaining
            flight.fuelUsed=math.max(flight.fuelUsed or 0,flight.startFuel-data.fuelRemaining)
            flight.fuelRemaining=data.fuelRemaining
        elseif flight.fuelSignature~=data.fuelSignature then flight.fuelGap=true end
        if data.fuelRemaining==nil then flight.fuelGap=true end
        if data.used then
            flight.startRXUsed=flight.startRXUsed or data.used
            flight.rxUsed=math.max(flight.rxUsed or 0,data.used-flight.startRXUsed)
        end
        flight.running=running
        for channel=1,flight.rfCount do flight["minRF"..channel]=minimum(flight["minRF"..channel],data["graph"..channel]) end
        if graphSample(flight,clock,data) then session.revision=session.revision+1 end
        if flight.lossSince and clock-flight.lossSince>=widget.endDelay then completeFlight(session,clock) end
    end
    if session.pending and clock>=session.retryAt and session.attempts<3 then
        session.attempts=session.attempts+1;saveCounter(session);session.retryAt=clock+5
    end
    flight=session.current
    data.logCount=session.count
    data.logShowingLast=session.last~=nil and (not flight or not flight.counted)
    data.logDuration=flight and flight.duration or 0
    data.logHighTime=flight and flight.highTime or 0
    data.logCounted=flight and flight.counted or false
    data.logLossTime=flight and flight.lossSince and clock-flight.lossSince or nil
    data.logState=session.error or (not selectedSource(widget.ignitionSource) and "Choose ignition source")
        or (data.ignition==nil and "Ignition unknown")
        or (not selectedSource(widget.throttleSource) and "Choose throttle")
        or (flight and (flight.lossSince and "Power loss wait" or flight.counted and
            (flight.running and "FLIGHT" or "FLIGHT paused") or (flight.running and "Qualifying" or "Qualify paused")))
        or (session.last and "Session complete") or "Ready"
end
local function cancelAutoLog(widget) widget.autoLogDue=nil end
local function updateAutoLog(widget,data,clock,key)
    local session=widget.flightSession
    if session~=widget.autoLogSession then
        widget.autoLogSession=session;widget.autoLogSeen=session and (session.completedSerial or 0) or 0
        cancelAutoLog(widget)
    end
    if not session or session.key~=key or not widget.logEnabled or widget.preview then cancelAutoLog(widget);return end
    local serial=session.completedSerial or 0
    if serial~=widget.autoLogSeen then
        widget.autoLogSeen=serial
        if widget.autoLogEnabled and session.last and data.voltage==nil then
            widget.autoLogDue=session.completedAt+widget.autoLogDelay
        end
    end
    if not widget.autoLogEnabled or data.voltage~=nil or session.current or not session.last then cancelAutoLog(widget);return end
    if widget.autoLogDue and clock>=widget.autoLogDue then
        cancelAutoLog(widget);widget.logVisible,widget.diagnosticsVisible,widget.refresh=true,false,true
    end
end
local function alerts(widget, data, clock)
    local fuel = DeckCore.alarmReady(widget, "Fuel", data.fuelPercent, widget.fuelWarning, widget.fuelAlarm, clock)
    local rxPercent
    for index = 1, 2 do
        if not data["rx"..index.."Estimated"] or widget.alarmEstimate then
            local value = data["rx"..index.."Percent"]
            if value ~= nil then rxPercent = rxPercent and math.min(rxPercent, value) or value end
        end
    end
    local rx = DeckCore.alarmReady(widget, "RX", rxPercent, 30, widget.rxAlarm, clock)
    -- Critical RX gets the first slot; simultaneous due alarms then alternate.
    local kind = rx and (not fuel or widget.lastAudioKind ~= "RX") and "RX" or fuel and "Fuel" or nil
    if not kind then return end
    local state = kind == "RX" and rx or fuel
    local path = audioPath(widget.audioFolder, kind == "RX" and widget.rxSound or widget.fuelSound)
    widget.soundCache = widget.soundCache or {}
    local cached = widget.soundCache[kind]
    if not cached or cached.path ~= path then
        cached = {path = path, duration = path ~= "" and audioInfo(path) or nil}; widget.soundCache[kind] = cached
    end
    local played = cached.duration and pcall(system.playFile, path)
    if not played then pcall(system.playTone, kind == "Fuel" and 1000 or 1400, 250, 50) end
    DeckCore.alarmPlayed(widget, state, clock, widget.alertInterval, played and cached.duration or 0)
    widget.lastAudioKind = kind
    widget[kind == "Fuel" and "lastFuelAlert" or "lastRxAlert"] = clock
end
local function prepareFlightGraphs(widget, clock)
    local session = widget.flightSession
    local flight = session and ((session.current and session.current.counted and session.current)
        or session.last or session.current)
    local width, height = widget.graphWidth, widget.graphHeight
    if not widget.logVisible or not flight or not width or not height then
        widget.rfGraphs, widget.rfGraphWork = nil, nil
        return false
    end
    local history = flight.history
    local unit1 = flight.unit1 ~= "" and flight.unit1 or "dB"
    local unit3=flight.unit3 or "dB"
    local channelCount=flight.rfCount or 2
    local unit2 = flight.unit2 ~= "" and flight.unit2 or "dB"
    unit1, unit2 = unit1 or "dB", unit2 or "dB"
    local signature = table.concat({width, height, widget.signalMinimum,
        widget.signalMaximum, widget.rfWarnDB, widget.rfCriticalDB,
        widget.rfWarnPercent, widget.rfCriticalPercent, widget.rf1Profile, widget.rf2Profile,
        widget.rf2WarnDB, widget.rf2CriticalDB, widget.rf2WarnPercent, widget.rf2CriticalPercent,
        widget.rf3Profile,widget.rf3WarnDB,widget.rf3CriticalDB,widget.rf3WarnPercent,widget.rf3CriticalPercent,channelCount,unit1, unit2,unit3}, ":")
    local ready, work = widget.rfGraphs, widget.rfGraphWork
    if ready and (ready.flight ~= flight or ready.signature ~= signature) then
        widget.rfGraphs, ready = nil, nil
    end
    local compaction = history.compaction or 0
    if work and (work.flight ~= flight or work.signature ~= signature
        or work.compaction ~= compaction) then
        widget.rfGraphWork, work = nil, nil
    end
    local revision = history.revision or history.count
    local total = math.max(1, math.floor(flight.elapsed or (clock - flight.started)))
    if not work then
        if ready and ready.revision == revision and ready.total == total then return false end
        local sx, sy = width / 800, height / 480
        work = {flight = flight, signature = signature, compaction = compaction,
            revision = revision, total = total, width = width, height = height,
            count = math.min(history.count, HISTORY_POINTS), sampleIndex = 1,
            binIndex = 1, binScale = GRAPH_BINS / total, channels = {}}
        for channel = 1, channelCount do
            local unit = flight["unit"..channel] or "dB"
            local low, high, warning, critical = rfLimits(widget, unit, channel)
            work.channels[channel] = {
                readings = history["rf"..channel],
                missing = history["missing"..channel],
                bins = {}, segments = {},
                minimum = low, maximum = high, warning = warning, critical = critical,
                x = (24+(channel-1)*(752/channelCount+8)) * sx, y = 282 * sy,
                w = (752/channelCount-16) * sx, h = 110 * sy,
                dotX = math.min(sx, 1), dotY = math.min(sy, 1),
            }
        end
        widget.rfGraphWork = work
    end
    if work.sampleIndex <= work.count then
        local last = math.min(work.count, work.sampleIndex + GRAPH_SOURCE_STEPS - 1)
        for index = work.sampleIndex, last do
            local time = history.times[index] or 0
            local bin = math.max(1, math.min(GRAPH_BINS,
                math.floor(time * work.binScale) + 1))
            for channel = 1, channelCount do
                local graph = work.channels[channel]
                local value, missing = graph.readings[index], graph.missing[index]
                local entry = graph.bins[bin]
                if not entry then entry = {}; graph.bins[bin] = entry end
                if value ~= nil and (entry.value == nil or value < entry.value) then
                    entry.value, entry.time = value, time
                end
                entry.gap = entry.gap or value == nil or missing
            end
        end
        work.sampleIndex = last + 1
        return false
    end
    local last = math.min(GRAPH_BINS, work.binIndex + GRAPH_BIN_STEPS - 1)
    for index = work.binIndex, last do
        for channel = 1, channelCount do
            local graph = work.channels[channel]
            local entry = graph.bins[index]
            if entry then
                if entry.value ~= nil then
                    local px = round(graph.x + clamp(entry.time / work.total, 0, 1) * graph.w)
                    local py = round(graph.y + graph.h - clamp((entry.value - graph.minimum)
                        / math.max(1, graph.maximum - graph.minimum), 0, 1) * graph.h)
                    local tone = entry.value <= graph.critical and 3
                        or (entry.value <= graph.warning and 2 or 1)
                    local segments, offset = graph.segments, #graph.segments
                    if graph.previousX and not graph.previousGap and not entry.gap then
                        segments[offset + 1], segments[offset + 2] = graph.previousX, graph.previousY
                        segments[offset + 3], segments[offset + 4] = px, py
                        segments[offset + 6] = 1
                    else
                        segments[offset + 1], segments[offset + 2] =
                            round(px - graph.dotX), round(py - graph.dotY)
                        segments[offset + 3], segments[offset + 4] =
                            round(2 * graph.dotX), round(2 * graph.dotY)
                        segments[offset + 6] = 0
                    end
                    segments[offset + 5] = tone
                    graph.previousX, graph.previousY, graph.previousGap = px, py, entry.gap
                else
                    graph.previousX, graph.previousY, graph.previousGap = nil, nil, true
                end
            end
        end
    end
    work.binIndex = last + 1
    if work.binIndex <= GRAPH_BINS then return false end
    for channel = 1, channelCount do
        local graph = work.channels[channel]
        graph.bins, graph.readings, graph.missing = nil, nil, nil
    end
    widget.rfGraphs, widget.rfGraphWork = work, nil
    return true
end


local function wakeup(widget)
    if not validWidget(widget) then return end
    local clock=os.clock()
    if clock<widget.nextPoll then return end
    widget.nextPoll=clock+0.25
    updateResources(widget)
    local key=modelKey()
    if widget.runtimeModel~=key then
        widget.runtimeModel,widget.fuelState=key,nil
        widget.peakRPM,widget.peakTemp={},{}
        widget.lastFuelAlert,widget.lastRxAlert,widget.audioUntil=nil,nil,nil
        widget.alertStates,widget.batteryStates,widget.metadata,widget.lastAudioKind=nil,nil,nil,nil
    end
    local colors=palette(widget)
    local data=widget.scratch
    for name in pairs(data) do data[name]=nil end
    local ok,name=pcall(model.name)
    data.modelName=ok and name or "GasDeck"
    rxBattery(widget,data,1,clock,key);rxBattery(widget,data,2,clock,key)
    data.current=sample(widget.currentSource,"current")
    data.used=sample(widget.consumptionSource,"capacity")
    if data.used and data.used<0 then data.used=nil end
    data.tx=sample(widget.txSource or widget.builtinTx,"voltage")
    data.timer=sample(widget.timerSource,"timer")
    data.ignition,data.ignitionKind,data.ignitionRaw=ignitionReading(widget)
    if selectedSource(widget.powerSource) then data.voltage=positive(sample(widget.powerSource,"voltage"))
    else data.voltage=data.rx1 or data.rx2 end
    local flight=widget.flightSession and widget.flightSession.key==key and widget.flightSession.current
    for index=1,4 do
        local rpmSource=flight and flight.rpmSources[index] or widget["rpm"..index.."Source"]
        local tempSource=flight and flight.tempSources[index] or widget["temp"..index.."Source"]
        local rpm,temp=sample(rpmSource,"rpm"),temperatureReading(tempSource)
        if rpm and rpm<0 then rpm=nil end
        data["rpm"..index],data["temp"..index]=rpm,temp
        if index<=widget.rpmCount then data["rpmName"..index]=DeckCore.metadata(widget,"RPM"..index,rpmSource,clock,"RPM "..index,"") end
        if index<=widget.tempCount then data["tempName"..index]=DeckCore.metadata(widget,"Temp"..index,tempSource,clock,"TEMP "..index,"") end
        if not widget.preview and rpm then widget.peakRPM[index]=math.max(widget.peakRPM[index] or 0,rpm) end
        if not widget.preview and temp then widget.peakTemp[index]=math.max(widget.peakTemp[index] or temp,temp) end
    end
    for channel=1,3 do
        local source=widget["rssi"..channel.."Source"]
        data["rssi"..channel]=sample(source,"signal")
        if channel<=widget.rfCount then
            data["rssi"..channel.."Name"],data["rssi"..channel.."Unit"]=DeckCore.metadata(widget,"RF"..channel,source,clock,"RF"..channel,"",true)
        end
        local graphSource
        if flight then graphSource=flight["source"..channel]
        else graphSource=selectedSource(widget["graph"..channel.."Source"]) or selectedSource(source) end
        data["graph"..channel]=sample(graphSource,"signal")
    end
    if not widget.preview then updateFuel(widget,data,clock,key) end
    if widget.preview then
        data.rx1,data.rx2,data.rx1Percent,data.rx2Percent=7.8,6.5,78,66
        data.rx1Estimated,data.rx2Estimated=false,false
        data.current,data.used,data.tx,data.timer=1.8,460,7.9,437
        data.ignition,data.ignitionKind=true,"DEMO"
        data.flow,data.fuelRemaining,data.fuelPercent=46.2,widget.tankCapacity*0.62,62
        data.fuelNote,data.fuelLow,data.rxLow="SYNTHETIC PREVIEW",false,false
        for index=1,4 do data["rpm"..index],data["temp"..index]=6820-(index-1)*140,122+(index-1)*5 end
        for channel=1,3 do data["rssi"..channel]=data["rssi"..channel.."Unit"]=="%" and 98 or 81 end
    end
    updateFlight(widget,data,clock,key)
    updateAutoLog(widget,data,clock,key)
    if widget.timerMode==1 and widget.logEnabled and not widget.preview then
        local session=widget.flightSession
        local shown=session and (session.current or session.last)
        data.timer=shown and shown.duration or nil
    end
    data.themeBackground,data.themeForeground,data.themeAccent=colors.background,colors.foreground,colors.accent
    local graphDirty=prepareFlightGraphs(widget,clock)
    local dirty=widget.refresh or graphDirty
    for name,value in pairs(data) do if widget.data[name]~=value then dirty=true end end
    for name in pairs(widget.data) do if data[name]==nil then dirty=true end end
    widget.scratch,widget.data,widget.refresh=widget.data,data,false
    alerts(widget,data,clock)
    if dirty then lcd.invalidate() end
end
local function batteryColor(percent)
    if percent == nil then return COLORS.muted end
    if percent <= 30 then return COLORS.red end
    if percent <= 35 then return COLORS.orange end
    if percent <= 40 then return COLORS.yellow end
    return COLORS.green
end

local function rect(x, y, w, h, color)
    if w <= 0 or h <= 0 then return end
    lcd.color(color)
    lcd.drawFilledRectangle(round(x), round(y), round(w), round(h))
end

local function rounded(x, y, w, h, radius, color)
    radius = math.max(0, math.floor(math.min(radius, w / 2, h / 2)))
    if radius < 1 then rect(x, y, w, h, color); return end
    local left, top, middleX, middleY = round(x), round(y), round(x + radius), round(y + radius)
    local stripX, cornerX, cornerY = round(x + w - radius), round(x + w - radius - 1), round(y + h - radius - 1)
    local innerW, innerH = math.max(0, round(w - 2 * radius)), math.max(0, round(h - 2 * radius))
    lcd.color(color)
    lcd.drawFilledRectangle(middleX, top, innerW, round(h))
    lcd.drawFilledRectangle(left, middleY, radius, innerH)
    lcd.drawFilledRectangle(stripX, middleY, radius, innerH)
    lcd.drawFilledCircle(middleX, middleY, radius)
    lcd.drawFilledCircle(cornerX, middleY, radius)
    lcd.drawFilledCircle(middleX, cornerY, radius)
    lcd.drawFilledCircle(cornerX, cornerY, radius)
end

local function text(x, y, value, width, height, color, align, customFont, small)
    local font, fitted, tw, th = DeckCore.fitText(value, width, height, customFont, small)
    lcd.font(font); lcd.color(color)
    lcd.drawText(round(x), round(math.max(0, math.min(y, SURFACE_HEIGHT - th))), fitted, align or LEFT)
    return tw, th
end

local function valueText(value, decimals, missing)
    if value == nil then return missing or "--" end
    return string.format("%." .. tostring(decimals or 0) .. "f", value)
end

local function timerText(value)
    if value == nil then return "--:--" end
    local seconds = math.floor(math.abs(value))
    local minutes = math.floor(seconds / 60)
    local result
    if minutes <= 99 then
        result = string.format("%02d:%02d", minutes, seconds % 60)
    else
        result = string.format("%dh%02d", math.floor(minutes / 60), minutes % 60)
    end
    return value < 0 and "-" .. result or result
end

local function drawSignal(widget, colors, x, y, value, unit, label, channel, sx, sy)
    text(x, y, label, 148 * sx, 14 * sy, colors.secondary, LEFT, nil, true)
    local low, high, warning, critical = rfLimits(widget, unit, channel)
    local ratio = value and clamp((value - low) / math.max(1, high - low), 0, 1) or 0
    local active = value and math.ceil(ratio * 5) or 0
    local tone = value == nil and colors.secondary or value <= critical and COLORS.red
        or value <= warning and COLORS.yellow or colors.accent
    for bar = 1, 5 do
        local height = (5 + bar * 3) * sy
        rect(x + (104 + (bar - 1) * 7) * sx, y + 35 * sy - height,
            4 * sx, height, bar <= active and tone or colors.track)
    end
    text(x, y + 14 * sy, valueText(value, 0) .. (unit or ""), 99 * sx, 23 * sy, tone)
end

local function drawFlightGraph(widget, colors, flight, channel, x, y, width, height, sx, sy)
    local unit = flight["unit"..channel]
    unit = unit ~= "" and unit or "dB"
    unit = unit or "dB"
    local minimumValue, maximumValue, warning, critical, profile = rfLimits(widget, unit, channel)
    local low = flight["minRF"..channel]
    local name = flight["name"..channel] or "RF" .. channel
    text(x, y - 24 * sy, name .. "  MIN " .. valueText(low, 0) .. unit,
        width, 19 * sy, colors.secondary, LEFT, nil, true)
    rect(x, y, width, height, colors.track)
    if unit ~= "dB" and unit ~= "%" then
        text(x + width / 2, y + height / 2, "Select RSSI (dB) or VFR (%)",
            width - 16 * sx, 18 * sy, colors.secondary, CENTERED, nil, true)
        return
    end
    local range = math.max(1, maximumValue - minimumValue)
    lcd.color(COLORS.yellow)
    local warningY = round(y + height - clamp((warning - minimumValue) / range, 0, 1) * height)
    lcd.drawLine(round(x), warningY, round(x + width), warningY)
    lcd.color(COLORS.red)
    local criticalY = round(y + height - clamp((critical - minimumValue) / range, 0, 1) * height)
    lcd.drawLine(round(x), criticalY, round(x + width), criticalY)
    local ready = widget.rfGraphs
    if ready and (ready.flight ~= flight or ready.width ~= widget.graphWidth
        or ready.height ~= widget.graphHeight) then ready = nil end
    if ready then
        local segments = ready.channels[channel].segments
        local tones = {colors.accent, COLORS.yellow, COLORS.red}
        local previousTone
        -- At most 48 primitives per channel: no history scan or per-point geometry.
        for index = 1, #segments, 6 do
            local tone = tones[segments[index + 4]]
            if tone ~= previousTone then lcd.color(tone); previousTone = tone end
            if segments[index + 5] == 1 then
                lcd.drawLine(segments[index], segments[index + 1],
                    segments[index + 2], segments[index + 3])
            else
                lcd.drawFilledRectangle(segments[index], segments[index + 1],
                    segments[index + 2], segments[index + 3])
            end
        end
    else
        text(x + width / 2, y + height / 2, "Preparing RF trace...",
            width - 16 * sx, 18 * sy, colors.secondary, CENTERED, nil, true)
    end
    local total = ready and ready.total
        or math.max(1, math.floor(flight.elapsed or (os.clock() - flight.started)))
    text(x, y + height + 6 * sy, "0s", 40 * sx, 14 * sy, colors.secondary, LEFT, nil, true)
    text(x + width, y + height + 6 * sy, timerText(total), 80 * sx, 14 * sy,
        colors.secondary, RIGHT, nil, true)
    local limits = unit == "%" and "VFR early " .. warning .. "% / low " .. critical .. "%"
        or profile .. " low " .. warning .. " / crit " .. critical .. " dB"
    text(x, y + height + 23 * sy, limits, width, 14 * sy, colors.secondary, LEFT, nil, true)
end


local function smallBattery(widget,colors,index,sx,sy)
    local data,prefix=widget.data,"rx"..index
    local cx=(index==1 and 607 or 731)*sx
    local percent=data[prefix.."Percent"]
    local color=batteryColor(percent)
    text(cx,116*sy,"RX "..index,112*sx,18*sy,colors.secondary,CENTERED,nil,true)
    local x,y,w,h=cx-29*sx,147*sy,58*sx,86*sy
    rounded(cx-11*sx,y-8*sy,22*sx,6*sy,2*math.min(sx,sy),colors.border)
    rounded(x,y,w,h,8*math.min(sx,sy),colors.border)
    rounded(x+2*sx,y+2*sy,w-4*sx,h-4*sy,6*math.min(sx,sy),colors.background)
    for segment=1,8 do
        local row=y+h-8*sy-segment*8.6*sy
        local fill=percent and clamp(percent/12.5-segment+1,0,1) or 0
        if fill<1 then rect(x+7*sx,row,w-14*sx,6*sy,colors.track) end
        if fill>0 then rect(x+7*sx,row+6*sy*(1-fill),w-14*sx,6*sy*fill,color) end
    end
    text(cx,239*sy,valueText(data[prefix],2).." V",112*sx,26*sy,colors.foreground,CENTERED,widget.valueFont)
    text(cx,269*sy,(data[prefix.."CounterReset"] and widget[prefix.."Method"]==1 and "CHECK mAh"
        or valueText(percent,0).."%"..(data[prefix.."Estimated"] and " EST" or "")),112*sx,21*sy,color,CENTERED)
    text(cx,294*sy,TYPES[widget[prefix.."Chemistry"]].name.." / "..widget[prefix.."Cells"].."S",112*sx,13*sy,
        colors.secondary,CENTERED,nil,true)
end
local function drawRPM(widget,colors,index,x,width,sx,sy)
    local data=widget.data
    local reading=data["rpm"..index]
    text(x,356*sy,data["rpmName"..index] or "RPM "..index,width,15*sy,colors.secondary,LEFT,nil,true)
    text(x+width,376*sy,valueText(reading,0),width,36*sy,colors.foreground,RIGHT,widget.valueFont)
    if widget.meterStyle==1 then
        text(x,429*sy,"MAX "..valueText(widget.peakRPM[index],0).." rpm",width,15*sy,colors.accent,LEFT,nil,true)
        return
    end
    local ratio=reading and clamp(reading/widget.rpmMaximum,0,1) or 0
    local count=width/sx<130 and 12 or 24
    local gap=2*sx
    local segmentWidth=(width-(count-1)*gap)/count
    local activeCount=math.ceil(ratio*count)
    for segment=1,count do
        local position=segment/count*100
        local color=colors.track
        if reading and segment<=activeCount then
            color=position>=widget.redZone and COLORS.red or position>=widget.redZone-10 and COLORS.orange
                or position>=widget.redZone-20 and COLORS.yellow or colors.accent
        end
        local px=x+(segment-1)*(segmentWidth+gap)
        local py=(443-24*(segment/count)^0.8)*sy
        lcd.color(color)
        local left, innerLeft, right, innerRight = round(px), round(px+2*sx), round(px+segmentWidth), round(px+segmentWidth-2*sx)
        local top, bottom = round(py), round(py+12*sy)
        lcd.drawFilledTriangle(innerLeft,top,right,top,left,bottom)
        lcd.drawFilledTriangle(right,top,innerRight,bottom,left,bottom)
    end
    text(x,458*sy,"0",30*sx,12*sy,colors.secondary,LEFT,nil,true)
    text(x+width,458*sy,string.format("%.0fk",widget.rpmMaximum/1000),45*sx,12*sy,colors.secondary,RIGHT,nil,true)
end
local function drawFuel(widget,colors,x,width,sx,sy)
    local data=widget.data
    local color=data.fuelLow and COLORS.red or colors.accent
    text(x,356*sy,"FUEL FLOW",width,15*sy,colors.secondary,LEFT,nil,true)
    text(x+width,375*sy,valueText(data.flow,1).." ml/min",width,26*sy,colors.foreground,RIGHT,widget.valueFont)
    text(x,407*sy,valueText(data.fuelRemaining,0).." ml",width*0.62,26*sy,color,LEFT,widget.valueFont)
    text(x+width,408*sy,valueText(data.fuelPercent,0).."%",width*0.36,26*sy,color,RIGHT,widget.valueFont)
    local count,gap=24,2*sx
    local barWidth=(width-(count-1)*gap)/count
    local reserveCount=math.floor(widget.fuelWarning/100*count)
    local activeCount=data.fuelPercent and math.ceil(data.fuelPercent/100*count) or 0
    for segment=1,count do
        local reserve=segment<=reserveCount
        local active=segment<=activeCount
        rect(x+(segment-1)*(barWidth+gap),440*sy,barWidth,13*sy,
            active and (reserve and COLORS.red or colors.accent) or reserve and COLORS.red or colors.track)
        if reserve and not active then rect(x+(segment-1)*(barWidth+gap),443*sy,barWidth,7*sy,colors.background) end
    end
    text(x,458*sy,"E",20*sx,12*sy,COLORS.red,LEFT,nil,true)
    text(x+width,458*sy,"F",20*sx,12*sy,colors.secondary,RIGHT,nil,true)
end
local function paintFlight(widget,colors,sx,sy)
    local data,session=widget.data,widget.flightSession
    local flight=session and ((session.current and session.current.counted and session.current) or session.last or session.current)
    text(24*sx,15*sy,data.logShowingLast and "LAST FLIGHT LOG" or "FLIGHT LOG",420*sx,29*sy,colors.foreground)
    text(24*sx,52*sy,data.modelName or "GasDeck",490*sx,17*sy,colors.secondary,LEFT,nil,true)
    text(776*sx,16*sy,"FLIGHTS "..tostring(session and session.count or 0),260*sx,32*sy,colors.accent,RIGHT)
    text(776*sx,54*sy,data.logState or "Enable flight log",260*sx,15*sy,colors.secondary,RIGHT,nil,true)
    if not flight then
        text(400*sx,178*sy,"No qualifying flight yet",720*sx,34*sy,colors.foreground,CENTERED)
        text(400*sx,235*sy,"ARM + receiver power + time/throttle gates",720*sx,19*sy,colors.secondary,CENTERED,nil,true)
        text(400*sx,272*sy,"Ignition/ARM off pauses; use Finish flight between sorties.",720*sx,18*sy,colors.secondary,CENTERED,nil,true)
        return
    end
    local labels={"FLIGHT TIME","FUEL USED / MAX FLOW","RX1 / RX2 MIN VOLTS"}
    local values={timerText(flight.duration),valueText(flight.fuelUsed,0).." ml / "..valueText(flight.maxFlow,0).." ml/m",
        valueText(flight.minRX1,2).." / "..valueText(flight.minRX2,2).." V"}
    for index=1,3 do
        local x=(24+(index-1)*254)*sx
        text(x,92*sy,labels[index],238*sx,15*sy,colors.secondary,LEFT,nil,true)
        text(x,115*sy,values[index],238*sx,28*sy,colors.foreground)
    end
    local count=math.max(flight.rpmCount,flight.tempCount,1)
    local width=752/count
    for index=1,count do
        local x=(24+(index-1)*width)*sx
        if index<=flight.rpmCount then
            text(x,158*sy,(flight["rpmName"..index] or "RPM "..index).." MAX",(width-12)*sx,15*sy,colors.secondary,LEFT,nil,true)
            text(x,178*sy,valueText(flight.maxRPM[index],0).." rpm",(width-12)*sx,25*sy,colors.foreground)
        end
        if index<=flight.tempCount then
            local temp=flight.maxTemp[index]
            local shown=widget.tempUnit==2 and temp and temp*9/5+32 or temp
            text(x,214*sy,(flight["tempName"..index] or "TEMP "..index).." MAX",(width-12)*sx,15*sy,colors.secondary,LEFT,nil,true)
            text(x,234*sy,valueText(shown,0)..(widget.tempUnit==2 and " F" or " C"),(width-12)*sx,23*sy,
                temp and temp>=widget.tempCritical and COLORS.red or colors.foreground)
        end
    end
    local graphWidth=752/flight.rfCount-16
    for channel=1,flight.rfCount do
        drawFlightGraph(widget,colors,flight,channel,(24+(channel-1)*(752/flight.rfCount+8))*sx,
            282*sy,graphWidth*sx,110*sy,sx,sy)
    end
    text(24*sx,439*sy,"RX MAX "..valueText(flight.maxCurrent,2).." A   RX USED "..valueText(flight.rxUsed,0).." mAh"
        ..(flight.fuelGap and "   FUEL: DATA GAP" or ""),752*sx,15*sy,colors.secondary,LEFT,nil,true)
    text(24*sx,465*sy,"Menu: Dashboard / Flight diagnostics / Finish flight",752*sx,12*sy,colors.accent,LEFT,nil,true)
end
local function paintDiagnostics(widget,colors,sx,sy)
    local data=widget.data
    text(24*sx,16*sy,"FLIGHT DIAGNOSTICS",580*sx,32*sy,colors.foreground)
    text(24*sx,56*sy,data.modelName or "GasDeck",752*sx,18*sy,colors.secondary,LEFT,nil,true)
    local reason=not widget.logEnabled and "LOG DISABLED" or widget.preview and "PREVIEW: NO FLIGHT COUNT"
        or data.voltage==nil and "NO VALID RX / POWER VOLTAGE"
        or data.ignition==nil and "IGNITION UNKNOWN: SESSION PAUSED"
        or not data.armed and "IGNITION OFF: SESSION PAUSED"
        or not data.airborne and "AIRBORNE GATE OFF" or data.throttlePercent==nil and "SELECT VALID THROTTLE"
        or data.logCounted and "FLIGHT COUNTED" or "QUALIFYING: TIME + HIGH THROTTLE"
    rounded(24*sx,91*sy,752*sx,40*sy,5*math.min(sx,sy),colors.track)
    text(40*sx,100*sy,reason,720*sx,24*sy,colors.accent)
    local labels={"THROTTLE API RAW","THROTTLE 0-100%","CALIBRATION RAW","IGNITION","AIRBORNE GATE","RECEIVER POWER"}
    local values={valueText(data.throttleRaw,1),valueText(data.throttlePercent,1).."%",
        widget.throttleMinimum.." / "..widget.throttleMaximum,
        data.ignition==nil and "UNKNOWN" or data.armed and "ON / PASS" or "OFF / BLOCK",data.airborne and "PASS" or "BLOCK",valueText(data.voltage,2).." V"}
    for index=1,6 do
        local x=(24+((index-1)%3)*254)*sx
        local y=(166+math.floor((index-1)/3)*102)*sy
        text(x,y,labels[index],238*sx,18*sy,colors.secondary,LEFT,nil,true)
        text(x,y+29*sy,values[index],238*sx,35*sy,colors.foreground)
    end
    text(24*sx,381*sy,"QUALIFY "..valueText(data.logDuration,1).." / "..widget.flightMinimum.." s",355*sx,26*sy,colors.foreground)
    text(425*sx,381*sy,"HIGH THROTTLE "..valueText(data.logHighTime,1).." / "..widget.highThrottleSeconds.." s",351*sx,26*sy,colors.foreground)
    text(24*sx,436*sy,"Both RX feeds missing ends session; ignition OFF only pauses the session.",752*sx,16*sy,colors.secondary,LEFT,nil,true)
    text(24*sx,465*sy,"Bench filtering is not an airborne detector. Ignition indication never controls engine.",752*sx,12*sy,colors.accent,LEFT,nil,true)
end
local function paint(widget)
    if not validWidget(widget) then return end
    local width,height=lcd.getWindowSize()
    if not finite(width) or not finite(height) or width<=0 or height<=0 then return end
    SURFACE_WIDTH,SURFACE_HEIGHT=width,height
    local sx,sy=width/800,height/480
    local colors,data=palette(widget),widget.data
    rect(0,0,width,height,colors.background)
    widget.graphWidth,widget.graphHeight=width,height
    if widget.diagnosticsVisible then paintDiagnostics(widget,colors,sx,sy);return end
    if widget.logVisible then paintFlight(widget,colors,sx,sy);return end
    text(24*sx,9*sy,"MODEL",286*sx,17*sy,colors.secondary,LEFT,nil,true)
    text(24*sx,30*sy,data.modelName or "GasDeck",292*sx,39*sy,colors.foreground,LEFT,widget.valueFont)
    text(24*sx,78*sy,(widget.engineBrand~="" and widget.engineBrand.." / " or "")
        ..widget.engineCC.." cc"..(widget.engineCount>1 and " / "..widget.engineCount.." engines" or ""),294*sx,17*sy,colors.secondary,LEFT,nil,true)
    for channel=1,widget.rfCount do
        local y=(12+(channel-1)*(widget.rfCount==3 and 29 or 43))*sy
        drawSignal(widget,colors,353*sx,y,data["rssi"..channel],data["rssi"..channel.."Unit"] or "dB",
            data["rssi"..channel.."Name"] or "RF"..channel,channel,sx,widget.rfCount==3 and sy*0.72 or sy)
    end
    local ignitionColor=data.ignition==nil and colors.border or data.ignition and COLORS.green or COLORS.red
    local ignitionFill=data.ignition==nil and COLORS.ignitionUnknown
        or data.ignition and COLORS.ignitionOn or COLORS.ignitionOff
    rounded(525*sx,14*sy,94*sx,44*sy,7*math.min(sx,sy),ignitionColor)
    rounded(526*sx,15*sy,92*sx,42*sy,6*math.min(sx,sy),ignitionFill)
    lcd.color(ignitionColor);lcd.drawFilledCircle(round(534*sx),round(26*sy),3*math.min(sx,sy))
    text(580*sx,19*sy,"IGNITION",70*sx,12*sy,COLORS.white,CENTERED,nil,true)
    text(572*sx,34*sy,data.ignition==nil and "--" or data.ignition and "ON" or "OFF",82*sx,20*sy,ignitionColor,CENTERED)
    text(776*sx,23*sy,timerText(data.timer),151*sx,46*sy,colors.foreground,RIGHT,widget.valueFont)
    text(776*sx,78*sy,"FLIGHT TIME",151*sx,16*sy,colors.secondary,RIGHT,nil,true)
    text(572*sx,69*sy,"TX "..valueText(data.tx,1).." V",94*sx,26*sy,colors.foreground,CENTERED)
    rect(24*sx,103*sy,752*sx,1*sy,colors.border)
    if widget.modelImage then
        local factor=math.min(277*sx/widget.imageWidth,156*sy/widget.imageHeight)
        local w,h=widget.imageWidth*factor,widget.imageHeight*factor
        lcd.drawBitmap(round(24*sx+(277*sx-w)/2),round(116*sy+(156*sy-h)/2),widget.modelImage,round(w),round(h))
    else
        rounded(24*sx,122*sy,277*sx,139*sy,10*math.min(sx,sy),colors.track)
        text(162*sx,172*sy,widget.imageError or "MODEL IMAGE",249*sx,22*sy,colors.secondary,CENTERED,nil,true)
    end
    text(329*sx,127*sy,"RX CURRENT",198*sx,16*sy,colors.secondary,LEFT,nil,true)
    text(329*sx,151*sy,valueText(data.current,2).." A",198*sx,38*sy,colors.foreground,LEFT,widget.valueFont)
    text(329*sx,204*sy,"RX CONSUMED",198*sx,16*sy,colors.secondary,LEFT,nil,true)
    text(329*sx,228*sy,valueText(data.used,0).." mAh",198*sx,34*sy,colors.foreground,LEFT,widget.valueFont)
    text(329*sx,276*sy,"FUEL "..valueText(data.fuelPercent,0).."%",198*sx,22*sy,data.fuelLow and COLORS.red or colors.accent)
    smallBattery(widget,colors,1,sx,sy);smallBattery(widget,colors,2,sx,sy)
    rect(24*sx,313*sy,752*sx,1*sy,colors.border)
    for index=1,widget.tempCount do
        local boxWidth=752/widget.tempCount
        local x=(24+(index-1)*boxWidth)*sx
        local value=data["temp"..index]
        local shown=widget.tempUnit==2 and value and value*9/5+32 or value
        local tone=value and (value>=widget.tempCritical and COLORS.red or value>=widget.tempWarning and COLORS.yellow)
            or colors.foreground
        text(x,321*sy,data["tempName"..index] or "TEMP "..index,(boxWidth-14)*sx*0.56,17*sy,colors.secondary,LEFT,nil,true)
        text(x+(boxWidth-14)*sx,318*sy,valueText(shown,0)..(widget.tempUnit==2 and " F" or " C"),
            (boxWidth-14)*sx*0.42,27*sy,tone,RIGHT,widget.valueFont)
    end
    if widget.rpmCount>0 then
        local boxWidth=472/widget.rpmCount
        for index=1,widget.rpmCount do drawRPM(widget,colors,index,(24+(index-1)*boxWidth)*sx,(boxWidth-15)*sx,sx,sy) end
        drawFuel(widget,colors,520*sx,256*sx,sx,sy)
    else drawFuel(widget,colors,24*sx,752*sx,sx,sy) end
    local footer=widget.preview and "SYNTHETIC PREVIEW / NO ALERTS OR FLIGHT COUNT"
        or ((data.rx1CounterReset and widget.rx1Method==1) or (data.rx2CounterReset and widget.rx2Method==1)) and "RX COUNTER RESET: CHECK BATTERY"
        or data.fuelLow and "LOW FUEL" or data.rxLow and "LOW RX BATTERY" or data.fuelNote or "SELECT TELEMETRY"
    text(24*sx,299*sy,footer,520*sx,12*sy,colors.secondary,LEFT,nil,true)
end

local function numberField(widget,label,key,low,high,suffix,step)
    local definition=SETTING_MAP[key]
    if definition and definition[3] then low,high=definition[3],definition[4] end
    local line=form.addLine(label,widget.configPanel)
    local field=form.addNumberField(line,nil,low,high,function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=value
        if key=="signalMinimum" then widget.signalMaximum=math.max(value+1,widget.signalMaximum) end
        if key=="signalMaximum" then widget.signalMinimum=math.min(value-1,widget.signalMinimum) end
        if key=="throttleMinimum" then widget.throttleMaximum=math.max(value+1,widget.throttleMaximum) end
        if key=="throttleMaximum" then widget.throttleMinimum=math.min(value-1,widget.throttleMinimum) end
        if key=="tempWarning" then widget.tempCritical=math.max(value,widget.tempCritical) end
        if key=="tempCritical" then widget.tempWarning=math.min(value,widget.tempWarning) end
        if key=="tankCapacity" then widget.fuelLoaded=math.min(value,widget.fuelLoaded) end
        if key=="fuelLoaded" then widget.fuelLoaded=math.min(value,widget.tankCapacity) end
        for channel=1,3 do
            local prefix=channel==1 and "rf" or "rf"..channel
            for _,unit in ipairs({"DB","Percent"}) do
                if key==prefix.."Warn"..unit then
                    widget[prefix.."Critical"..unit]=math.min(value,widget[prefix.."Critical"..unit])
                    widget["rf"..channel.."Profile"]=3
                elseif key==prefix.."Critical"..unit then
                    widget[prefix.."Warn"..unit]=math.max(value,widget[prefix.."Warn"..unit])
                    widget["rf"..channel.."Profile"]=3
                end
            end
        end
        changed(widget,true)
    end)
    if suffix then field:suffix(suffix) end
    if step then field:step(step) end
end
local function choiceField(widget,label,key,choices)
    local line=form.addLine(label,widget.configPanel)
    form.addChoiceField(line,nil,choices,function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=value;changed(widget,true) end)
end
local function colorField(widget,label,key)
    local line=form.addLine(label,widget.configPanel)
    form.addColorField(line,nil,function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=value;changed(widget) end)
end
local function showProblem(message)
    form.openDialog({title="GasDeck",message=message,buttons={{label="OK",action=function() return true end}}})
end
local function askAction(widget,action,title,message)
    if not validWidget(widget) then return end
    local safe,problem=safeGroundAction(widget)
    if not safe then showProblem(problem);return end
    local key=modelKey()
    form.openDialog({title=title,message=message,buttons={{label="Cancel",action=function() return true end},
        {label="Confirm",action=function()
            if not validWidget(widget) or modelKey()~=key then return true end
            local ok,reason=action(widget)
            if not ok then print("GasDeck: "..tostring(reason));return false end
            lcd.invalidate();return true
        end}}})
end
local function configure(widget)
    if not validWidget(widget) then return end
    cancelAutoLog(widget)
    widget.configPanel=nil
    form.addLine("GasDeck "..VERSION)
    local function group(label)
        widget.configPanel=form.addExpansionPanel(label);widget.configPanel:open(false)
    end
    local function note(message)
        local line=form.addLine("",widget.configPanel)
        local ok,width=pcall(form.width)
        form.addStaticText(line,{x=10,y=0,w=ok and width-20 or 720,h=30},message)
    end
    local function boolean(label,key)
        local line=form.addLine(label,widget.configPanel)
        form.addBooleanField(line,nil,function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=value;cancelAutoLog(widget);changed(widget,true)
        end)
    end
    local function sourceField(label,key)
        local line=form.addLine(label,widget.configPanel)
        form.addSourceField(line,nil,function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=selectedSource(value);changed(widget,true)
        end)
    end
    local function stringField(label,key,dirty)
        local line=form.addLine(label,widget.configPanel)
        form.addTextField(line,nil,function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=(value or ""):sub(1,256)
            if dirty then widget[dirty]=true end
            changed(widget,true)
        end)
    end
    if widget.configError then note(widget.configError) end
    note("Owner radio test passed: 2026-10-05.")
    note("Per-model settings: gc*.cfg / counters: gd*.dat")
    group("Model / appearance")
    stringField("Engine brand","engineBrand")
    numberField(widget,"Displacement","engineCC",0,1000,"cc",1)
    numberField(widget,"Engine count","engineCount",1,4,nil,1)
    choiceField(widget,"Background","backgroundMode",{{"Radio theme",1},{"Black",2},{"Custom",3}})
    colorField(widget,"Background color","backgroundColor");colorField(widget,"Accent color","accentColor")
    stringField("Font file","fontPath","fontDirty")
    choiceField(widget,"Image source","imageMode",{{"Selected model",1},{"Image file",2},{"Hidden",3}})
    local line=form.addLine("Image file",widget.configPanel)
    form.addFileField(line,nil,"/bitmaps/models","image+ext",function() return widget.imageName end,
        function(value) if not validWidget(widget) then return end; widget.imageName=value or "";widget.imageDirty=true;changed(widget) end)
    note("Reuses model image; native instruments need no art.")
    note("PNG RGB/RGBA 8-bit; <=160k pixels; 290x191 ideal.")
    for index=1,2 do
        local prefix="rx"..index
        group("RX battery "..index)
        choiceField(widget,"Chemistry",prefix.."Chemistry",{{"LiPo",1},{"LiFe",2}})
        numberField(widget,"Cells",prefix.."Cells",1,8,nil,1)
        numberField(widget,"Capacity",prefix.."Capacity",100,20000,"mAh",50)
        choiceField(widget,"Remaining from",prefix.."Method",{{"Consumed mAh",1},{"Percent sensor",2},{"Voltage estimate",3}})
        sourceField("Voltage source",prefix.."Source")
        sourceField("Consumed mAh",prefix.."UsedSource")
        sourceField("Percent source",prefix.."PercentSource")
        sourceField("Current source",prefix.."CurrentSource")
        note("Individual % needs individual consumption/sensor.")
        note("Counter decrease: unknown until loss or confirmation.")
        note("Do not assign combined mAh to both batteries.")
        note("Voltage % is rough, especially on flat LiFe curve.")
    end
    group("RX / ignition")
    sourceField("RX total current","currentSource")
    sourceField("RX total consumed","consumptionSource")
    sourceField("Ignition status","ignitionSource")
    numberField(widget,"Ignition ON above","ignitionThreshold",-2048,2048,nil,1)
    sourceField("TX voltage","txSource")
    note("Switch/command does not prove ignition is powered.")
    note("A status sensor can report ignition; widget is read-only.")
    group("AES engine sensors")
    numberField(widget,"RPM displays","rpmCount",0,4,nil,1)
    numberField(widget,"Temp displays","tempCount",0,4,nil,1)
    for index=1,4 do sourceField("RPM "..index.." source","rpm"..index.."Source") end
    for index=1,4 do sourceField("Temp "..index.." source","temp"..index.."Source") end
    choiceField(widget,"RPM style","meterStyle",{{"Numeric",1},{"Retro LCD",2}})
    numberField(widget,"RPM scale max","rpmMaximum",1000,100000,"rpm",500)
    numberField(widget,"RPM red zone","redZone",10,100,"%",1)
    choiceField(widget,"Temperature unit","tempUnit",{{"Celsius",1},{"Fahrenheit",2}})
    numberField(widget,"Temp warning","tempWarning",30,300,"C",1)
    numberField(widget,"Temp critical","tempCritical",31,350,"C",1)
    note("Temperature limits are examples: set for your engine.")
    note("AES II has 4 RPM / 7 temp inputs; display up to 4.")
    group("Fuel / flowmeter")
    choiceField(widget,"Tank value from","fuelMethod",{{"Capacity - consumed",1},{"Integrate flow",2},{"Remaining volume",3},{"Remaining percent",4}})
    numberField(widget,"Tank capacity","tankCapacity",10,20000,"ml",10)
    numberField(widget,"Refill amount","fuelLoaded",10,20000,"ml",10)
    sourceField("Flow source","flowSource");sourceField("Fuel used source","fuelUsedSource")
    sourceField("Remaining source","fuelRemainingSource")
    choiceField(widget,"Flow input units","flowUnit",{{"Auto",1},{"ml/min",2},{"L/min",3},{"ml/s",4}})
    choiceField(widget,"Volume input units","volumeUnit",{{"Auto",1},{"ml",2},{"L",3}})
    numberField(widget,"Flow calibration","flowCorrection",10,300,"%",1)
    numberField(widget,"Reserve / warning","fuelWarning",1,50,"%",1)
    note("Auto accepts sensor ml, ml/m (ml/min), L or L/min.")
    note("Flow integration needs Refuel after each radio restart.")
    note("A >2s gap invalidates integration until refuelling.")
    note("Consumption reset is not treated as a full tank.")
    note("Calibration applies only to integrated flow.")
    line=form.addLine("Confirm refuel",widget.configPanel)
    form.addButton(line,nil,{text="Refuel...",press=function()
        askAction(widget,refuel,"Confirm fuel loaded?",tostring(widget.fuelLoaded).." ml. Ignition must be confirmed OFF.")
    end})
    group("Alerts")
    boolean("Low fuel alert","fuelAlarm");boolean("Low RX alert","rxAlarm")
    boolean("Alert RX estimate","alarmEstimate")
    numberField(widget,"Repeat interval","alertInterval",1,600,"s",1)
    stringField("Audio folder","audioFolder")
    for _,definition in ipairs({{"Fuel WAV","fuelSound"},{"RX battery WAV","rxSound"}}) do
        local label,key=definition[1],definition[2]
        line=form.addLine(label,widget.configPanel)
        local folder=normalizeAudioFolder(widget.audioFolder)
        form.addFileField(line,nil,folder,"audio+ext",function() return widget[key] end,function(value) if not validWidget(widget) then return end; widget[key]=audioPath(folder,value);changed(widget,true)
        end)
    end
    note("PCM WAV: 32kHz, mono, 16-bit; invalid file uses tone.")
    note("RX alarm <=30%; fuel uses configured reserve %.")
    group("RF sources / limits")
    numberField(widget,"RF displays","rfCount",1,3,nil,1)
    numberField(widget,"RSSI scale min","signalMinimum",-150,199,"dB",1)
    numberField(widget,"RSSI scale max","signalMaximum",-149,200,"dB",1)
    for channel=1,3 do
        local prefix=channel==1 and "rf" or "rf"..channel
        sourceField("RF "..channel.." source","rssi"..channel.."Source")
        sourceField("Log RF "..channel.." source","graph"..channel.."Source")
        choiceField(widget,"RF "..channel.." profile","rf"..channel.."Profile",{{"ACCESS / TD / TW",1},{"ACCST",2},{"Custom",3}})
        numberField(widget,"RF "..channel.." low RSSI",prefix.."WarnDB",-149,200,"dB",1)
        numberField(widget,"RF "..channel.." critical RSSI",prefix.."CriticalDB",-150,199,"dB",1)
        numberField(widget,"RF "..channel.." early VFR",prefix.."WarnPercent",1,100,"%",1)
        numberField(widget,"RF "..channel.." low VFR",prefix.."CriticalPercent",0,99,"%",1)
    end
    note("3 antennas do not imply 3 independent RF sensors.")
    note("Log source blank = dashboard source; names/units follow.")
    note("VFR 95/50% are visual warnings, not radio alarms.")
    group("Flight session")
    boolean("Enable log","logEnabled")
    sourceField("Throttle source","throttleSource")
    note("Ignition status is the only arm/flight gate.")
    sourceField("Airborne gate","airborneSource");sourceField("Power loss source","powerSource")
    numberField(widget,"Throttle low (raw)","throttleMinimum",-2048,2047,nil,1)
    numberField(widget,"Throttle high (raw)","throttleMaximum",-2047,2048,nil,1)
    numberField(widget,"Flight minimum","flightMinimum",60,3600,"s",10)
    numberField(widget,"Throttle gate","throttleThreshold",10,100,"%",1)
    numberField(widget,"High throttle time","highThrottleSeconds",1,120,"s",1)
    numberField(widget,"Power loss delay","endDelay",3,120,"s",1)
    boolean("Auto-open log","autoLogEnabled")
    numberField(widget,"Extra log delay","autoLogDelay",0,120,"s",1)
    choiceField(widget,"Flight time from","timerMode",{{"GasDeck flight session",1},{"ETHOS timer",2}})
    sourceField("ETHOS timer","timerSource")
    note("Default power = either valid RX1 or RX2 voltage.")
    note("Ignition OFF pauses; one count per qualified session.")
    note("Finish flight / Refuel requires valid ignition OFF.")
    note("Last log stays until next flight qualifies.")
    note("Long RF loss can resemble power loss; not a detector.")
    note("Only count persists; last log/graphs stay in RAM.")
    line=form.addLine("Finish session",widget.configPanel)
    form.addButton(line,nil,{text="Finish flight...",press=function()
        askAction(widget,finishFlight,"Finish flight?","Keep the last qualified flight log; Ignition must be OFF.")
    end})
    line=form.addLine("Reset flight count",widget.configPanel)
    form.addButton(line,nil,{text="Reset...",press=function()
        askAction(widget,function(w)
            local safe,problem=safeGroundAction(w)
            if not safe then return false,problem end
            local session=w.flightSession
            if not session or session.current then return false,"Finish the current session first." end
            session.count=0;session.pending,session.attempts,session.retryAt=true,0,0
            w.refresh=true;return true
        end,"Reset model count?",widget.data.modelName or "Current model")
    end})
    group("Preview")
    boolean("Synthetic preview","preview")
    note("Preview never counts flights or plays alerts.")
    widget.configPanel=nil
end
local function destroy(widget)
    if not validWidget(widget) then return end
    widget.destroyed = true
    widget.autoLogSession, widget.autoLogSeen, widget.autoLogDue = nil, nil, nil
    widget.modelImage, widget.valueFont, widget.flightSession = nil, nil, nil
    widget.fuelState,widget.soundCache,widget.peakRPM,widget.peakTemp=nil,nil,nil,nil
    widget.metadata,widget.batteryStates,widget.alertStates=nil,nil,nil
    widget.rfGraphs, widget.rfGraphWork = nil, nil
    if FLIGHT_SESSION and FLIGHT_SESSION.owner == widget then
        FLIGHT_SESSION.owner, FLIGHT_SESSION.lastClock = nil, nil
        if FLIGHT_SESSION.current then FLIGHT_SESSION.current.running = false end
    end
    collectResources()
end


local function menu(widget)
    if not validWidget(widget) then return {} end
    return {
        {(widget.logVisible or widget.diagnosticsVisible) and "Dashboard" or "Flight log",function()
            if not validWidget(widget) then return end
            cancelAutoLog(widget)
            if widget.diagnosticsVisible then widget.logVisible=false else widget.logVisible=not widget.logVisible end
            widget.diagnosticsVisible,widget.refresh=false,true;lcd.invalidate()
        end},
        {"Flight diagnostics",function()
            if not validWidget(widget) then return end
            cancelAutoLog(widget);widget.diagnosticsVisible,widget.logVisible,widget.refresh=true,false,true;lcd.invalidate()
        end},
        {"Finish flight...",function()
            if not validWidget(widget) then return end
            askAction(widget,finishFlight,"Finish flight?","Keep qualified log. Ignition must be OFF.") end},
        {"Refuel...",function()
            if not validWidget(widget) then return end
            askAction(widget,refuel,"Confirm fuel loaded?",tostring(widget.fuelLoaded).." ml. Ignition must be OFF.") end},
        {"Reset live peaks",function()
            if not validWidget(widget) then return end
            widget.peakRPM,widget.peakTemp={},{};changed(widget) end},
        {"Accept RX counters...",function()
            if not validWidget(widget) then return end
            askAction(widget,acceptRxCounters,"Accept RX counters?","Check battery charge and mAh. Ignition must be OFF.") end},
        {"Memory snapshot",function()
            if not validWidget(widget) then return end
            memorySnapshot(widget) end},
    }
end
local function init()
    system.registerWidget({key="gdeck",name="GasDeck",create=create,paint=paint,wakeup=wakeup,
        configure=configure,read=read,write=write,menu=menu,destroy=destroy,persistent=true,title=false})
end
return {init=init}