-- =========================================================================
-- Basepalette helper by Gayapón
-- =========================================================================

-- 1. Helper para obtener rutas seguras permitidas por el sandbox de Aseprite
local userDir = (app.fs and app.fs.userConfigPath) or "."
local tempDir = (app.fs and app.fs.tempPath) or "."

local function safePath(dir, filename)
  if app.fs and app.fs.joinPath then
    local p = app.fs.joinPath(dir, filename)
    return p:gsub("\\", "/")
  elseif dir and dir ~= "." then
    return (dir .. "/" .. filename):gsub("\\", "/")
  end
  return filename
end

-- Matriz exacta de 16x16 para la esfera de sombreado
local templateData = {
  4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
  4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4,
  4, 4, 4, 4, 5, 5, 3, 3, 3, 4, 5, 6, 4, 4, 4, 4,
  4, 4, 4, 5, 4, 2, 2, 2, 3, 3, 4, 5, 7, 4, 4, 4,
  4, 4, 5, 4, 2, 2, 1, 1, 2, 3, 3, 5, 6, 7, 4, 4,
  4, 4, 5, 3, 2, 2, 1, 1, 2, 3, 3, 4, 5, 7, 4, 4,
  4, 6, 4, 3, 2, 2, 2, 2, 2, 3, 3, 4, 5, 5, 8, 4,
  4, 6, 4, 3, 3, 2, 2, 2, 3, 3, 3, 4, 5, 5, 8, 4,
  4, 6, 4, 4, 3, 3, 3, 3, 3, 3, 4, 5, 5, 5, 8, 4,
  4, 7, 5, 4, 4, 3, 3, 3, 3, 4, 5, 5, 5, 7, 8, 4,
  4, 4, 6, 4, 4, 4, 4, 4, 4, 5, 5, 4, 3, 8, 4, 4,
  4, 4, 7, 5, 4, 4, 4, 5, 5, 4, 3, 2, 4, 8, 4, 4,
  4, 4, 4, 7, 6, 5, 4, 4, 3, 3, 2, 4, 8, 4, 4, 4,
  4, 4, 4, 4, 7, 7, 6, 5, 5, 6, 8, 8, 4, 4, 4, 4,
  4, 4, 4, 4, 4, 4, 8, 8, 8, 8, 4, 4, 4, 4, 4, 4,
  4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
}

-- Matriz especial de 16x16 para paletas de 2 colores
local templateData2 = {
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1,
  1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1,
  1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1,
  1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1,
  1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1,
  1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1,
  1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1,
  1, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1,
  1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 2, 1, 1,
  1, 1, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1, 2, 2, 1, 1,
  1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 1, 1,
  1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
}

-- Matriz especial de 16x16 para paletas de 3 colores
local templateData3 = {
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 3, 3, 1, 1, 1, 2, 3, 3, 2, 2, 2, 2,
  2, 2, 2, 3, 2, 1, 1, 1, 1, 1, 2, 3, 3, 2, 2, 2,
  2, 2, 3, 2, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 2, 2,
  2, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 2,
  2, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 2,
  2, 3, 2, 2, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 3, 2,
  2, 3, 2, 2, 2, 1, 1, 1, 1, 2, 3, 3, 3, 3, 3, 2,
  2, 2, 3, 2, 2, 2, 2, 2, 2, 3, 3, 2, 1, 3, 2, 2,
  2, 2, 3, 3, 2, 2, 2, 3, 3, 2, 1, 1, 2, 3, 2, 2,
  2, 2, 2, 3, 3, 3, 2, 2, 1, 1, 1, 2, 3, 2, 2, 2,
  2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
}

