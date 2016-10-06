React               = require 'react'

module.exports  = React.createClass
  displayName: 'Card'
  propTypes:
    title: React.PropTypes.string.isRequired
    category: React.PropTypes.string.isRequired
    style: React.PropTypes.object
    children: React.PropTypes.node
    altHeader: React.PropTypes.node
  render: ->
    <div className='card' style={@props.style}>
      <div className='header' style={display: 'inline-block'}>
        <h4 className='title'>{@props.title}</h4>
        <p className="category">{@props.category}</p>
      </div>
      {if @props.altHeader
        <div className='alt-header' style={display: 'inline-block', float:'right', padding:15}>
          {@props.altHeader}
        </div>
      }
      <div className='content'>{@props.children}</div>

    </div>
