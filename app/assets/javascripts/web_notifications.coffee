dealHoleEvent = (message) ->
  players_html = "";
  for player in message.players
    players_html += "<div id=#{player.id}>#{player.name}</div>"
  $("#players").html(players_html)

startGame = () ->
  App.web_notifications_channel = App.cable.subscriptions.create {
      channel: "WebNotificationsChannel"
  },

  connected: () ->
    console.log("Game started!")
    $("#not-joined").hide()
    $("#joined").hide()   
    $(".leave-game-link").show()
    $(".start-link").hide()

  disconnected: () ->
    console.log("You left the game!")
    $("#not-joined").hide()
    $("#joined").hide()
    $(".leave-game-link").hide()
    $(".start-link").show()

  received: (message) ->
    console.log(message)
    switch message.type
      when "GAME_START_EVENT" then dealHoleEvent message.payload

leaveGame = () ->
  console.log(App.web_notifications_channel)
  App.cable.subscriptions.remove(App.web_notifications_channel)

$(document).on 'turbolinks:load', () ->
  $('.start-link').on 'ajax:beforeSend', startGame
  $('.leave-game-link').on 'click', leaveGame
