# BundleNinja!

* * *

BundleNinja is a bundler for a tight subset of AMD/RequireJS with just 1kb (pre-gzip!) footprint. It's meant to be a replacement for r.js bundler and provide an absolutely minimal footprint in your final bundles. BN doesn't support many core features of RequireJS or AMD in general, so you must be really sure your application is using only a very sctrict subset of AMD and does not use any RequireJS plugins aside from `text` - support for which is built in.

BN enables you to develop your app with RequireJS for all it's debugging goodness, and then bundle everything into a single, small js file. Unlike r.js, BN packs all your files as strings (uglifying them beforehand) so when your app starts the browser only has to parse the javascript you actually need at any given moment.