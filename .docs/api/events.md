# Sending an event to JS
With the ``0.1.2`` update, it is now possible to send events in JavaScript.\
With this you can, for example, close your menu when an event occurs.\
You can do this via the ``:event()`` method. Example:
```lua
local webview = cream:new("example")
-- :event(string name, table payload)
webview:event("menuStateChanged", {
  visible = false
})
```
JavaScript side:
```ts
import { listen } from "@autumngmod/cream-api"

interface MenuStateEvent {
  visible: boolean
}

listen<MenuStateEvent>("menuStateChanged", body => {
  // body will be of type MenuStateEvent
  console.log(body.visible) // should print "false"
})
```