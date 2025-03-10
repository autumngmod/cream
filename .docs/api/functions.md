# Adding functions
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