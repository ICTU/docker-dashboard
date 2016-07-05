{ Meteor }          = require 'meteor/meteor'
React               = require 'react'
Helpers             = require '../helpers.coffee'

productStyle =
  width: '19%'
  height: '230px'
  float: 'left'
  overflow: 'hidden'
  margin: '5px'
  border: '1px solid lightgrey'
  borderRadius: 2
  boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
  textAlign: 'center'

ApplicationDefinition = React.createClass
  displayName: 'ApplicationDefinition'
  componentDidMount: ->
    editor = ace.edit $(@refs.appDefEditor).get(0)
    editor.setOptions
      readOnly: true
      highlightActiveLine: false
      highlightGutterLine: false
    editor.setTheme "ace/theme/chrome"
    editor.getSession().setMode "ace/mode/yaml"
    editor.getSession().setUseWrapMode(true)
  setEditorValue: (definition) ->
    editor = ace.edit $(@refs.appDefEditor).get(0)
    editor.getSession().setValue definition
  render: ->
    <div id="ace" ref="appDefEditor" className="appDefEditor" style={height:600}></div>

ProductDetails = React.createClass
  displayName: 'ProductDetails'
  getInitialState: ->
    selectedApp: @props.definitions[0]
  changeSelectedVersion: (app) -> =>
    @setState selectedApp: app
    @refs.applicationDefinition.setEditorValue app.def
  installApp: ->
    app = @state.selectedApp
    Meteor.call 'saveApp', app.name, app.version, app.def, =>
      console.log 'saveAppDone'
      $(@refs.modal).modal 'hide'

  componentDidMount: ->
    @refs.applicationDefinition.setEditorValue @state.selectedApp.def
    $(@refs.modal).modal 'show'
    $(@refs.modal).on 'hidden.bs.modal', (e) =>
      @props.modalHidden?()
  render: ->
    <div ref="modal" id="productDetailModal" className="modal fade" tabindex="-1" role="dialog">
      <div className="modal-dialog modal-lg">
        <div className="modal-content">
          <div className="modal-body">
            <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <div className="row">
              <div className="col-md-2" style={borderRight:'1px dashed lightgrey'}>
                <div style={height:100}>
                  <span style={height:'100%', display:'inline-block', verticalAlign: 'middle'}></span>
                  <img src={@props.img} style={maxHeight:150, maxWidth:'100%', verticalAlign: 'middle'} />
                </div>
              </div>
              <div className="col-md-8">
                <h2>{@props.name}</h2>
                <div className="btn-group">
                  <button type="button" className="btn btn-default" disabled=true>version: {@state.selectedApp.version}</button>
                  {if @props.definitions.length > 1
                    [
                      <button type="button" className="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <span className="caret"></span>
                        <span className="sr-only">Select version</span>
                      </button>
                      <ul className="dropdown-menu">
                      {@props.definitions.map (app) =>
                        <li><a key=app.version href="#" onClick={@changeSelectedVersion app}>{app.version}</a></li>
                      }
                      </ul>
                    ]
                  }
                </div>
              </div>
              <div className="col-md-2" style={paddingTop:25}>
                {if Helpers.isAuthenticated()
                  [
                    <button type="button" className="btn btn-success btn-lg dropdown-toggle" data-toggle="dropdown"><i className="material-icons">file_download</i> Install</button>
                    <form role="form" className="dropdown-menu dropdown-menu-right" style={padding:10}>
                        <div className="form-group" style={width:350}>
                          <div className="alert alert-warning" role="alert">
                            Installing may overwrite an existing app called <strong>{@state.selectedApp.name}</strong> with version <strong>{@state.selectedApp.version}</strong>.
                            <br />
                            Do you wish to continue?
                          </div>
                        </div>
                        <button onClick={@installApp} type="button" className="btn-install-app btn btn-lg btn-success pull-right">Yes!</button>
                    </form>
                  ]}
              </div>
            </div>
            <div className="row" style={paddingTop:20}>
              <div className="col-md-12" style={paddingLeft:100}>
                <ApplicationDefinition ref="applicationDefinition" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

Product = React.createClass
  displayName: 'Product'
  getInitialState: ->
    showDetails: false
  onTouchTap: ->
    @setState showDetails: true
  modalHidden: ->
    @setState showDetails: false
  listHowManyMoreVersions: ->
    if x = @props.definitions.length - 1 then " + #{x} more"
  render: ->
    <div className='appStoreProduct' style=productStyle onClick={@onTouchTap}>
      <div style={height:120}>
        <span style={height:'100%', display:'inline-block', verticalAlign: 'middle'}></span>
        <img src={@props.img} style={maxHeight:100, maxWidth:150, verticalAlign: 'middle'} />
      </div>
      <div style={textAlign: 'left', letterSpacing:0.5, padding: 10, height: 100, position: 'relative'}>
        <h2 style={fontSize:19, margin:0}>{@props.name}</h2>
        <p><i style={fontSize:14}>{@props.version}{@listHowManyMoreVersions()}</i></p>
        {if false
          <div style={position: 'absolute', bottom: 0}>
            <span className="badge" style={backgroundColor:'lightgrey', color:'grey'}>42</span> installs
          </div>
        }

        {if @state.showDetails
          <ProductDetails {...@props} modalHidden={@modalHidden} />
        }
      </div>
    </div>

module.exports.Appstore = React.createClass
  displayName: 'Appstore'
  render: ->
    <span>
      {if @props.apps
        x = _.reduce @props.apps.fetch(), (prev, curr) ->
          unless prev[curr.name]
            prev[curr.name] =
              name: curr.name
              version: curr.version
              img: curr.pic
              definitions: [curr]
          else prev[curr.name].definitions.push curr
          prev
        , {}
        for key, app of x
          <Product key=app.name name=app.name version=app.version img=app.img definitions=app.definitions />
      }
    </span>
