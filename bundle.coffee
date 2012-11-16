
fs = require('fs')
nodepath = require('path')
UglifyJS = require("uglify-js2")

#################################################

#
# `bundle` array will contain new lines of javascript to inject into `template.js`,
#   including shim, all bundled files and initial require command.
#
bundle = []

#
# `files` hash will contain all javascript and text (templates) files with paths
#   as keys.
#
files = {}

#
# Attempt to load config.json so we know what we are doing :).
#
throw "Didn't find config.json, copy example.config.json to start!" if not fs.existsSync('config.json')

config = JSON.parse(fs.readFileSync('config.json'))

#################################################

console.log("")
console.log("  > Running bootstrap config, reading and uglifying vendor stuff")

#
# Helper function for checking if any given file isn't on the ignore list
#
isIgnored = (item) ->
  for path in config.ignore
    return true if nodepath.relative(item, path) is ''
  return false

#
# Faux require() function to be passed into the `bootstrap` file of your project
#
r = ->

#
# Faux require.config() method to be passed into the `bootstrap`, this way we trick
# your client side javascript to give us all of the RequireJS configuration without
# any additional config files. After all, who wants to remember to edit two configs
# when adding a new vendor library to a project!
#
r.config = (options) ->
  paths = options.paths or {}

  #
  # Shims are important and will be resolved by the footprint code in `template.js`
  #
  bundle.push("  shim = "+JSON.stringify(options.shim)) if options.shim

  #
  # Go through all files defined in the `path` option and bundle those
  #
  for label, path of paths
    path = config.assets + '/' + path + '.js'
    if not isIgnored(path)
      label = label.replace(new RegExp('\\\\', 'g'), '/')
      console.log("  --- "+label+" from "+path)
      files[label] = UglifyJS.minify(path).code

#
# Read and eval bootstrap, encapsulated into anonymous function with our faux require()
# passed as an argument.
#
bootstrap = fs.readFileSync(config.bootstrap).toString()

eval('(function(require){'+bootstrap+'})')(r)

#################################################

console.log("")
console.log("  > Reading and uglifying all asset files")

#
# Read all files from the assets, note that we are not reading files for require()
# dependencies, but rather recusively read and bundle every single .js and text (extensions
# specified in config) file in folders specified to be bundled!
#
readFolder = (path) ->
  for item in fs.readdirSync(path)
    item = nodepath.join(path, item)

    if not isIgnored(item) and nodepath.relative(item, config.bootstrap) isnt '' and nodepath.relative(item, config.output) isnt ''

      ext = item.split('.').pop()

      stats = fs.statSync(item)

      if stats.isFile()
        if ext is 'js'
          label = nodepath.relative(config.assets, item).replace(new RegExp('\\\\', 'g'), '/')
          console.log("  --- "+label+" from "+item)
          files[label] = UglifyJS.minify(item).code

        if ext in config.texts
          label = 'text!'+nodepath.relative(config.assets, item).replace(new RegExp('\\\\', 'g'), '/')
          console.log("  --- "+label+" from "+item)
          files[label] = fs.readFileSync(item).toString()

      if stats.isDirectory()
        readFolder(item)

for folder in config.bundle
  readFolder(nodepath.join(config.assets, folder))

#################################################

console.log("")
console.log("  > Bundling")

#
# Bundle all uglified files into pure javascript lines, just treat them as JSON strings :).
#
for path, data of files
  path = path.replace(new RegExp('^\.\/compiled\/'), '').replace(new RegExp('\.js$'), '')

  bundle.push("  files[#{JSON.stringify(path)}] = #{JSON.stringify(data)};")

#
# Add a call to main js module, this allows you can completely skip the bootstrap file from
# the final bundle - the only thing needed is the shim that has been already included.
#
bundle.push("  require("+JSON.stringify(config.main)+")")

#################################################

#
# Load template and inject the bundle into it
#
data = fs.readFileSync('./template.js').toString().replace('//#!inject', bundle.join("\n"))

#################################################

#
# Save the bundle
#
fs.writeFileSync(config.output, data)

#################################################

#
# If the minify option in the config was set to true, we pass a final uglify over the whole
# bundle to make sure our footprint is as small as possible, as well as making sure our file-
# strings are using quotes (single or double) that produce least backslash overhead.
#
if config.minify
  console.log("")
  console.log("  > Uglify the bundle")

  #
  # Yes, really, read and save to same file
  #
  fs.writeFileSync(config.output, UglifyJS.minify(config.output).code)

#################################################

console.log("")
console.log("  > All done!")
console.log("")
