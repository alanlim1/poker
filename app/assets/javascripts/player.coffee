dealHoleEvent = (message) ->
  hole_html = "";
  for card in message.hole
    hole_html += "<div>#{card}</div>"
  $("#playerHand").html(hole_html)

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

leaveUserChannel = () ->
  console.log(App.web_notifications_channel)
  App.cable.subscriptions.remove(App.player_channel)

$(document).on 'turbolinks:load', () ->
  $('.join-link').on 'ajax:beforeSend', joinUserChannel
  $('.leave-game-link').on 'click', leaveUserChannel
