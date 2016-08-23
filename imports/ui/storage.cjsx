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
            <span>
              <a href='#' className="dropdown-toggle" data-toggle="dropdown">
                <i className="pull-right glyphicon glyphicon-remove"></i>
              </a>
              <form onClick={@dontClose} role="form" className="dropdown-menu dropdown-menu-right" style={padding:'1em'}>
                  <div className="form-group" style={width:'25em'}>
                    <h4>Delete data bucket '{bucket.name}'</h4>
                    <div className="alert alert-warning" role="alert">
                      All data inside the bucket will be removed. This operation is irreversible.<br />
                      <strong>Do you really want to delete this data bucket?</strong>
                    </div>

                  </div>
                  <button type="button" onClick={@props.onDelete?.bind(bucket)} className="clear-instance btn btn-mini btn-danger pull-right">Yes, destroy the data in this bucket!</button>
              </form>
            </span>
          }
        </div>
      }
    </div>
