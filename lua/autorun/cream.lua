--
-- cream is a library that allows you to easily
--   create Web UI for Garry's Mod without thinking about the details.
--
-- autumngmod@2025
--

if (cream and cream.webviews) then
  for _, webview in pairs(cream.webviews) do
    if (IsValid(webview)) then
      webview:getPanel()
        :Remove()
    end
  end
end

---@diagnostic disable-next-line: lowercase-global
cream = cream or {}
cream.version = "0.1.4"
-- Table of WebView panels that will be initialized after player spawned first time
---@type string[] List of WebViews id
cream.preload = cream.preload or {}
-- Registred WebViews
---@type table<string, WebView>
cream.webviews = cream.webviews or {}

-- DHTMLExtended
---@class DHTMLExtended: DHTML
---@field storage table<string, fun(...): string | number | boolean | nil>
---@field webview WebView
---@field getWebView fun(self: DHTMLExtended): WebView
---@field addCallback fun(self: DHTMLExtended, name: string, callback: fun(...): string | number | boolean | nil)

-- WebView
---@class WebView
---@field id string
---@field url string
---@field baseDir string | nil Folder, that contains ${id}/index.html.txt file. Relative to garrysmod/data/worky/
---@field expressions string[] JS Code that will be executed when DHTML created
---@field methods table<string, fun(...): string | number | boolean | nil>
---@field panel DHTMLExtended | nil DHTML Panel
---@field loaded function | nil
local webview = {}
webview.__index = webview

--- Creates new WebView object
---
---@param id string
---@param url? string
---@return WebView
function cream:new(id, url)
  local webview = setmetatable({
    id = id,
    url = url,
    expressions = {},
    methods = {},
  }, webview)

  if (not url) then
    ---@diagnostic disable-next-line: invisible
    webview.url = webview:generateUrl()
  end

  return webview
end

--- Adds a function that you can call from JavaScript.
---
---@param name string
---@param callback fun(...): string | number | boolean | nil
function webview:define(name, callback)
  -- If self.panel is valid
  if (not IsValid(self)) then
    self.methods[name] = callback

    return
  end

  self.panel:addCallback(name, callback)
end

