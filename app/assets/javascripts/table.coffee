
playerJoined = (message) ->
  $("#players").append("<div id=#{message.player.id}>#{message.player.name}</div>")


playerLeft = (message) ->
  $("#players ##{message.player.id}").remove()


joinTable = () ->
  App.table_channel = App.cable.subscriptions.create {
      channel: "TableChannel"
  },

  connected: () ->
    console.log("Connected")
    $("#not-joined").hide()
    $("#joined").show()

  disconnected: () ->
    console.log("Disconnected")
    $("#not-joined").show()
    $("#joined").hide()

  received: (message) ->
    console.log(message)
    switch message.type
      when "PLAYER_JOINED" then playerJoined message.payload
      when "PLAYER_LEFT" then playerLeft message.payload

leaveTable = () ->
  console.log(App.table_channel)
  App.cable.subscriptions.remove(App.table_channel)
  # App.cable.disconnect()
  $("#not-joined").show()
  $("#joined").hide()

$(document).on 'turbolinks:load', () ->
  $('.join-link').on 'ajax:beforeSend', joinTable
  $('.leave-link').on 'click', leaveTable
  $("#not-joined").show()
  $("#joined").hide()
