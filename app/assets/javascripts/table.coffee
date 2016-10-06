joinLeaveEvent = (message) ->
  players_html = "";
  for player in message.players
    players_html += "<div id=#{player.id}>#{player.name}</div>"
  $("#players").html(players_html)

  if message.players.length > 2 #TODO: make this check at the server
    $('#start').show()
  else
    $('#start').hide()

gameStarted = (message) ->
  $('#start').hide()

# revealCommonCardsEvent = (message) ->
#   cards_html = "";
#   for commoncards in message.commoncards
#     cards_html += "#{commoncards}"
#   $("#commoncards").html(cards_html)

flopReveal = (message) ->
  flop_html = "";
  for flop in message.flop
    flop_html += "#{flop}"
  $('.flop').html(flop_html)

turnReveal = (message) ->
  turn_html = "";
  for turn in message.turn
    turn_html += "#{turn}"
  $('.turn').html(turn_html)

riverReveal = (message) ->
  river_html = "";
  for river in message.river
    river_html += "#{river}"
  $('.river').html(river_html)

betEventMessages = (message) -> 
  message_html = "";
  for message in message.message
    message_html += "<div>#{message}</div>"
  $("#messages").append(message_html)

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
      when "GAME_START_EVENT" then gameStarted message.payload
      when "FLOP_REVEAL_EVENT" then flopReveal message.payload
      when "TURN_REVEAL_EVENT" then turnReveal message.payload
      when "RIVER_REVEAL_EVENT" then riverReveal message.payload
      when "BET_EVENT" then betEventMessages message.payload

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
