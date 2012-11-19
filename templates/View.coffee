# @author {{ author }}, <{{ email }}>
namespace '{{ projectName }}.View', (exports) ->
  class exports.{{ name }} extends Backbone.View

    initialize: ->
      # @template = _.template top.{{ projectName }}.Templates.{{ name }}
      console.log 'Initializing {{ name }} view…'

    render: ->
      console.log 'render'
      # @$el.html (@template @model.toJSON())
      @
