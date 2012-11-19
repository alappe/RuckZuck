optimist = require 'optimist'

options = [
    short: 'c'
    long: 'create'
    describe: 'Create a file/project'
    boolean: true
  ,
    short: 'p'
    long: 'project'
    describe: 'Handle a project'
    boolean: true
  ,
    short: 'm'
    long: 'model'
    describe: 'Handle a model'
    boolean: true
  ,
    short: 'v'
    long: 'view'
    describe: 'Handle a view'
    boolean: true
  ,
    short: 't'
    long: 'template'
    describe: 'Handle a template'
    boolean: true
]

for option in options
  optimist = optimist.alias option.short, option.long
  optimist = optimist.demand option.short if option.demand
  optimist = optimist.boolean option.short if option.boolean
  optimist = optimist.describe option.short, option.describe

optimist.usage """
Usage:

  Kickstart a project with:

    $0 --create --project <MyProject>
    or
    $0 -c -p <MyProject>

"""

module.exports = optimist