-- Matriz especial de 16x16 para paletas de 4 colores (BasePaint)
local templateData4 = {
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 3, 3, 1, 1, 1, 2, 3, 4, 2, 2, 2, 2,
  2, 2, 2, 3, 2, 1, 1, 1, 1, 1, 2, 3, 4, 2, 2, 2,
  2, 2, 3, 2, 1, 1, 1, 1, 1, 1, 1, 3, 3, 4, 2, 2,
  2, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 2, 2,
  2, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 2,
  2, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 2,
  2, 3, 2, 2, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 4, 2,
  2, 3, 2, 2, 2, 1, 1, 1, 1, 2, 3, 3, 3, 3, 4, 2,
  2, 2, 3, 2, 2, 2, 2, 2, 2, 3, 3, 2, 1, 4, 2, 2,
  2, 2, 4, 3, 2, 2, 2, 3, 3, 2, 1, 1, 2, 4, 2, 2,
  2, 2, 2, 4, 3, 2, 2, 2, 2, 1, 1, 2, 4, 2, 2, 2,
  2, 2, 2, 2, 4, 4, 3, 3, 3, 3, 4, 4, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
}

-- Convertir código Hex #RRGGBB a objeto Color de Aseprite
local function hexToColor(hexStr)
  local h = hexStr:gsub("#", "")
  if #h == 6 then
    local r = tonumber(h:sub(1,2), 16) or 255
    local g = tonumber(h:sub(3,4), 16) or 255
    local b = tonumber(h:sub(5,6), 16) or 255
    return Color{ r = r, g = g, b = b, a = 255 }
  end
  return Color{ r = 255, g = 255, b = 255, a = 255 }
end

-- Helper para calcular el valor de luminancia perceptiva CIELAB L* (0 a 1)
local function getLuminanceValue(colorObj)
  local r = (colorObj.red or 255) / 255
  local g = (colorObj.green or 255) / 255
  local b = (colorObj.blue or 255) / 255

  local function cal(c)
    if c <= 0.04045 then
      return c / 12.92
    else
      return ((c + 0.055) / 1.055) ^ 2.4
    end
  end

  local R = cal(r)
  local G = cal(g)
  local B = cal(b)

  local Y = 0.2126 * R + 0.7152 * G + 0.0722 * B

  if Y > 0.008856 then
    return (116 * (Y ^ (1/3)) - 16) / 100
  else
    return Y * 9.033
  end
end

-- Genera rampas organizadas de 8 niveles ordenados por luminancia CIELAB L*
local function generateRampsFromHexes(hexList, themeTitle)
  local uniqueMap = {}
  local uniqueColors = {}

  for _, hex in ipairs(hexList) do
    local cleanHex = hex:lower()
    if not uniqueMap[cleanHex] then
      uniqueMap[cleanHex] = true
      table.insert(uniqueColors, hexToColor(cleanHex))
    end
  end

  -- Ordenar todos los colores por luminancia CIELAB L* (de más claro a más oscuro)
  table.sort(uniqueColors, function(a, b)
    return getLuminanceValue(a) > getLuminanceValue(b)
  end)

  local totalCount = #uniqueColors

  -- Paleta de respaldo cohesiva si no se encuentran colores válidos
  if totalCount == 0 then
    local fallbackHexes = { "#ffffff", "#fff3b0", "#f4d35e", "#ee964b", "#da627d", "#9a031e", "#5f0f40", "#0f051d" }
    local fallbackRamp = {}
    for _, h in ipairs(fallbackHexes) do
      table.insert(fallbackRamp, hexToColor(h))
    end
    return { fallbackRamp }
  end

  if totalCount <= 8 then
    local ramp = {}
    local map = {}
    if totalCount == 1 then
      map = {1, 1, 1, 1, 1, 1, 1, 1}
    elseif totalCount == 2 then
      map = {1, 2, 2, 2, 2, 2, 2, 2}
    elseif totalCount == 3 then
      map = {1, 2, 3, 3, 3, 3, 3, 3}
    elseif totalCount == 4 then
      map = {1, 2, 3, 4, 4, 4, 4, 4}
    elseif totalCount == 5 then
      map = {1, 2, 3, 4, 5, 5, 5, 5}
    elseif totalCount == 6 then
      map = {1, 2, 3, 4, 5, 6, 6, 6}
    elseif totalCount == 7 then
      map = {1, 2, 3, 4, 5, 6, 7, 7}
    elseif totalCount == 8 then
      map = {1, 2, 3, 4, 5, 6, 7, 8}
    end
    for _, idx in ipairs(map) do
      table.insert(ramp, uniqueColors[idx])
    end
    return { ramp }
  end

  -- Si hay más de 8 colores, generar 1 rampa representativa distribuida
  local ramp = {}
  for i = 1, 8 do
    local idx = math.min(math.floor(((i - 1) / 8) * totalCount) + 1, totalCount)
    table.insert(ramp, uniqueColors[idx])
  end
  return { ramp }
