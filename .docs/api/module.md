# cream api
Well, we actually have [our own module on npm](https://www.npmjs.com/package/@autumngmod/cream-api) that adds the ability to asynchronously call functions from Garry's Mod, saving developers from colbacks (ewww gross).

Let me show you how to use it.

# Installation
```bash
npm/bun install @autumngmod/cream-api
```
Now you can use it in code!

# Usage
Example in ReactJS
```tsx
import { useState, useEffect } from "react"
import { call } from "@autumngmod/cream-api"

export default Home() {
  const [username, setUsername] = useState("nil");

  useEffect(() => {
    (() => {
      setUsername(await call<string>("getUsername"))
    })()
  }, [])

  return (
    <div>username is {username}</div>
  )
}
```
Garry's Mod Lua:
```lua
local panel = cream:new("example")

panel:addFunction("getUsername", function()
  return LocalPlayer():Nick()
end)

panel:load()
```

It's easy, isn't it?