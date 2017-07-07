
module.exports = () ->
    _.map process.env.DEPLOY_KEYS?.split(','), (key) -> key.trim() or []

