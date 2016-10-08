dealHoleEvent = (payload) ->
  hole_html = ""
  for card in payload.hole
    hole_html += "<div class=\"card card-#{card}\"></div>"
  $("#player-hand").html(hole_html)

doBet = (payload) =>
  $(".player_actions_child").show()
  $("#messages").append(payload.message)

reRaiseEvent = (payload) =>
  $(".player_actions_child").show()
  $("#messages").append(payload.message)

hideActions = () =>
  $("#player_actions").hide()
  $(".player_actions_child").hide()

joinUserChannel = () ->
  App.player_channel = App.cable.subscriptions.create {
      channel: "PlayerChannel"
  },

  connected: () ->
    console.log("Joined Player Channel!")

  disconnected: () ->
    console.log("You left the game!")

  received: (message) ->
    console.log(message)
    switch message.type
      when "HOLE_EVENT" then dealHoleEvent message.payload
      when "BET_EVENT" then doBet message.payload
      # when "RERAISE_EVENT" then reRaiseEvent message.payload

leaveUserChannel = () ->
  console.log(App.player_channel)
  App.cable.subscriptions.remove(App.player_channel)

$(document).on 'turbolinks:load', () ->
  $('.join-link').on 'ajax:beforeSend', joinUserChannel
  $('.raise').on 'ajax:success', hideActions
  $('.fold-link btn btn-danger').on 'ajax:success', hideActions
  $('.call-link btn-warning').on 'ajax:success', hideActions
  $('.check-link btn btn-primary').on 'ajax:success', hideActions
  # $('.leave-game-link').on 'click', leaveUserChannel
