@APIKeys = new Mongo.Collection 'api-keys'

APIKeys.allow {
  insert: -> false,
  update: -> false,
  remove: -> false
}

APIKeys.deny {
  insert: -> true,
  update: -> true,
  remove: -> true
}
