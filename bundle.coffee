
fs = require('fs')
nodepath = require('path')
UglifyJS = require("uglify-js2")

#################################################

bundle = []
files = {}

throw "Didn't find config.json, copy example.config.json to start!" if not fs.existsSync('config.json')

config = JSON.parse(fs.readFileSync('config.json'))

#################################################

console.log("")
console.log("  > Running bootstrap confing, reading and uglifying vendor stuff")

isIgnored = (item) ->
  for path in config.ignore
    return true if nodepath.relative(item, path) is ''
  return false

r = ->
r.config = (options) ->
  paths = options.paths or {}

  bundle.push("  shim = "+JSON.stringify(options.shim)) if options.shim

  for label, path of paths
    path = config.assets + '/' + path + '.js'
    if not isIgnored(path)
      label = label.replace(new RegExp('\\\\', 'g'), '/')
      console.log("  --- "+label+" from "+path)
      files[label] = UglifyJS.minify(path).code

bootstrap = fs.readFileSync(config.bootstrap).toString()

eval('(function(require){'+bootstrap+'})')(r)

#################################################

console.log("")
console.log("  > Reading and uglifying all asset files")

#
# Read all files
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
#
# Bundle all files into javascript hash
#

console.log("")
console.log("  > Bundling")

for path, data of files
  path = path.replace(new RegExp('^\.\/compiled\/'), '').replace(new RegExp('\.js$'), '')

  bundle.push("  files[#{JSON.stringify(path)}] = #{JSON.stringify(data)};")

#
# Add a call to main js module
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