end

-- Helper para mezclar 8 colores aleatorios de una paleta mayor a 8 y ordenarlos por luminancia
local function shuffle8FromHexes(hexList)
  local uniqueMap = {}
  local uniqueColors = {}

  for _, hex in ipairs(hexList) do
    local cleanHex = hex:lower()
    if not uniqueMap[cleanHex] then
      uniqueMap[cleanHex] = true
      table.insert(uniqueColors, hexToColor(cleanHex))
    end
  end

  local totalCount = #uniqueColors
  if totalCount <= 8 then
    return generateRampsFromHexes(hexList)
  end

  -- Inicializar semilla aleatoria
  math.randomseed(os.time() + math.random(1, 10000))

  -- Mezclar índices (Fisher-Yates)
  local indices = {}
  for i = 1, totalCount do
    table.insert(indices, i)
  end

  for i = totalCount, 2, -1 do
    local j = math.random(1, i)
    indices[i], indices[j] = indices[j], indices[i]
  end

  -- Tomar los primeros 8 colores aleatorios
  local picked = {}
  for i = 1, 8 do
    table.insert(picked, uniqueColors[indices[i]])
  end

  -- Ordenar por luminancia CIELAB L* (de más claro a más oscuro)
  table.sort(picked, function(a, b)
    return getLuminanceValue(a) > getLuminanceValue(b)
  end)

  return { picked }
end

