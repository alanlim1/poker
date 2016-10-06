dealHoleEvent = (payload) ->
  hole_html = ""
  for card in payload.hole
    hole_html += "<div class=\"card card-#{card}\"></div>"
  $("#player-hand").html(hole_html)

doBet = (payload) =>
  $(".player_actions_child").show()
  $("#messages").append(payload.message)

hideActions = () =>
  $("#player_actions").hide()

joinUserChannel = () ->
  App.player_channel = App.cable.subscriptions.create {
      channel: "PlayerChannel"
  },

  connected: () ->
    console.log("Joined User Channel!")

  disconnected: () ->
    console.log("You left the game!")

  received: (message) ->
    console.log(message)
    # $('#commoncards').append message['message']
    switch message.type
      when "HOLE_EVENT" then dealHoleEvent message.payload
      when "BET_EVENT" then doBet message.payload

leaveUserChannel = () ->
  console.log(App.player_channel)
  App.cable.subscriptions.remove(App.player_channel)

$(document).on 'turbolinks:load', () ->
  $('.join-link').on 'ajax:beforeSend', joinUserChannel
  $('.raise').on 'ajax:success', hideActions
  $('.leave-game-link').on 'click', leaveUserChannel
