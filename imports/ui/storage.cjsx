{ Meteor }          = require 'meteor/meteor'
React               = require 'react'

module.exports = React.createClass
  displayName: 'Storage'

  propTypes:
    buckets: React.PropTypes.array.isRequired
    onDelete: React.PropTypes.func
    authenticated: React.PropTypes.bool.isRequired

  render: ->
    <div className="list-group">
      {for bucket in @props.buckets
        <div className="list-group-item" key={bucket._id}>
          <span>{bucket.name}</span>
          {if @props.authenticated
            <a onClick={@props.onDelete?.bind(bucket)}>
              <span className="pull-right glyphicon glyphicon-remove" aria-hidden="true"></span>
            </a>
          }
        </div>
      }
    </div>