-- Dibuja el canvas de previsualización de esferas en una ventana flotante de referencia (Visor Puro)
local function displayPreviewAndApply(rampas, title, rawHexes)
  local numRamps = #rampas
  local baseImg = Image(16 * numRamps, 16, ColorMode.RGB)

  for r, rampa in ipairs(rampas) do
    local offsetX = (r - 1) * 16

    -- Detectar si la rampa tiene 4 colores únicos o menos
    local uniqueMap = {}
    local uniqueCount = 0
    for _, col in ipairs(rampa) do
      local hex = string.format("#%02x%02x%02x", col.red or 255, col.green or 255, col.blue or 255)
      if not uniqueMap[hex] then
        uniqueMap[hex] = true
        uniqueCount = uniqueCount + 1
      end
    end
    local activeTemplate = templateData
    if uniqueCount <= 2 then
      activeTemplate = templateData2
    elseif uniqueCount == 3 then
      activeTemplate = templateData3
    elseif uniqueCount == 4 then
      activeTemplate = templateData4
    end

    for y = 0, 15 do
      for x = 0, 15 do
        local val = activeTemplate[(y * 16) + x + 1]
        if val and val > 0 and rampa[val] then
          baseImg:drawPixel(offsetX + x, y, rampa[val])
        end
      end
    end
  end

  local function buildScaledImage(sourceImg, zFactor)
    local scaled = Image(sourceImg.width * zFactor, sourceImg.height * zFactor, ColorMode.RGB)
    for y = 0, sourceImg.height - 1 do
      for x = 0, sourceImg.width - 1 do
        local px = sourceImg:getPixel(x, y)
        for zy = 0, zFactor - 1 do
          for zx = 0, zFactor - 1 do
            scaled:drawPixel((x * zFactor) + zx, (y * zFactor) + zy, px)
          end
        end
      end
    end
    return scaled
  end

  local function buildDistantCompositeImage(sourceImg)
    local s3, s2, s1 = 3, 2, 1
    local gap = 12
    local w3, h3 = sourceImg.width * s3, sourceImg.height * s3
    local w2, h2 = sourceImg.width * s2, sourceImg.height * s2
    local w1, h1 = sourceImg.width * s1, sourceImg.height * s1

    local totalWidth = w3 + gap + w2 + gap + w1
    local totalHeight = h3

    local composite = Image(totalWidth, totalHeight, ColorMode.RGB)

    -- Scale 3 (left, 3x)
    for y = 0, sourceImg.height - 1 do
      for x = 0, sourceImg.width - 1 do
        local px = sourceImg:getPixel(x, y)
        for zy = 0, s3 - 1 do
          for zx = 0, s3 - 1 do
            composite:drawPixel((x * s3) + zx, (y * s3) + zy, px)
          end
        end
      end
    end

    -- Scale 2 (middle, 2x, bottom aligned)
    local xOffset2 = w3 + gap
    local yOffset2 = h3 - h2
    for y = 0, sourceImg.height - 1 do
      for x = 0, sourceImg.width - 1 do
        local px = sourceImg:getPixel(x, y)
        for zy = 0, s2 - 1 do
          for zx = 0, s2 - 1 do
            composite:drawPixel(xOffset2 + (x * s2) + zx, yOffset2 + (y * s2) + zy, px)
          end
        end
      end
    end

    -- Scale 1 (right, 1x, bottom aligned)
    local xOffset1 = w3 + gap + w2 + gap
    local yOffset1 = h3 - h1
    for y = 0, sourceImg.height - 1 do
      for x = 0, sourceImg.width - 1 do
        local px = sourceImg:getPixel(x, y)
        composite:drawPixel(xOffset1 + x, yOffset1 + y, px)
      end
    end

    return composite
  end

  local previewImg = buildScaledImage(baseImg, 8)
  local distantCompositeImg = buildDistantCompositeImage(baseImg)

  local previewDlg = Dialog({ title = title or "BasePaint - Vista Previa / Referencia" })
  
  previewDlg:canvas{
    id = "preview_canvas",
    width = previewImg.width,
    height = previewImg.height,
    onpaint = function(ev)
      if previewImg then
        ev.context:drawImage(previewImg, 0, 0)
      end
    end
  }

  previewDlg:separator{}

  previewDlg:canvas{
    id = "distant_canvas",
    width = distantCompositeImg.width,
    height = distantCompositeImg.height,
    onpaint = function(ev)
      if distantCompositeImg then
        ev.context:drawImage(distantCompositeImg, 0, 0)
      end
    end
  }

  -- Botón Shuffle! para paletas extendidas (> 8 colores)
  if rawHexes and #rawHexes > 8 then
    previewDlg:separator{}
    previewDlg:button{
      id = "btn_shuffle",
      text = "Shuffle!",
      onclick = function()
        local shuffledRampas = shuffle8FromHexes(rawHexes)
        previewDlg:close()
        displayPreviewAndApply(shuffledRampas, title, rawHexes)
      end
    }
  end

  -- Ventana flotante de referencia (se cierra con la cruz de la ventana)
  previewDlg:show{ wait = false }
end

-- =========================================================================
-- HELPERS DE RED PARA BASEPAINT Y ASEPRITE
-- =========================================================================
local decodeOnChainMetadata
local fetchOnChainBasePaint
local fetchTodayBasePaint
local fetchBasePaintDirect
local fetchCurrentAsepritePalette

