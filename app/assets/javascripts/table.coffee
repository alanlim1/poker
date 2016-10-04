dealHoleEvent = (message) ->
  hole_html = "";
  for allholes in message.allholes
    hole_html += "#{allholes}"
  $("#playerHand").html(hole_html)

dealCommonCardsEvent = (message) ->
  cards_html = "";
  for commoncards in message.commoncards
    cards_html += "#{commoncards}"
  $("#commoncards").html(cards_html)

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
      when "pre_bet" then pre_betEvent message.payload
      when "bet" then betEvent message.payload
      when "fold" then foldEvent message.payload
      when "flop" then flopEvent message.payload
      when "turn" then turnEvent message.payload
      when "river" then riverEvent message.payload

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