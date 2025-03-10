# LuaLS support
The entire library is documented, so the types of each function are signed.\
This means that you can write code more easily, and safely, without consulting the documentation.

So you can download [cream.lua](/lua/autorun/cream.lua) (non-minified library), and move it to wherever you want.

Then copy the path to the saved ``cream.lua``, open ``.vscode/settings.json``/``.luarc.json`` in your workspace, find/create the ``workspace.library`` field (Lua.workspace.library in ``.vscode/settings.json``), and add the path to ``cream.lua`` to that array.\
Like here:

```json
"Lua.workspace.library": [
  "${addons}/garrysmod/module/library", // for garry's mod standart library support
  "/home/user/exampledir/cream.lua" // for cream support
]
```