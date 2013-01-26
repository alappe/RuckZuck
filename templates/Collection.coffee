# @author {{ author }}, <{{ email }}>
namespace '{{ projectName }}.Collection', (exports) ->
  class exports.{{ name }} extends Backbone.Collection

    url: '/'

    initialize: -> console.log 'Initializing {{ name }} collection…'
