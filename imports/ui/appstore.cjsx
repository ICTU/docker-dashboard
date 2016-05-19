{ Meteor }          = require 'meteor/meteor'
React               = require 'react'

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

Product = React.createClass
  displayName: 'Product'
  render: ->
    <div style=productStyle>
      <div style={height:120}>
        <span style={height:'100%', display:'inline-block', verticalAlign: 'middle'}></span>
        <img src={@props.img} style={maxHeight:100, maxWidth:150, verticalAlign: 'middle'} />
      </div>
      <div style={textAlign: 'left', letterSpacing:0.5, padding: 10, height: 100, position: 'relative'}>
        <h2 style={fontSize:19, margin:0}>{@props.name}</h2>
        <p><i style={fontSize:14}>{@props.version}</i></p>
        <div style={position: 'absolute', bottom: 0}>
          <span className="badge" style={backgroundColor:'lightgrey', color:'grey'}>42</span> installs
        </div>
        <div style={position:'absolute', bottom:0, right: 0}>
          <i className="material-icons">system_update_alt</i>
        </div>
      </div>
    </div>

module.exports.Appstore = React.createClass
  displayName: 'Appstore'
  render: ->
    <span>
      {@props.apps.map (app) ->
        <Product key=app._id name=app.name version=app.version img=app.pic />
      }
    </span>
