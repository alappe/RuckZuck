#!/usr/bin/env coffee

# wraps optimist with the configured cli options:
optimist = require './cliOptions'

fs = require 'fs'
path = require 'path'
findit = require 'findit'
exec = (require 'child_process').exec

_ = require 'underscore'
_.templateSettings =
  evaluate: /\{\[([\s\S]+?)\]\}/g
  interpolate: /\{\{([\s\S]+?)\}\}/g

# The main class to structure the code…
class RuckZuck

  basicValues:
    year: new Date().getFullYear()
    author: ''
    email: ''
    projectName: ''
    projectUnderline: ''

  constructor: (argv) ->
    # At the moment there is only one action:
    if argv.create and argv.project and argv._.length is 1
      @createProject argv._[0]
    else if argv.create and argv.model and argv._.length is 1
      @createModel argv._[0]
    else if argv.create and argv.view and argv._.length is 1
      @createView argv._[0]
    else
      console.log optimist.help()
      process.exit 1

  createProject: (projectName) ->
    console.log "Kickstarting your project »#{projectName}«"
    @basicValues.projectName = projectName
    @basicValues.projectUnderline += '=' for i in projectName
    @resolveAuthor()
    @templatePath = path.resolve __dirname, '../templates/basicStructure'

    @mkdir projectName

    requireTree = []

    # For every entry
    for entry in findit.sync @templatePath
      stat = fs.statSync entry
      relativePath = (entry.slice (@templatePath.length + 1)).replace /\d{3}_/, ''
      projectPath = path.join projectName, relativePath
      if stat.isDirectory()
        requireTree.push relativePath
        @mkdir projectPath
      if stat.isFile()
        fileTemplate = _.template (fs.readFileSync entry).toString()
        fs.writeFileSync projectPath, (fileTemplate @basicValues)

    # Write router which includes all necessary files/directories:
    routerTemplate = _.template (fs.readFileSync (path.resolve @templatePath, '../App.coffee')).toString()
    @basicValues.requireTree = @buildRequireDirectives requireTree
    fs.writeFileSync (path.join projectName, 'router', "#{projectName}.coffee"), routerTemplate @basicValues

    # Write Cakefile
    cakeTemplate = _.template (fs.readFileSync (path.resolve @templatePath, '../Cakefile')).toString()
    fs.writeFileSync (path.join projectName, 'Cakefile'), cakeTemplate @basicValues

    # Write the configuration file
    @writeConfiguration projectName, @basicValues

    # Write package.json
    packageJson =
      name: @basicValues.projectName
      author: @basicValues.author
      dependencies: {}
    fs.writeFileSync (path.join projectName, 'package.json'), (JSON.stringify packageJson, null, 2)
    # Install dependencies for build process:
    console.log "Installing basic build-process dependencies locally: snockets, coffee-script, uglify-js…"
    exec 'npm install snockets coffee-script uglify-js', cwd: projectName

  # Write the configuration to a file (.ruckruckrc)
  #
  # @param [String] relativePath
  # @param [Object] configuration
  writeConfiguration: (relativePath, configuration) ->
    fs.writeFileSync (path.resolve relativePath, '.ruckzuckrc'), (JSON.stringify configuration)

  # Read in the configuration and return it.
  #
  # @return [Object]
  getConfiguration: ->
    configurationPath = undefined
    for i in ['.', '..', '../..']
      possiblePath = path.resolve i, '.ruckzuckrc'
      configurationPath = possiblePath if fs.existsSync possiblePath
    throw Error 'Cannot find your project\'s .ruckzuckrc. Are you in your project?' unless configurationPath?
    configuration = JSON.parse (fs.readFileSync configurationPath)
    configuration.relativePath = configurationPath
    configuration

  # Create a model
  #
  # @param [String] name
  createModel: (name) ->
    configuration = @getConfiguration()
    configuration.name = name
    templatePath = path.resolve __dirname, '../templates/Model.coffee'
    modelPath = path.resolve (path.dirname configuration.relativePath), 'models', "#{name}.coffee"
    modelTemplate = _.template (fs.readFileSync templatePath).toString()
    fs.writeFileSync modelPath, modelTemplate configuration

  # Create a view
  #
  # @param [String] name
  createView: (name) ->
    configuration = @getConfiguration()
    configuration.name = name
    templatePath = path.resolve __dirname, '../templates/View.coffee'
    viewPath = path.resolve (path.dirname configuration.relativePath), 'views', "#{name}.coffee"
    viewTemplate = _.template (fs.readFileSync templatePath).toString()
    fs.writeFileSync viewPath, viewTemplate configuration

  # Build a string of require-directives to include necessary
  # directories and files.
  #
  # @param [Array] requireTree
  # @return [String]
  buildRequireDirectives: (requireTree) ->
    requires = ''
    for entry in requireTree
      unless entry is 'router' or entry is 'tests'
        relEntry = path.join '..', entry
        requires += "#= require_tree #{relEntry}\n"
    requires

  # Resolve the name and email from ~/.gitconfig
  resolveAuthor: ->
    gitconfig = (fs.readFileSync (path.join process.env.HOME, '.gitconfig')).toString()
    for line in (gitconfig.split '\n')
      @basicValues.author = line.replace /^.*name = ([\w\s]+)$/, '$1' if (line.match /name = [\w\s]+/)?
      @basicValues.email = line.replace /^.*email = (.+)$/, '$1' if (line.match /email = .+/)?
    for val in ['name', 'email']
      console.log "Warning: I can not resolve #{val} automatically… correct them in the created files!" if @basicValues[val] is ''

  # Wrapper around fs.mkdir to ensure the directory to be created
  # doesn't exist yet—aborts if it does.
  #
  # @param [String] path
  mkdir: (path) ->
    if fs.existsSync path
      console.log "The directory »#{path}» already exists. I will not override it!"
      process.exit 1
    fs.mkdirSync path

rz = new RuckZuck optimist.argv
