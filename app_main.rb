require 'sinatra'
require 'line/bot'

# 微小変更部分！確認用。
get '/' do
  "Hello world"
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
  type: "template",
  altText: "this is a carousel template",
  template: {
      type: "carousel",
      columns: [
          {
            thumbnailImageUrl: "http://www.enjoytokyo.jp/img/s_e/11140/1113625IMG1.jpg",
            title: "this is menu",
            text: "description",
            actions: [
                {
                    type: "postback",
                    label: "Buy",
                    data: "action=buy&itemid=111"
                },
                {
                    type: "postback",
                    label: "Add to cart",
                    data: "action=add&itemid=111"
                },
                {
                    type: "uri",
                    label: "View detail",
                    uri: "http://www.enjoytokyo.jp/img/s_e/13080/1307816IMG1.jpg"
                }
            ]
          },
          {
            thumbnailImageUrl: "http://www.enjoytokyo.jp/img/s_e/13465/1346309IMG1.jpg",
            title: "this is menu",
            text: "description",
            actions: [
                {
                    type: "postback",
                    label: "Buy",
                    data: "action=buy&itemid=222"
                },
                {
                    type: "postback",
                    label: "Add to cart",
                    data: "action=add&itemid=222"
                },
                {
                    type: "uri",
                    label: "View detail",
                    uri: "http://www.enjoytokyo.jp/search/event/area-2/today/"
                }
            ]
          }
      ]
  }
}
        #{
          #type: 'text',
          #text: event.message['text']
        #}
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end
