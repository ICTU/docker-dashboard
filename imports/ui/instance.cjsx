{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

Instance = React.createClass
  displayName: 'Instance'
  render: ->
    instance = @props.instance
    unless instance
      <span></span>
    else
      <div>
        <ul className="nav nav-justified pull-right" style={marginBottom:'5px'}>
          <li className="btn-group">
            <a title="Logs" target="_blank" href="{{pathFor route='instanceLogs' instanceId=_id}}">
              <i className="glyphicon glyphicon-lg glyphicon-list-alt"></i>
            </a>
          </li>
          <li className="btn-group">

            <a title="Stop" href="#" className="dropdown-toggle" data-toggle="dropdown">
              <i className="glyphicon glyphicon-lg glyphicon-stop"></i>
            </a>
            <form role="form" className="dropdown-menu dropdown-menu-right" style={padding:'1em'}>
                <div className="form-group" style={width:'20em'}>
                  Do you really want to stop this application?
                </div>
                <button type="button" className="stop-instance btn btn-mini btn-danger pull-right">Yes!</button>
            </form>

          </li>
          <li className="btn-group">

            <a href="#" className="dropdown-toggle" data-toggle="dropdown">
              <i className="glyphicon glyphicon-lg glyphicon-trash"></i>
            </a>
            <form role="form" className="dropdown-menu dropdown-menu-right" style={padding:'1em'}>
                <div className="form-group" style={width:'20em'}>
                  <div className="alert alert-warning" role="alert">
                    <span className="label label-danger">Expert feature!</span> <br />
                    Do you really want to clear the instance meta information?
                  </div>

                </div>
                <button type="button" className="clear-instance btn btn-mini btn-danger pull-right">Yes!</button>
            </form>

          </li>
        </ul>

        <table className="table table-condensed">
          <tbody>
            <tr><th scope="row" style={width:'250px'}>State</th><td>{instance.state}</td></tr>
            <tr><th scope="row" >Application name</th><td>{instance.app.name}</td></tr>
            <tr><th scope="row">Application version</th><td>{instance.app.version}</td></tr>
          </tbody>
        </table>
      </div>


module.exports = createContainer (x) ->
  Meteor.subscribe 'instances'
  instance = Instances.findOne name: x.name
  instance: instance
, Instance
