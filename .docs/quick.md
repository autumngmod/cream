# Quick guide
## "Nonsense" (actually very important information)
1. Due to Garry's mod limitations, static files (html/css/js) are transferred with a .txt extension and saved in the ``data/worky`` folder.
2. Static files are transferred via ``net``, that is, when the player is already connected to the server. Because of this there is a problem - at the first connection files may not have time to download. There is a function ``cream:load`` for this purpose. It starts the UI when the file is ready (installed).
3. Your UI web project should be a single index.html file. It's all because of problems with ``.txt`` file format, ``.js.txt``/``.css.txt`` can't be processed properly by the browser, but ``index.html`` can. You can do this on Vite via [vite-plugin-singlefile plugin](https://www.npmjs.com/package/vite-plugin-singlefile).

Such are the limitations of Garry's Mod.

## Creating a project
### Initializing
Let's start by creating a client-side lua file that will run your UI.

Create a file ``garrysmod/lua/autorun/client/my_web_ui.lua``, and write the following in it:
```lua
lua:load("my_project")
```
Now when you join to the server you will have your web project open.

### Create React+Vite project
Let's base our guide on the Vite+ReactJS stack, it's the most normal option.

Make a folder called ``my_project`` in a convenient location (mine was my desktop folder) then open it in explorer.

Open a terminal, and type ``cd`` into your new folder (``my_project``), for example:
```bash
cd C:/Users/admin/Desktop/my_project
```

Now you need to initialize the Vite project. This is done with ``npm``/``bun``/others

Examples:
```bash
npm create vite@latest
# or
bun create vite
```

When you get the “Project name:” text box, type ``my_project`` into it, select ``React`` in the “Select a framework:” box, and “Select a variant” just select ``TypeScript``.

Write the following commands:
```bash
cd my_project

bun/npm install # dependency installation
bun/npm run dev --host # starting a vite server
```

That's pretty much it, all that's left is to plug in the ``vite-plugin-singlefile plugin``:
```bash
npm install vite-plugin-singlefile --save-dev
# or
bun install vite-plugin-singlefile
```

After successful installation, open the `vite.config.ts` file and make it look like this:
```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { viteSingleFile } from 'vite-plugin-singlefile';

export default defineConfig({
  plugins: [react(), viteSingleFile()],
});
```

Now you can build your project:
```bash
npm/bun run build
```

After a successful build, you will have a ``dist`` folder created, it will contain an ``index.html`` (only ``index.html``) file. Copy it to ``garrysmod/data/worky/my_project/``

Restart your Garry's Mod server and join to the server.

If you did everything correctly, your project will appear on the entire screen (in 2-10 seconds).