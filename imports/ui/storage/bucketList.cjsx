{ Meteor }          = require 'meteor/meteor'
React               = require 'react'
StorageBucket       = require './bucket.cjsx'

module.exports = React.createClass
  displayName: 'StorageBucketList'

  propTypes:
    buckets: React.PropTypes.array.isRequired
    onDelete: React.PropTypes.func
    onCopy: React.PropTypes.func
    authenticated: React.PropTypes.bool.isRequired

  render: ->
    <div className="list-group">
      {for bucket in @props.buckets
        <StorageBucket
          key={bucket._id}
          bucket={bucket}
          onCopy={@props.onCopy}
          onDelete={@props.onDelete}
          displayButtons={@props.authenticated} />
      }
    </div>
