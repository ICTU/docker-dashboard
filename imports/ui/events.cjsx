{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

Event = React.createClass
  displayName: 'Event'
  render: ->
    <div className="event">
      <div className="event-body">
        <div className="event-status-icon event-status-#{@props.type}">
          <i className="material-icons">{@props.icon}</i>
        </div>
        <div className="event-message">
          <p>{@props.message}</p>
        </div>
      </div>
      <span title={@props.timestamp} className="event-timestamp">{moment(@props.timestamp).from()}</span>
    </div>

eventType =

StorageEvent = React.createClass
  displayName: 'StorageEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    txt = switch e.action
      when 'added'   then <span>Storage bucket <b>{e.info.name}</b> was created.</span>
      when 'locked' then <span>Storage bucket <b>{e.info.name}</b> has become unavailable.</span>
      when 'unlocked' then <span>Storage bucket <b>{e.info.name}</b> has become available.</span>
      when 'removed' then <span>Storage bucket <b>{e.info.name}</b> got removed.</span>
    <Event message=txt timestamp=e.timestamp icon='storage' type=e.type />

AppdefEvent = React.createClass
  displayName: 'AppdefEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    txt = switch e.action
      when 'added'   then <span>Application <b>{e.info.name}:{e.info.version}</b> was created.</span>
      when 'changed' then <span>Application <b>{e.info.name}:{e.info.version}</b> was edited.</span>
      when 'removed' then <span>Application <b>{e.info.name}:{e.info.version}</b> got removed.</span>
    <Event message=txt timestamp=e.timestamp icon='apps' type=e.type />

InstanceEvent = React.createClass
  displayName: 'InstanceEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    user = e.info.user?.username
    txt = switch e.action
      when 'starting' then <span>Instance <b>{e.info.name}</b> is started by <i>{user}</i>.</span>
      when 'started'  then <span>Instance <b>{e.info.name}</b> has become active.</span>
      when 'stopping' then <span>Instance <b>{e.info.name}</b> is stopped by <i>{user}</i>.</span>
      when 'stopped'  then <span>Instance <b>{e.info.name}</b> has stopped.</span>
    <Event message=txt timestamp=e.timestamp icon='content_copy' type=e.type />

exports.EventsList = EventsList = React.createClass
  displayName: 'EventsList'
  propTypes:
    events: React.PropTypes.array.isRequired
  renderEventItem: (eventItem) ->
    switch eventItem.subject
      when 'appdef' then <AppdefEvent event=eventItem />
      when 'instance' then <InstanceEvent event=eventItem />
      when 'storage' then <StorageEvent event=eventItem />
  render: ->
    <ul style={listStyleType:'none', padding: 0}>
      {@props.events and @props.events.map (eventItem) =>
        <span key=eventItem._id>{@renderEventItem eventItem}</span>
      }
    </ul>

exports.EventsListContainer = EventsListContainer = createContainer (x) ->
  Meteor.subscribe 'events'
  events = Events.find({}, sort: timestamp: -1).fetch()
  events: events
, EventsList

exports.EventsListView = EventsListView = React.createClass
  displayName: 'EventsListView'
  getInitialState: ->  display: 'none'
  toggle: -> if @state.display is 'none' then @open() else @close()
  open: ->  @setState display: 'block'
  close: -> @setState display: 'none'
  render: ->
    @props.onRender @
    <div className="events-container" style={display: @state.display}>
      <div className="events-header">
        <b className="events-title">Event History</b>
        <a className="close-button" href="#" onClick={@close}>
          <div className="close-button-icon" ></div>
        </a>
      </div>
      <div className="content-container">
        <div className="content">
          <EventsListContainer />
        </div>
      </div>
    </div>