-- Función para ejecutar comandos cURL de forma totalmente silenciosa en Windows y Unix
local function executeSilent(cmd)
  local isWindows = (package.config:sub(1,1) == "\\")
  if isWindows then
    local batPath = safePath(tempDir, "bp_cmd.bat")
    local vbsPath = safePath(tempDir, "bp_run_silent.vbs")

    local fBat = io.open(batPath, "w")
    if fBat then
      fBat:write("@echo off\n" .. cmd .. "\n")
      fBat:close()
    end

    local fVbs = io.open(vbsPath, "w")
    if fVbs then
      fVbs:write("Set WshShell = CreateObject(\"WScript.Shell\")\n")
      fVbs:write("WshShell.Run \"cmd /c \"\"" .. batPath:gsub("/", "\\") .. "\"\"\", 0, True\n")
      fVbs:close()
    end

    os.execute("wscript //nologo \"" .. vbsPath:gsub("/", "\\") .. "\"")

    pcall(function() os.remove(batPath) end)
    pcall(function() os.remove(vbsPath) end)
  else
    os.execute(cmd .. " > /dev/null 2>&1")
  end
end

-- Decodificador de Metadata On-Chain del contrato BasePaintMetadataRegistry (0x5104482a2Ef3a03b6270D3e931eac890b86FaD01)
decodeOnChainMetadata = function(rawHex)
  if not rawHex then return nil, nil end
  local cleanHex = rawHex:gsub("^0x", ""):gsub("%s+", "")
  if #cleanHex < 64 * 8 then return nil, nil end

  local words = {}
  for i = 1, #cleanHex, 64 do
    table.insert(words, cleanHex:sub(i, i + 63))
  end
  if #words < 8 then return nil, nil end

  -- Word 1 es el offset a la estructura de metadata (0x20 = 32 bytes = 1 palabra)
  local structOffsetBytes = tonumber(words[1], 16) or 32
  local structStartIdx = 1 + math.floor(structOffsetBytes / 32) -- índice 2 en Lua

  -- Nombre del tema (el offset relativo al inicio del struct está en words[structStartIdx])
  local themeName = nil
  local nameOffsetBytes = tonumber(words[structStartIdx], 16)
  if nameOffsetBytes then
    local nameLenIdx = structStartIdx + math.floor(nameOffsetBytes / 32)
    if words[nameLenIdx] then
      local nameLen = tonumber(words[nameLenIdx], 16)
      if nameLen and nameLen > 0 and nameLen < 200 then
        local nameHex = words[nameLenIdx + 1] or ""
        local nameStr = ""
        for byteHex in nameHex:sub(1, nameLen * 2):gmatch("%x%x") do
          local code = tonumber(byteHex, 16)
          if code and code >= 32 and code <= 126 then
            nameStr = nameStr .. string.char(code)
          end
        end
        if nameStr ~= "" then themeName = nameStr end
      end
    end
  end

  -- Paleta de colores uint24[] (el offset relativo al inicio del struct está en words[structStartIdx + 1])
  local hexes = {}
  local palOffsetBytes = tonumber(words[structStartIdx + 1], 16)
  if palOffsetBytes then
    local palLenIdx = structStartIdx + math.floor(palOffsetBytes / 32)
    if words[palLenIdx] then
      local palCount = tonumber(words[palLenIdx], 16)
      if palCount and palCount > 0 and palCount <= 64 then
        for cIdx = 1, palCount do
          local colWord = words[palLenIdx + cIdx]
          if colWord then
            local hex6 = colWord:sub(-6):upper()
            if hex6:match("^%x%x%x%x%x%x$") then
              table.insert(hexes, "#" .. hex6)
            end
          end
        end
      end
    end
  end

  if #hexes > 0 then
    return hexes, themeName
  end
  return nil, nil
end

