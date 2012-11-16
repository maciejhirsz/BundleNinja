/*
 * (c) 2012 Maciej Hirsz
 * BundleNinja may be freely distributed under the MIT license.
 *
 * =========================================================================
 *
 * This file is the footprint code added to the bundle that will handle your
 *   define() and require() needs. You shouldn't need to modify this (unless
 *   you find a bug!), but it might be good to read through to know how it
 *   handles your modules!
 *
 * =========================================================================
 *
 */
(function(window) {

  var files   = {},
      modules = {},
      shim    = {},
      require = function(path) {
        /*
         * Clear incoming path from any './' or tailing '.js', this may or may not
         *   violate standard AMD rules, we don't care, BundleNinja only supports a
         *   very strict subset of AMD/RequireJS
         */
        path = path.replace(/\.\//, '').replace(/\.js$/i, '');

        /*
         * The `modules` hash contains all parsed and executed modules, if a module
         *   isn't there yet, we need to parse it from `files` hash.
         */
        if (modules[path] === void 0) {
          /*
           * Throw an exception if there is no source coresponding to the module
           */
          if (files[path] === void 0) { throw "Unknown module: " + path; }

          /*
           * Resolve `mode!path` calls, at this moment we only support a faux `text` plugin,
           *   if you need anything else on top of standard RequireJS, this bundler might
           *   not be for you.
           */
          mode = path.split('!');
          if (mode.length > 1) {
            mode = mode[0];
          } else {
            mode = null;
          }

          /*
           * Handle the `text` mode by just returning the string source of the file.
           */
          if (mode === 'text') {
            return modules[path] = files[path];
          }

          /*
           * This is our `define` function, it will get passed to the module and is
           *   responsible for executing any logic contained within the module as well
           *   as putting executed module to our modules hash.
           */
          var module, define = function(content) {
            /*
             * If argument of `define` is a callback function (should be most of the time),
             *   execute it and refer to the results.
             */
            if(typeof content === 'function') {
              content = content(require);
            }

            module = modules[path] = content;
          }

          /*
           * Some modules check for existence of amd property on define to make sure it's an
           *   AMD compatible function rather than something custom in global scope.
           */
          define.amd = {};

          /*
           * Helper vars for shim and iterations, nothing to see here.
           */
          var d, i, l, s = shim[path];

          /*
           * Check shim for dependencies and require them first!
           */
          if (s && s.deps) {
            for (i = 0, l = s.deps.length; i < l; i++) {
              require(s.deps[i]);
            }
          }

          /*
           * Our module gets pares with eval but only encapsulated within an anonymous function,
           *   where it gets passed our define function from above as an argument, this way we can
           *   avoid any conflicts within global scope and eventually prevent global scope from
           *   being messed up. If any of your modules need to assign stuff to global scope always
           *   do it via the `window` object.
           */
          eval("(function(define){" + files[path] + "})")(define);

          /*
           * Check shim for exports (will return a property from global scope for non AMD requires)
           */
          if (s && s.exports) {
            module = modules[path] = window[s.exports];
          }

          /*
           * Change `undefined` module results to `null` to avoid re-parsing.
           */
          if(module === void 0) {
            module = modules[path] = null;
          }

          /*
           * Drop the file string to save some memory now it's been parsed.
           */
          delete files[path];

          /*
           * Return the module.
           */
          return module
        }

        /*
         * Module in the hash? awesome!
         */
        return modules[path];
      };

/*
 * The comment line below is not an ordinary comment, bundler script will use it to push all the
 *   bundled files into the template file, do not remove it as it will break the whole process!
 */
//#!inject

})(window);