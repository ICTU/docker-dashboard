@Projects = new Mongo.Collection 'projects'

Projects.attachSchema new SimpleSchema
  name:
    type: String
    label: "Project name"