-- Consulta on-chain a la blockchain Base (BasePaintMetadataRegistry) para el canvas indicado
fetchOnChainBasePaint = function(dayNum)
  local dNum = tonumber(dayNum) or 0
  if dNum <= 0 then return nil, nil end

  local hexDay = string.format("%x", dNum)
  while #hexDay < 64 do
    hexDay = "0" .. hexDay
  end
  local callData = "0xa574cea4" .. hexDay

  local rpcReqFile = safePath(tempDir, "bp_onchain_req.json")
  local rpcResFile = safePath(tempDir, "bp_onchain_res.json")

  local rpcPayload = string.format([[{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "eth_call",
    "params": [{
      "to": "0x5104482a2Ef3a03b6270D3e931eac890b86FaD01",
      "data": "%s"
    }, "latest"]
  }]], callData)

  local reqFile = io.open(rpcReqFile, "w")
  if reqFile then
    reqFile:write(rpcPayload)
    reqFile:close()
  end

  local rpcUrls = { "https://base-rpc.publicnode.com", "https://mainnet.base.org", "https://base.llamarpc.com", "https://1rpc.io/base" }
  for _, rpcUrl in ipairs(rpcUrls) do
    local curlCmd = string.format('curl -s -m 6 -X POST -H "Content-Type: application/json" -d @"%s" "%s" -o "%s"', rpcReqFile, rpcUrl, rpcResFile)
    executeSilent(curlCmd)

    local fRes = io.open(rpcResFile, "r")
    if fRes then
      local jsonText = fRes:read("*all") or ""
      fRes:close()
      pcall(function() os.remove(rpcResFile) end)

      local rawResult = jsonText:match('"result"%s*:%s*"([^"]+)"')
      if rawResult and rawResult:len() > 100 then
        local hexes, themeName = decodeOnChainMetadata(rawResult)
        if hexes and #hexes > 0 then
          pcall(function() os.remove(rpcReqFile) end)
          local title = (themeName and themeName ~= "") and (themeName .. " (#" .. tostring(dNum) .. ")") or ("Palette #" .. tostring(dNum))
          return hexes, title
        end
      end
    end
  end

  pcall(function() os.remove(rpcReqFile) end)
  return nil, nil
end

-- Obtener la paleta actual/hoy de BasePaint
fetchTodayBasePaint = function()
  -- 1. Intentar GraphQL primero
  local gqlReqFile = safePath(tempDir, "bp_gql_req.json")
  local gqlResFile = safePath(tempDir, "bp_gql_res.json")

  local reqFile = io.open(gqlReqFile, "w")
  if reqFile then
    reqFile:write('{"query":"query { canvass(limit: 1, orderBy: \"id\", orderDirection: \"desc\") { items { id name palette } } }"}')
    reqFile:close()
  end

  local curlGqlCmd = string.format('curl -s -X POST -H "Content-Type: application/json" -d @"%s" "https://graphql.basepaint.xyz/" -o "%s"', gqlReqFile, gqlResFile)
  executeSilent(curlGqlCmd)

  local fGql = io.open(gqlResFile, "r")
  if fGql then
    local jsonText = fGql:read("*all") or ""
    fGql:close()
    pcall(function() os.remove(gqlReqFile) end)
    pcall(function() os.remove(gqlResFile) end)

    local idVal = jsonText:match('"id":%s*(%d+)')
    local palVal = jsonText:match('"palette":%s*"([^"]+)"')
    local nameVal = jsonText:match('"name":%s*"([^"]+)"')

    if idVal and tonumber(idVal) then
      local onChainHexes, onChainTitle = fetchOnChainBasePaint(tonumber(idVal))
      if onChainHexes and #onChainHexes > 0 then
        return onChainHexes, onChainTitle
      end
    end

    if palVal then
      local hexes = {}
      for hex in palVal:gmatch('#%x%x%x%x%x%x') do
        table.insert(hexes, hex)
      end
      if #hexes > 0 then
        local title = (nameVal and nameVal ~= "") and (nameVal .. " (#" .. idVal .. ")") or ("Palette #" .. idVal)
        return hexes, title
      end
    end
  end

  -- 2. Fallback directo al API /api/today
  local resFileName = safePath(tempDir, "bp_today_fallback.json")
  local curlCmd = string.format('curl -s "https://basepaint.xyz/api/today" -o "%s"', resFileName)
  executeSilent(curlCmd)

  local fRes = io.open(resFileName, "r")
  if fRes then
    local jsonText = fRes:read("*all") or ""
    fRes:close()
    pcall(function() os.remove(resFileName) end)

    local hexes = {}
    for hex in jsonText:gmatch('#%x%x%x%x%x%x') do
      table.insert(hexes, hex)
    end
    if #hexes > 0 then
      return hexes, "Today's palette"
    end
  end

  return nil, "No se pudo obtener la paleta de hoy."
