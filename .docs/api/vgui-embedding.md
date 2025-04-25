# VGUI Embedding

```lua
local webview = cream:new("example")
webview:attach(function()
  local element = vgui.Create("DModelPanel")
  element:SetModel(LocalPlayer():GetModel())

  return element
end, "html-block-id")
webview:load()
```