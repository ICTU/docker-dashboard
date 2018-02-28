{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

module.exports = React.createClass
  displayName: 'AppActions'

  getInitialState: ->
    name: @props.appName
    bucket: ''
    parameters: {}

  handleRun: ->
    @props.onRun @state

  handleNameChange: (event) ->
    @setState name: event.target.value

  handleBucketChange: (event) ->
    @setState bucket: event.target.value

  handleParamChange: (event) ->
    parameters = @state.parameters
    parameters[event.target.dataset.parameter] = event.target.value
    @setState parameters: parameters

  componentWillReceiveProps: ->
    @setState name: @props.appName

  render: ->
    <ul className="nav nav-justified">
      <li className="btn-group">
        <button data-toggle="dropdown"
          id="runButton"
          type="button"
          style={marginTop:15, marginRight: 10}
          className="btn btn-success pull-right">Start</button>
        <form onClick={@handleRun}
          id="start-app-form" role="form"
          className="dropdown-menu dropdown-menu-right"
          style={padding: "1em"}>

          <div className="form-group">
              <label>Instance name (must match [a-z0-9-]+)</label>
              <input required pattern="[a-z0-9-]+" type="text"
                value={@state.name}
                className="form-control instance-name"
                placeholder="Alphanummeric, underscores and dashes; no spaces"
                onChange={@handleNameChange}></input>

              <label>Storage bucket</label>
              <select className="form-control storage-bucket" onChange={@handleBucketChange}>
                <option value="!! instance name !!">Use instance name</option>
                <option value="!! do not persist !!">Do not persist</option>
                <optgroup label="Available storage buckets">
                {for sb in @props.storageBuckets or []
                  <option value={sb.name} key={sb.name}>{sb.name}}</option>
                }
                </optgroup>
              </select>

              {if @props.parameters.length
                <div className="divider" style={paddingTop: "5px"}></div>
              }
              {for param in @props.parameters or []
                <div key={param}>
                  <label>{param}</label>
                  <input required type="text"
                    className="form-control parameter"
                    data-parameter={param}
                    onChange={@handleParamChange}>
                  </input>
                </div>
              }
          </div>
          {if @props.systemNotHealthy
            <div style={float: "left", color: "#D40000", width: 280, fontSize: 14}>
              <span className="glyphicon glyphicon-exclamation-sign"></span>
              The system is not healthy, your instance may not start.</div>
          }
          <button type="button"
            className="btn btn-mini pull-right">Go!</button>
        </form>
      </li>
    </ul>
