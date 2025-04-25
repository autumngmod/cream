--
-- cream is a library that allows you to easily
--   create Web UI for Garry's Mod without thinking about the details.
--
-- autumngmod@2025
--

if (SERVER) then
  return
end

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
---@type table<string, fun(webview: WebView)>
cream.std = cream.std or {}
cream.version = "0.1.6"
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

---@param name string
---@return boolean
local function isValidStdName(name)
	return string.match(name, "^[^.]+%.[^.]+$") ~= nil
end

--- Registers std in cream, making it possible to connect it to WebView.
---
---@param name string Name of std ()
---@param callback fun(webview: WebView)
function cream:registerStd(name, callback)
  if (not isValidStdName(name)) then
    error("The name of the registered std must be of the form “%s.%s”")
  end

  self.std[name] = callback
end

-- WebView
---@class WebView
---@field id string
---@field url string
---@field expressions string[] JS Code that will be executed when DHTML created
---@field methods table<string, fun(...): string | number | boolean | nil>
---@field stds string[]
---@field attached table<string, fun(): Panel>
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
    stds = {},
    attached = {}
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

---@param name string
---@return self
function webview:importStd(name)
  if (!cream.std[name]) then
    error("Invalid std " .. name .. "!")
  end

  self.stds[#self.stds+1] = name

  return self
end

--- Attaches the returned VGUI panel to the HTML block, taking over its width and position.
---
---@param callback fun(): Panel
---@param blockId string
---@return self
function webview:attach(callback, blockId)
  self.attached[blockId] = callback

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

    for name, callback in pairs(self.methods) do
      self.panel:addCallback(name, callback)
    end

    for _, code in ipairs(self.expressions) do
      self.panel:QueueJavascript(code)
    end

    -- for _, name in ipairs(self.stds) do
      -- local std = cream.std[name]
 
      -- std(self)
    -- end

    -- for id, callback in pairs(self.attached) do
      -- local panel = callback()
      -- panel:SetParent(self.panel)
      -- todo
    -- end
  end

  return self
end

--- Function called after panel loading
---
---@param callback function
---@return self
function webview:onLoaded(callback)
  self.loaded = callback

  return self
end

--- Generates path to the ``index.html.dat`` of current WebView.\
---
--- Relative to ``asset://garrysmod/resource/shared/``
---
---@private
---@return string ``asset://garrysmod/resource/shared/${id}/index.html.dat``
function webview:generateUrl()
  return "asset://garrysmod/resource/shared/" .. self.id .. "/index.html.dat"
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
    cached:getPanel()
      :Remove()
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
    webview:getPanel()
      :Remove()
  end

  ---@type DHTML
  local dhtml = vgui.Create("DHTML")
  dhtml:Dock(FILL) -- autosizing

  self:setupWebView(webview, dhtml)

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

    return callback(unpack(args))
  end)

  webview.panel = panel

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
    error("WebView " .. id .. " not found!")
  end

  return webview
end
timer.Simple(0, function()
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