end

-- Petición a BasePaint para un canvas específico
fetchBasePaintDirect = function(dayNum)
  local dStr = tostring(dayNum or ""):gsub("%s+", ""):upper()
  local isTodayOrLatest = (dStr == "" or dStr == "HOY" or dStr == "TODAY" or dStr == "LATEST" or dStr == "NOW" or dStr == "CURRENT" or dStr == "ACTUAL")

  if isTodayOrLatest then
    return fetchTodayBasePaint()
  end

  local dNum = tonumber(dayNum) or 0
  if dNum <= 0 then
    return nil, "Número de canvas inválido."
  end

  -- 1. Intentar consulta ON-CHAIN directa al smart contract de BasePaint
  local onChainHexes, onChainTitle = fetchOnChainBasePaint(dNum)
  if onChainHexes and #onChainHexes > 0 then
    return onChainHexes, onChainTitle
  end

  -- 2. Consultar GraphQL tanto para el canvas solicitado como para los últimos canvas activos
  local gqlReqFile = safePath(tempDir, "bp_gql_day_req.json")
  local gqlResFile = safePath(tempDir, "bp_gql_day_res.json")

  local reqFile = io.open(gqlReqFile, "w")
  if reqFile then
    local queryStr = string.format('{"query":"query { canvas(id: %d) { id name palette } latest: canvass(limit: 6, orderBy: \"id\", orderDirection: \"desc\") { items { id name palette } } }"}', dNum)
    reqFile:write(queryStr)
    reqFile:close()
  end

  local curlGqlCmd = string.format('curl -s -X POST -H "Content-Type: application/json" -d @"%s" "https://graphql.basepaint.xyz/" -o "%s"', gqlReqFile, gqlResFile)
  executeSilent(curlGqlCmd)

  local fGql = io.open(gqlResFile, "r")
  if fGql then
    local jsonText = fGql:read("*all") or ""
    fGql:close()
    pcall(function() os.remove(gqlReqFile) end)
    pcall(function() os.remove(gqlResFile) end)

    local exactMatch = nil
    local firstValid = nil

    for chunk in jsonText:gmatch("{[^{}]-}") do
      local idVal = chunk:match('"id":%s*(%d+)')
      local palVal = chunk:match('"palette":%s*"([^"]+)"')
      local nameVal = chunk:match('"name":%s*"([^"]+)"')
      if idVal and palVal and palVal:find('#') then
        local itemObj = {
          id = tonumber(idVal),
          name = nameVal,
          palette = palVal
        }
        if tonumber(idVal) == dNum then
          exactMatch = itemObj
          break
        elseif not firstValid then
          firstValid = itemObj
        end
      end
    end

    if exactMatch then
      local hexes = {}
      for hex in exactMatch.palette:gmatch('#%x%x%x%x%x%x') do
        table.insert(hexes, hex)
      end
      if #hexes > 0 then
        local title = (exactMatch.name and exactMatch.name ~= "") and (exactMatch.name .. " (#" .. tostring(dNum) .. ")") or ("Palette #" .. tostring(dNum))
        return hexes, title
      end
    end

    if firstValid then
      local hexes = {}
      for hex in firstValid.palette:gmatch('#%x%x%x%x%x%x') do
        table.insert(hexes, hex)
      end
      if #hexes > 0 then
        local msg = string.format("El Canvas #%d no tiene datos en el indexador de BasePaint.\n\nSe cargó automáticamente el Canvas activo más cercano: #%d (%s).", dNum, firstValid.id, firstValid.name or "Hoy")
        app.alert(msg)
        return hexes, "Palette #" .. tostring(firstValid.id) .. " (" .. (firstValid.name or "Latest") .. ")"
      end
    end
  end

  -- 3. Fallback a la REST API /api/art/{dayNum}
  local resFileName = safePath(tempDir, "basepaint_res.json")
  local url = "https://basepaint.xyz/api/art/" .. tostring(dNum)
  local curlCmd = string.format('curl -s "%s" -o "%s"', url, resFileName)

  executeSilent(curlCmd)

  local fRes = io.open(resFileName, "r")
  if fRes then
    local jsonText = fRes:read("*all") or ""
    fRes:close()
    pcall(function() os.remove(resFileName) end)

    local hexes = {}
    for hex in jsonText:gmatch('#%x%x%x%x%x%x') do
      table.insert(hexes, hex)
    end

    if #hexes > 0 then
      return hexes, "Palette #" .. tostring(dNum)
    end
  end

  return nil, "El Canvas #" .. tostring(dNum) .. " no se encontró o aún no está disponible."
