# Static files
To send HTML/other files we use [workyround]. This is our little library that allows the server to send files of any extension (because Garry's mod doesn't allow it, which is silly). This is done through a big crutch, so when you build your project (html/css/js), make it build into a single HTML file. On [Vite](https://vite.dev/) this is accomplished by plugging in [vite-plugin-singlefile plugin](https://www.npmjs.com/package/vite-plugin-singlefile).

## So how do I send files?
It's easy. After you have enabled our library, in the ``garrysmod/data`` folder will appear another folder - ``worky``, it is in it you should throw all the necessary files. Our libraries will resolve themselves with the transfer of files to the client.

Don't forget to keep the architecture of the folder clean!