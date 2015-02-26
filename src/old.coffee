# Description
#   A hubot script that warns you when a post has already been posted
#
# Dependencies:
#   hubot-redis-brain
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Author:
#   Antoine Lehurt

moment = require("moment")
urlNorm = require("url-norm")

module.exports = (robot) ->
  unless robot.brain.get("old")
    robot.brain.set("old", {})

  robot.hear /(\w+)\:\/\/([^\/\:]*)(\:\d+)?(\/?.*)/i, (msg) ->
    user = msg.message.user
    url = urlNorm(msg.match[0])

    cache = robot.brain.get("old")
    cachedData = cache[url]

    if cachedData and cachedData.user isnt user.name
      msg.send """
        Oops @#{user.name}, this link has already been shared:
        :point_right: #{url} by @#{cachedData.user} on <##{cachedData.room}> #{moment(cachedData.time).fromNow()}
      """
    else
      cache[url] =
        user: user.name
        room: msg.message.room
        time: new Date().getTime()

      robot.brain.set("old", cache)
      robot.brain.save()
