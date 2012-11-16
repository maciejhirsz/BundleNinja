# BundleNinja!

* * *

BundleNinja is a bundler for a tight subset of AMD/RequireJS with just 1kb (pre-gzip!) footprint. It's meant to be a replacement for r.js bundler and provide an absolutely minimal footprint in your final bundles. BN doesn't support many core features of RequireJS or AMD in general, so you must be really sure your application is using only a very strict subset of AMD (which I'll try to describle later below) and does not use any RequireJS plugins aside from `text` - support for which is built in.

BN enables you to develop your app with RequireJS for all it's debugging goodness, and then bundle everything into a single, tight js file. Unlike r.js, BN packs all your files as strings (uglifying them beforehand) so when your app starts the browser only has to parse the javascript you actually need at any given moment.

Packing code as strings adds a tiny overhead to the file size (extra backslashes), but the result is still smaller than anything you might get otherwise, even using almond.

* * *

Requires: node, coffeescript and uglify-js2

Usage: `coffee bundle.coffee`

* * *

`config.json` options:

* `minify` - boolean, if set to `true` will uglify the whole footprint after bundling is done (recommended).
* `assets` - main directory root where all your assets - application javascript, vendor javascript and templates are. It's a good practice (demanded even) if vendor stuff is separated from application stuff.
* `bundle` - array of directories within assets that should have all it's js and text files bundled recursively.
* `bootstrap` - points to a bootstrap javascript file of your application. This file should only call require.config() method and then require a single "main" module.
* `output` - where the final bundled file should be saved.
* `main` - the "main" module that should be initialized after the bundle is loaded.
* `texts` - array of extensions that should be allowed to bundle as text modules with `text!` prefix, perfect for mustache templates.
* `ignore` - ignore list, by default it's good to ignore the `text` plugin of RequireJS since BN will handle all `text!` prefixes for you.

Look at `example.config.json` or my boilerplate repo for a clear example.