--- Executes ``JavaScript`` code in the panel,\
--- or queues the execution until the panel is created, and then executes that code.
---
--- This provides guarantees that your code will be executed.
---
---@param code string
---@return self
function webview:execute(code)
  if (not IsValid(self)) then
    self.expressions[#self.expressions+1] = code

    return self
  end

  self.panel:QueueJavascript(code)

  return self
end

--- Updates URL of WebView
---
---@param url string
---@return self
function webview:setUrl(url)
  self.url = url

  if (IsValid(self)) then
    self.panel:OpenURL(url)

    for name, callback in pairs(webview.methods) do
      panel:addCallback(name, callback)
    end

    for _, code in ipairs(webview.expressions) do
      panel:QueueJavascript(code)
    end
  end

  return self
end

--- Function called after panel loading
---
---@param callback function
function webview:onLoaded(callback)
  self.loaded = callback
end

--- Generates path to the ``index.html.txt`` of current WebView.\
---
--- Relative to ``asset://garrysmod/data/``
---
---@private
---@return string ``asset://garrysmod/data/worky/${baseDir}/index.html.txt``
function webview:generateUrl()
  return "asset://garrysmod/data/" .. ((self.baseDir or ("worky/" .. self.id .. "/")) .. "index.html.txt")
end

--- Sets folder that contains ${id}/index.html.txt file. Relative to ``garrysmod/data/worky/``\
---
--- ``Must end with a "/"``
---
---@param baseDir string
---@return self
function webview:setBaseDir(baseDir)
  self.baseDir = "worky/" .. baseDir

  self.url = self:generateUrl()

  return self
end

--- Returns DHTML panel (if it already created)
---
---@return DHTML | nil
function webview:getPanel()
  return self.panel
end

--- _G.IsValid compatibility
---
---@private
---@return boolean
function webview:IsValid()
  return IsValid(self.panel)
end

--- Alias for ``cream:load(webview)``
---
---@return self
function webview:load()
  cream:load(self)

  return self
end

--- Sends an event to JavaScript
---
---@param name string Name of the event
---@param payload table Payload
function webview:event(name, payload)
  local jsoned = util.TableToJSON(payload)

  -- ¯\_(ツ)_/¯
  local event = ("new CustomEvent('%s', { detail: %s })"):format(name, jsoned)
  local code = ("window.dispatchEvent(%s)"):format(event)

  self:execute(code)
end

-- Panel managment

--- Creates DHTML panel on player's screen\
--- If ``cream.preload`` (creation queue) exists, it places itself in it\
--- If not, the panel is created immediately
---
---@param webview WebView
function cream:load(webview)
  local id = webview.id

  local cached = self.webviews[id]
  if (IsValid(cached)) then
    cached:getPanel():Remove()
  end

  self.webviews[id] = webview

  if (self.preload and not table.HasValue(self.preload, id)) then
    if (webview.url:sub(1, 8) ~= "asset://") then -- ¯\_(ツ)_/¯
      timer.Simple(0, function()
        self:create(id)
      end)

      return
    end

    self.preload[#self.preload+1] = id

    return
  end

  self:create(id)
end

--- ``INTERNAL`` Creates DHTML on player's screen\
--- ``You don't have to use it!``
---
---@private
---@param id string WebView's id
---@return DHTMLExtended
function cream:create(id)
  local webview = self:getThrowable(id)

  -- If DHTML already created
  if (IsValid(webview)) then
    local panel = webview:getPanel()
    -- checked above
    ---@diagnostic disable-next-line: need-check-nil
    panel:Remove()
  end

  ---@type DHTML
  local dhtml = vgui.Create("DHTML")
  dhtml:Dock(FILL) -- autosizing

  local panel = self:setupWebView(webview, dhtml)

  webview.panel = panel

  if (webview.loaded) then
    webview:loaded()
  end

  return panel
end

--- ``INTERNAL`` Provides interface between Lua and JS (API)\
--- ``You don't have to use it!``
---
---@private
---@param webview WebView
---@param panel DHTML
---@return DHTMLExtended
function cream:setupWebView(webview, panel)
  ---@cast panel DHTMLExtended

  -- Storage
  ---@private
  panel.storage = {}

  ---@private
  panel.webview = webview

  panel.getWebView = function(self)
    return self.webview
  end

  panel.addCallback = function(self, name, callback)
    self.storage[name] = callback
  end

  panel:AddFunction("lua", "call", function(...)
    local args = { ... }
    local func = args[1]
    local callback = panel.storage[func]

    if (not callback) then
      -- todo @ throw error to js if not found
      return
    end

    -- removing callback function name
    table.remove(args, 1)

    return callback(args)
  end)

  webview:setUrl(webview.url)

  return panel
end

--- Returns WebView if it exists
---
---@param id string
---@return WebView | nil
function cream:get(id)
  return self.webviews[id]
end

--- Returns WebView, throws error if it not exists in ``self.webviews``
---
---@param id string
---@return WebView
function cream:getThrowable(id)
  local webview = self.webviews[id]

  if (not webview) then
    -- yes, it is declared in @param that the variable is required,
    -- but this is just a security measure (id or "")

    error("WebView " .. (id or "") .. " not found!")
  end

  return webview
end

-- Preload mechanism
hook.Add("WorkyFileReady", "cream", function(path)
  path = path .. ".txt"

  if (not cream.preload) then
    return hook.Remove("WorkyFileReady", "cream")
  end

  local found;

  for index, id in ipairs(cream.preload) do
    local webview = cream:get(id)

    if (not webview or not webview.url:find(path, 1, true)) then
      continue
    end

    found = {index, webview}
    break
  end

  if (found) then
    local index, webview = found[1], found[2]

    webview:load()

    table.remove(cream.preload, index)
  end

  if (#cream.preload == 0) then
    return hook.Remove("WorkyFileReady", "cream")
  end
end)

hook.Add("WorkyReady", "cream", function()
  for index, v in ipairs(cream.preload) do
    local webview = cream:get(v)

    if (not webview) then
      print("Webview \"" .. tostring(v) .. "\" not found")

      continue
    end

    webview:load()

    table.remove(cream.preload, index)
  end
end)

-- right after installation
timer.Simple(0, function()
  if (worky and worky.isDownloaded) then
    for index, v in ipairs(cream.preload) do
      local webview = cream:get(v)

      if (not webview) then
        print("Webview \"" .. tostring(v) .. "\" not found")

        continue
      end

      webview:load()

      table.remove(cream.preload, index)
    end
  end
end)