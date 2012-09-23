{{ requireTree }}
# Router
#
# @author {{ author }}, <{{ email }}>
namespace '{{ projectName }}.Router', (exports) ->
  class exports.App extends Backbone.Router

    #events:

    routes:
      '': 'indexAction'

    initialize: ->
      console.log 'initialize router…'

    indexAction: ->
      console.log 'indexAction'
