# std
``std`` is a way to add pre-prepared functions to JavaScript.

## Registering your std
```lua
cream:registerStd("projectName.stdName", function(webview)
  webview:define("example", function()
    -- todo
  end)
end)
```

## Using your std
```lua
local webview = cream:new("example")
webview:importStd("projectName.stdName")
webview:load()
```

## JS Example
```js
import { call } from "@autumngmod/cream-api"

await call("projectName.stdName")
```