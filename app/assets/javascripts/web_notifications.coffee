dealHoleEvent = (message) ->
  cards_html = "";
  for commoncards in message.commoncards
    cards_html += "#{commoncards}"
  $("#commoncards").html(cards_html)
  hole_html = "";
  for playerHand in message.playerHand
    hole_html += "<div id=#{}>#{playerHand}</div>"
  $("#playerHand").html(hole_html)

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
    # $('#commoncards').append message['message']
    switch message.type
      when "GAME_START_EVENT" then dealHoleEvent message.payload

leaveGame = () ->
  console.log(App.web_notifications_channel)
  App.cable.subscriptions.remove(App.web_notifications_channel)

$(document).on 'turbolinks:load', () ->
  $('.start-link').on 'ajax:beforeSend', startGame
  $('.leave-game-link').on 'click', leaveGame
