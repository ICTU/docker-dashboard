{ Meteor }          = require 'meteor/meteor'
React               = require 'react'

module.exports = React.createClass
  displayName: 'StorageBucketList'

  propTypes:
    bucket: React.PropTypes.object.isRequired
    onDelete: React.PropTypes.func
    onCopy: React.PropTypes.func
    displayButtons: React.PropTypes.bool.isRequired

  copy: (bucket) -> (e) =>
    e.preventDefault()
    @props.onCopy bucket.name, @refs.bucketName.value

  render: ->
    bucket = @props.bucket
    console.log bucket
    <div className="list-group-item storage-bucket" data-bucket-name={bucket.name}>
      <span className="bucket-name">{bucket.name}</span>
      {if @props.displaySpinner
        <img className="pull-right" src="/img/svg/hourglass.svg" style={marginTop: -5} />
      }
      {if @props.displayButtons
        <span>
          <span>
            <a href='#' className="dropdown-toggle" data-toggle="dropdown" title="Delete">
              <i className="delete-bucket pull-right material-icons">delete_forever</i>
            </a>
            <form onClick={@dontClose} role="form" className="delete-bucket-form dropdown-menu dropdown-menu-right" style={padding:'1em'}>
                <div className="form-group" style={width:'25em'}>
                  <h4>Delete data bucket '{bucket.name}'</h4>
                  <div className="alert alert-warning" role="alert">
                    All data inside the bucket will be removed. This operation is irreversible.<br />
                    <strong>Do you really want to delete this data bucket?</strong>
                  </div>
                </div>
                <button type="button" onClick={@props.onDelete?.bind(bucket)}
                  className="delete-bucket-confirm btn btn-mini btn-danger pull-right">
                  Yes, destroy the data in this bucket!
                </button>
            </form>
          </span>
          <span>
            <a href='#' className="dropdown-toggle" data-toggle="dropdown" title="Copy">
              <i className="copy-bucket pull-right material-icons">content_copy</i>
            </a>
            <form onSubmit={@copy(bucket)} role="form" className="copy-bucket-form dropdown-menu dropdown-menu-right" style={padding:'1em'}>
                <div className="form-group" style={width:'30em'}>
                    <label>Bucket name (must match [a-zA-Z0-9_-]+)</label>
                    <input ref='bucketName' required pattern="[a-zA-Z0-9_-]+" type="text"
                      name='bucket-name'
                      className="form-control bucket-name"
                      placeholder="Alphanummeric, underscores and dashes; no spaces" />
                </div>
                <button type="submit"
                  className="copy-bucket-submit btn btn-mini">
                  Copy
                </button>
            </form>
          </span>
        </span>
      }
      <span className="pull-right" style={marginRight: 10, marginTop: 3, fontSize: 12, color: "grey"}>
        Created {moment(bucket.created).fromNow()}
      </span>
    </div>
