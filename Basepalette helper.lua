-- =========================================================================
-- Palette helper by Gayapón
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

local apiKeyFile = safePath(userDir, "gemini_key.txt")
local savedApiKey = ""

local fileRead = io.open(apiKeyFile, "r")
if fileRead then
  local readContent = fileRead:read("*all")
  if readContent then
    savedApiKey = readContent:gsub("%s+", "")
  end
  fileRead:close()
end

-- Helper para guardar la API Key localmente en el directorio del usuario
local function saveApiKey(key)
  if key and key ~= "" then
    local fileWrite = io.open(apiKeyFile, "w")
    if fileWrite then
      fileWrite:write(key)
      fileWrite:close()
    end
  end
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
  2, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 2, 2,
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

-- Función para aplicar las rampas a la Paleta Activa de Aseprite
local function applyToActivePalette(rampas)
  local sprite = app.activeSprite
  if not sprite then
    app.alert("No hay ningún lienzo/sprite activo en Aseprite.\nAbre o crea un nuevo archivo para aplicar la paleta.")
    return false
  end

  local totalColors = 0
  for _, rampa in ipairs(rampas) do
    totalColors = totalColors + #rampa
  end

  if totalColors == 0 then
    app.alert("No se encontraron colores para aplicar.")
    return false
  end

  local pal = nil
  if sprite.palettes and #sprite.palettes > 0 then
    pal = sprite.palettes[1]
  elseif app.activePalette then
    pal = app.activePalette
  end

  if not pal then
    pal = Palette(totalColors)
    if sprite.setPalette then
      sprite:setPalette(pal)
    end
  else
    pal:resize(totalColors)
  end

  local function doApply()
    local colorIdx = 0
    for _, rampa in ipairs(rampas) do
      for _, colorObj in ipairs(rampa) do
        pal:setColor(colorIdx, colorObj)
        colorIdx = colorIdx + 1
      end
    end
  end

  if app.transaction then
    app.transaction("Apply BasePaint Palette", doApply)
  else
    doApply()
  end

  app.refresh()
  app.alert("¡Éxito! Se han aplicado " .. totalColors .. " colores ordenados a la paleta activa.")
  return true
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

-- Función para ejecutar comandos cURL de forma totalmente silenciosa en Windows (sin ventana cmd.exe) y Unix
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

-- Petición cURL a GraphQL o REST de BasePaint para una paleta específica
local function fetchBasePaintDirect(dayNum)
  local dNum = tonumber(dayNum) or 0
  if dNum <= 0 then
    return nil, "Número de paleta inválido."
  end

  -- 1. Intentar GraphQL primero
  local gqlReqFile = safePath(tempDir, "bp_gql_day_req.json")
  local gqlResFile = safePath(tempDir, "bp_gql_day_res.json")

  local reqFile = io.open(gqlReqFile, "w")
  if reqFile then
    local queryStr = string.format('{"query":"query { canvas(id: %d) { id name palette } }"}', dNum)
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

    local palStr = jsonText:match('"palette":%s*"([^"]+)"')
    local nameStr = jsonText:match('"name":%s*"([^"]+)"')
    if palStr and palStr ~= "" then
      local hexes = {}
      for hex in palStr:gmatch('#%x%x%x%x%x%x') do
        table.insert(hexes, hex)
      end
      if #hexes > 0 then
        return hexes, "Palette #" .. tostring(dNum)
      end
    end
  end

  -- 2. Fallback a la REST API /api/art/{dayNum}
  local resFileName = safePath(tempDir, "basepaint_res.json")
  local url = "https://basepaint.xyz/api/art/" .. tostring(dNum)
  local curlCmd = string.format('curl -s "%s" -o "%s"', url, resFileName)

  executeSilent(curlCmd)

  local fRes = io.open(resFileName, "r")
  if not fRes then
    return nil, "No se pudo conectar a BasePaint API."
  end

  local jsonText = fRes:read("*all") or ""
  fRes:close()
  pcall(function() os.remove(resFileName) end)

  local hexes = {}
  for hex in jsonText:gmatch('#%x%x%x%x%x%x') do
    table.insert(hexes, hex)
  end

  if #hexes == 0 then
    return nil, "No se encontraron colores para la Palette #" .. tostring(dNum)
  end

  return hexes, "Palette #" .. tostring(dNum)
end

-- Petición cURL a Gemini AI
local function fetchFromGemini(apiKey, promptText)
  if not apiKey or apiKey == "" then
    app.alert("Por favor ingrese una API Key de Gemini válida.")
    return
  end

  saveApiKey(apiKey)

  local reqFileName = safePath(tempDir, "gemini_req.json")
  local resFileName = safePath(tempDir, "gemini_res.json")

  local fullPrompt = promptText .. " Devuelve exclusivamente un JSON con claves de colores HEX #RRGGBB."

  local jsonPayload = string.format([[{
    "contents": [{
      "parts": [{ "text": %q }]
    }]
  }]], fullPrompt)

  local fReq = io.open(reqFileName, "w")
  if fReq then
    fReq:write(jsonPayload)
    fReq:close()
  end

  local apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" .. apiKey
  local curlCmd = string.format('curl -s -X POST -H "Content-Type: application/json" -d @"%s" "%s" -o "%s"', reqFileName, apiUrl, resFileName)

  executeSilent(curlCmd)

  local fRes = io.open(resFileName, "r")
  if not fRes then
    app.alert("No se pudo leer la respuesta del archivo temporal de cURL.\nAsegúrate de tener cURL instalado.")
    return
  end

  local jsonText = fRes:read("*all") or ""
  fRes:close()

  pcall(function() os.remove(reqFileName) end)
  pcall(function() os.remove(resFileName) end)

  local hexes = {}
  for hex in jsonText:gmatch('#%x%x%x%x%x%x') do
    table.insert(hexes, hex)
  end

  local rampas = generateRampsFromHexes(hexes, "Gemini AI")
  displayPreviewAndApply(rampas, "BasePaint - Paleta Generada por AI", hexes)
end

-- =========================================================================
-- DIÁLOGO PRINCIPAL (UI)
-- =========================================================================
local mainDlg = Dialog({ title = "Palette helper" })

mainDlg:entry{
  id = "canvas_number",
  label = "Canvas #:",
  text = "42"
}

mainDlg:button{
  id = "get_canvas",
  text = "Load palette",
  onclick = function()
    local data = mainDlg.data
    local canvasNum = data.canvas_number:gsub("%s+", "")
    if canvasNum == "" then canvasNum = "42" end

    local hexes, name = fetchBasePaintDirect(canvasNum)
    if hexes and #hexes > 0 then
      local rampas = generateRampsFromHexes(hexes, name)
      displayPreviewAndApply(rampas, name or ("Palette #" .. canvasNum), hexes)
    else
      app.alert("No se encontró la paleta #" .. canvasNum)
    end
  end
}

mainDlg:separator{}

mainDlg:label{
  text = "by Gayapón"
}

mainDlg:show()