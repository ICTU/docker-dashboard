{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

Event = React.createClass
  displayName: 'Event'
  render: ->
    <div className="event">
      <div className="event-body">
        <div className="event-status-icon">
          <i className="material-icons">{@props.icon}</i>
        </div>
        <div className="event-message">
          <p>{@props.message}</p>
        </div>
      </div>
      <span className="event-timestamp">{moment(@props.timestamp).from()}</span>
    </div>

AppdefEvent = React.createClass
  displayName: 'AppdefEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    txt = switch e.action
      when 'added'   then "Application #{e.info.name}:#{e.info.version} was created."
      when 'changed' then "Application #{e.info.name}:#{e.info.version} was edited."
      when 'removed' then "Application #{e.info.name}:#{e.info.version} got removed."
    <Event message=txt timestamp=e.timestamp icon='apps' />

InstanceEvent = React.createClass
  displayName: 'InstanceEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    txt = switch e.action
      when 'starting' then <span>Instance <b>{e.info.name}</b> is starting...</span>
      when 'started'  then <span>Instance <b>{e.info.name}</b> has become active.</span>
      when 'stopping' then <span>Instance <b>{e.info.name}</b> is stopping...</span>
      when 'stopped'  then <span>Instance <b>{e.info.name}</b> has stopped.</span>
    <Event message=txt timestamp=e.timestamp icon='content_copy' />

exports.EventsList = EventsList = React.createClass
  displayName: 'EventsList'
  propTypes:
    events: React.PropTypes.array.isRequired
  renderEventItem: (eventItem) ->
    switch eventItem.subject
      when 'appdef' then <AppdefEvent event=eventItem />
      when 'instance' then <InstanceEvent event=eventItem />
  render: ->
    console.log 'render', @props
    <ul style={listStyleType:'none', padding: 0}>
      {@props.events and @props.events.map (eventItem) =>
        console.log eventItem
        <span key=eventItem._id>{@renderEventItem eventItem}</span>
      }
    </ul>

exports.EventsListContainer = EventsListContainer = createContainer (x) ->
  console.log 'createContainer', x
  Meteor.subscribe 'events'
  events = Events.find({}, sort: timestamp: -1).fetch()
  events: events
, EventsList

exports.EventsListView = EventsListView = React.createClass
  displayName: 'EventsListView'
  render: ->
    <div className="events-container">
      <div className="events-header">
        <b className="events-title">Event History</b>
        <a className="close-button" href="#">
          <div className="close-button-icon" ></div>
        </a>
      </div>
      <div className="content-container">
        <div className="content">
          <EventsListContainer />
        </div>
      </div>
    </div>
