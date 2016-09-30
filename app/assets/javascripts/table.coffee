
joinLeaveEvent = (message) ->
  players_html = "";
  for player in message.players
    players_html += "<div id=#{player.id}>#{player.name}</div>"
  $("#players").html(players_html)

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
      when "JOIN_LEAVE_EVENT" then joinLeaveEvent message.payload

leaveTable = () ->
  console.log(App.table_channel)
  App.cable.subscriptions.remove(App.table_channel)
  $("#not-joined").show()
  $("#joined").hide()

$(document).on 'turbolinks:load', () ->
  $('.join-link').on 'ajax:beforeSend', joinTable
  $('.leave-link').on 'click', leaveTable
  $("#not-joined").show()
  $("#joined").hide()
