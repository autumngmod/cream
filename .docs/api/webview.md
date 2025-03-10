# WebView
WebView is a Lua class that describes a WebUI panel.
It includes URLs, functions that you can call from JS, events, js code executions.

### Briefly:
To create a WebUI just use this:
```lua
local webui = cream:new("test")
webui:load()
-- or
cream:new("test"):load()
```

## Creation
```lua
local webview = cream:new("id")
```
The argument passed to ``cream:new`` is id. It is a unique identifier for your WebUI.

The specified id also affects the search for the desired ``HTML`` file.

The id literally shows in which folder (relative to ``garrysmod/data/worky/``) the ``index.html`` is located.

That is, in this example id refers to ``garrysmod/data/worky/id/index.html.tx``.

## Functions
You can bind functions that you can call from the JavaScript side. This is done using the ``:define()`` method.

```lua
local webview = cream:new("id")
webview:define("getUsername", function()
  return LocalPlayer():Nick()
end)
```
Now, after creating a WebUI from WebView, the ``getUsername()`` function call will be available in JavaScript. In JavaScript, the call will look like this:

```ts
import { call } from "@autumngmod/cream-api"

let username: string = await call("getUsername");

console.log(username)
```

## Base Directory
If you don't want to store ``index.html`` at the root of the ``worky`` directory, you can specify your path inside ``worky`` using the ``:setBaseDir()`` method. Example:

```lua
-- will load the ``data/worky/ui/example/index.html`` file
local webview = cream:new("example")
webview:setBaseDir("ui/example/") -- must end in “/”
```

## Loading
WebView is a configurator class. This means that you can create it once, and use it many times. It will keep all the functions and URLs in it.

To create a WebUI from a WebView you need to use the ``:load()`` method.

This method will create a WebUI (DHTML panel) after the ``index.html`` file has been downloaded from the server by the client, and is fully ready for use.

If you specify a custom URL, the WebUI will be created instantly.

```lua
-- will wait for the file (data/worky/example/index.html) to download
local webview = cream:new("example")
-- will be created instantly
local webview = cream:new("google", "https://google.com")
```