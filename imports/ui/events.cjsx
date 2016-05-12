{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

Event = React.createClass
  displayName: 'Event'
  render: ->
    <span>
      <div className="event">
        <div className="event-body">
          <p>{@props.message}</p>
        </div>
        <span className="event-timestamp">{moment(@props.timestamp).from()}</span>
      </div>
      <div className="intercom-conversation-parts">
        <div className="intercom-conversation-part">
          <div className="intercom-comment intercom-comment-by-admin">
            <div className="intercom-comment-body-container">
              <div className="intercom-comment-body intercom-embed-body">
                <p>{@props.message}</p>
              </div>
            </div>
            <div className="intercom-comment-metadata-container">
              <div className="intercom-comment-metadata">
                <span className="intercom-comment-state">
                </span>
                <span className="intercom-relative-time">{moment(@props.timestamp).from()}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </span>

AppdefEvent = React.createClass
  displayName: 'AppdefEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    txt = switch e.action
      when 'added'   then "Application #{e.info.name}:#{e.info.version} was created."
      when 'changed' then "Application #{e.info.name}:#{e.info.version} was edited."
      when 'removed' then "Application #{e.info.name}:#{e.info.version} got removed."
    <Event message=txt timestamp=e.timestamp />

InstanceEvent = React.createClass
  displayName: 'InstanceEvent'
  propTypes: event: React.PropTypes.object.isRequired
  render: ->
    e = @props.event
    txt = switch e.action
      when 'starting' then "Instance #{e.info.name} is starting..."
      when 'started'  then "Instance #{e.info.name} has become active."
      when 'stopping' then "Instance #{e.info.name} is stopping..."
      when 'stopped'  then "Instance #{e.info.name} has stopped."
    <Event message=txt timestamp=e.timestamp />

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
        <b className="intercom-sheet-header-title">Events</b>
        <a className="close-button" href="#">
          <div className="intercom-sheet-header-button-icon" ></div>
        </a>
      </div>
      <div className="content">
        <EventsListContainer />
      </div>
    </div>
