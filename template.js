(function(window) {

  var files   = {},
      modules = {},
      shim    = {},
      require = function(path) {

        // resolve mode
        mode = path.split('!');
        if (mode.length > 1) {
          mode = mode[0];
        } else {
          mode = null;
        }

        // the define function
        var module, define = function(content) {
          // if argument of define is a function, execute it
          if(typeof content === 'function') {
            content = content(require);
          }

          module = modules[path] = content;
        }
        define.amd = {};

        // Clear incoming path from heading './' or tailing '.js'
        path = path.replace(/^\.\//, '').replace(/\.js$/i, '');

        // Module not in the hash?
        if (modules[path] === void 0) {
          // Throw an exception if there is no source coresponding to the module
          if (files[path] === void 0) { throw "Unknown module: " + path; }

          // Handle text mode
          if (mode === 'text') {
            return modules[path] = files[path];
          }

          // helper vars
          var d, i, l, s = shim[path];

          // Check for dependencies
          if (s && s.deps) {
            for (i = 0, l = s.deps.length; i < l; i++) {
              require(s.deps[i]);
            }
          }

          // Parse the file string, pass module object and require function to it
          eval("(function(define){" + files[path] + "})")(define);

          // Check for shim exports
          if (s && s.exports) {
            module = modules[path] = window[s.exports];
          }

          // Handle undefined
          if(module === void 0) {
            module = modules[path] = null;
          }

          // Drop the file string to save some memory now it's been parsed
          delete files[path];

          // Return module exports
          return module
        }

        // Module in the hash? awesome!
        return modules[path];
      };

//#!inject

})(window);