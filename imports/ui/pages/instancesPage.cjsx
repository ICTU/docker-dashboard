React               = require 'react'
Card                = require '../card.cjsx'
InstanceList        = require '../meteor/instanceList.cjsx'
InstanceInfo        = require '../meteor/instanceInfo.cjsx'
InstanceOverview    = require '../meteor/instanceOverview.cjsx'

cardListStyle =
  minHeight: 'calc(100vh - 90px)'
  margin: 0
  marginTop: 10

cardStyle =
  margin: 0
  marginTop: 10
  width: 500
  float: 'left'

colMd = (num, html) -> <div className="col-md-#{num}">{html()}</div>

module.exports  = React.createClass
  displayName: 'InstancesPage'
  propTypes:
    activeInstance: React.PropTypes.string
  render: ->
    <div className='container-fluid'>
      <div className='instancesPage row'>
        {colMd 3, =>
          <Card style=cardListStyle title='Instances' category='Running applications'>
            <InstanceList activeInstance={@props.activeInstance} />
          </Card>
        }
        {if @props.activeInstance then colMd 9, =>
          <InstanceOverview instanceName={@props.activeInstance} />
        }
      </div>
    </div>
