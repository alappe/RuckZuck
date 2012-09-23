# @author {{ author }}, <{{ email }}>
namespace '{{ projectName }}.Model', (exports) ->
  class exports.{{ name }} extends Backbone.Model

    # Use this if your backend is a couch
    #idAttribute: '_id'

    #
    #defaults:
    #  type: 'myType'
    #  edited_at: []

    #urlRoot: '/logs'
    #url: ->

    initialize: -> console.log 'Initializing {{ name }} model…'
