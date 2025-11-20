# comicthumb.yazi

Plugin for [Yazi](https://github.com/sxyazi/yazi) to preview comic book archive files using [p7zip](https://github.com/p7zip-project/p7zip).
Currently only works on Linux due to awk dependency.
To install:

```bash
ya pack -a navysky12/comicthumb.yazi
```

and reference it in your `yazi.toml`:

```toml
[plugin]
prepend_preloaders = [
	{ name = "*.cb[7rz]", run = "comicthumb" },
]
prepend_previewers = [
	{ name = "*.cb[7rz]", run = "comicthumb" },
]
```
