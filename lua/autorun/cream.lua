---@diagnostic disable: inject-field :)
--
-- cream -- a lua library for Garry's Mod
-- which manages web page based user interfaces,
-- and provides a convenient API for them.
--
-- table of content:
--  cream   # table
--    cream:new(string id, string url): Panel
--    cream:get(string id): Panel | nil
--    cream:remove(string id)
--    cream:isValid(string id): boolean
--

---@class WebView: DHTML

cream = cream or {}
cream.storage = cream.storage or {}
---@type table<string, { callback?: fun(_: WebView), url: string }>
cream.preload = cream.preload or {}

--- Returns WebView panel
---
---@param id string
---@return WebView | nil
function cream:get(id)
  return self.storage[id]
end

--- Is WebView panel valid?
---
---@param id string
---@return boolean
function cream:isValid(id)
  return IsValid(self.storage[id])
end

--- Returns the WebView panel if it exists or throws an error
---
---@param id string
function cream:getThrowable(id)
  local panel = self.storage[id]

  if (!IsValid(panel)) then
    error("Panel is missing")
  end

  return panel
end

--- Returns the path to the main folder of your UI in the ``data/worky/`` folder
---
---@param folder string
---@return string "relative to ``asset://garrysmod/data/worky/``"
function cream:getUrlInData(folder)
  return "asset://garrysmod/data/worky/" .. folder
end

--- Automatically launches the file when a player joins to the server
---
---@param id string
---@param callback? fun(panel: WebView)
---@param url? string
function cream:load(id, callback, url)
  if (!self.preload) then
    local panel = self:new(id, url, true)

    if (callback) then
      panel(callback)
    end

    return
  end

  self.preload[id] = {
    callback = callback,
    url = url or self:getUrlInData(id) .. "/index.html.txt"
  }
end

hook.Add("workyDownloaded", "cream", function(path)
  path = path .. ".txt"

  if (!cream.preload) then
    return hook.Remove("workyDownloaded", "cream")
  end

  for id, info in pairs(cream.preload) do
    local url = info.url

    if (url:find(path, 1, true)) then
      local panel = cream:new(id, url)
      local callback = info.callback

      cream.preload[id] = nil

      if (callback) then
        callback(panel)
      end
    end
  end
end)

--- Creates new WebView
---
---@param id string
---@param url? string Override default url
---@param override? boolean
---@return WebView
function cream:new(id, url, override)
  local p = self.storage[id]

  --- why tf is there no walrus operator in lua?
  if (p) then
    if (!override) then
      return p
    end

    p:Remove()
  end

  ---@type WebView
  ---@diagnostic disable-next-line: assign-type-mismatch
  local panel = vgui.Create("DHTML")
  panel:Dock(FILL) -- auto sizing
  panel:OpenURL(url or self:getUrlInData(id) .. "/index.html.txt") -- workyround rules (.txt)

  self.storage[id] = panel

  self:setup(id, panel)

  return panel
end

--- Provides API methods to the JavaScript\
--- *internal function, use ``addCallback``
---
---@private
---@param id string
---@param panel WebView
function cream:setup(id, panel)
  panel.callbackStorage = {}

  ---@param name string
  ---@param callback fun(...): number | string | boolean
  panel.addFunction = function(self, name, callback)
    cream:addCallback(id, name, callback)

    return self
  end

  panel.execute = panel.QueueJavascript
  panel.setUrl = panel.OpenURL

  panel:AddFunction("lua", "call", function(...)
    local args = {...}
    local fn = args[1] // callable function name
    local callback = panel.callbackStorage[fn]

    if (!callback) then
      -- todo @ throw error to js if not found
      return
    end

    table.remove(args, 1) // removing function name

    return callback(args)
  end)
end

--- Adds a function that can be called from JS
---
---@param id string
---@param name string
---@param callback fun(...): number | string | boolean
function cream:addCallback(id, name, callback)
  self:getThrowable(id)
    .callbackStorage[name] = callback
end

--- Executes JavaScript witin WebView panel
---
---@param id string
---@param jsCode string
function cream:execute(id, jsCode)
  self:getThrowable(id)
    :QueueJavascript(jsCode)
end

--- Changes url in WebView
---
---@param id string
---@param url string
function cream:setUrl(id, url)
  self:getThrowable(id)
    :OpenURL(url)
end

--- Destroys WebView
---
---@param id string
function cream:remove(id)
  self:getThrowable(id)
    :Remove()

  self.storage[id] = nil
end