

tableChannelFunctions = () ->
  if $('.table-container').length > 0
    App.table_channel = App.cable.subscriptions.create {
        channel: "TableChannel"
    },
    connected: () ->
      console.log("Connected");
    #end

    disconnected: () ->
    #end

    received: (data) ->
      console.log(data)
      switch data.type
        when "create" then createComment(data)
        when "update" then updateComment(data)
        when "destroy" then destroyComment(data)
      #end
    #end
  #end
#end
$(document).on 'turbolinks:load', tableChannelFunctions
