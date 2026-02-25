require 'telegram/bot'

TOKEN = '7858846953:AAEyIXAQN3kRpJYdECWL4yD4nso7zIB1BL4'

TARGET_USERS = {}

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    if message.is_a?(Telegram::Bot::Types::Message) && 
       (message.chat.type == 'group' || message.chat.type == 'supergroup')

      case message.text
      when /^\/setclown @(\w+)/
        username = $1
        TARGET_USERS[message.chat.id] = { username: username, id: nil }
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Теперь клоунюсика на сообщения @#{username}"
        )

      when '/stopclown'
        TARGET_USERS.delete(message.chat.id)
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Реакции отключены"
        )

      else
        if TARGET_USERS[message.chat.id]
          target = TARGET_USERS[message.chat.id]
          if message.from.username == target[:username]
            target[:id] = message.from.id unless target[:id]
            begin
              bot.api.set_message_reaction(
                chat_id: message.chat.id,
                message_id: message.message_id,
                reaction: [
                  { type: 'emoji', emoji: '🤡' }, 
                ]
              )
            rescue Telegram::Bot::Exceptions::ResponseError => e
              puts "Ошибка при установке реакций: #{e.message}"
            end
          end
        end
      end
    end
  end
end