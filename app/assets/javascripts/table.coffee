tableChannelFunctions = () ->
  if $('.table-container').length > 0
    App.table_channel = App.cable.subscriptions.create {
        channel: "TableChannel"
    },

    connected: () ->
      console.log("Connected");

    disconnected: () ->
      console.log("Disconnected");

    received: (data) ->
      console.log("Player has left");

$(document).on 'turbolinks:load', tableChannelFunctions