end

-- Obtener la paleta actual del sprite abierto en Aseprite
fetchCurrentAsepritePalette = function()
  local sprite = app.activeSprite
  if not sprite then
    app.alert("No hay ningún dibujo/sprite activo en Aseprite.\nAbre un lienzo para leer su paleta.")
    return nil, nil
  end

  local pal = sprite.palettes[1]
  if not pal or #pal == 0 then
    app.alert("El sprite activo no contiene colores en su paleta.")
    return nil, nil
  end

  local hexes = {}
  local seen = {}
  for i = 0, #pal - 1 do
    local color = pal:getColor(i)
    if color and color.alpha > 0 then
      local hex = string.format("#%02X%02X%02X", color.red, color.green, color.blue)
      if not seen[hex] then
        seen[hex] = true
        table.insert(hexes, hex)
      end
    end
  end

  if #hexes == 0 then
    app.alert("No se encontraron colores visibles en la paleta del sprite activo.")
    return nil, nil
  end

  local name = "Paleta Aseprite Actual"
  if sprite.filename and sprite.filename ~= "" then
    local fName = (app.fs and app.fs.fileName and app.fs.fileName(sprite.filename)) or sprite.filename:match("([^/\\]+)$") or "Lienzo"
    name = "Paleta de " .. fName
  end

  return hexes, name
end

-- =========================================================================
-- DIÁLOGO PRINCIPAL (UI) - SOLO BASEPAINT
-- =========================================================================
local mainDlg = Dialog({ title = "Basepalette helper" })

mainDlg:entry{
  id = "canvas_number",
  label = "Canvas #:",
  text = "1101"
}

mainDlg:button{
  id = "get_canvas",
  text = "Load palette",
  onclick = function()
    local data = mainDlg.data
    local canvasNum = data.canvas_number:gsub("%s+", "")
    if canvasNum == "" then canvasNum = "HOY" end

    local hexes, name = fetchBasePaintDirect(canvasNum)
    if hexes and #hexes > 0 then
      local rampas = generateRampsFromHexes(hexes, name)
      displayPreviewAndApply(rampas, name or ("Palette #" .. canvasNum), hexes)
    else
      app.alert("No se encontró la paleta #" .. canvasNum .. ".\nVerifica que el Canvas exista o usa 'HOY' para el día actual.")
    end
  end
}

mainDlg:separator{}

mainDlg:button{
  id = "get_current_active",
  text = "Use current palette",
  onclick = function()
    local hexes, name = fetchCurrentAsepritePalette()
    if hexes and #hexes > 0 then
      local rampas = generateRampsFromHexes(hexes, name)
      displayPreviewAndApply(rampas, name, hexes)
    end
  end
}

mainDlg:separator{}

mainDlg:label{
  text = "by Gayapón"
}

mainDlg:show()
