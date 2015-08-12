require 'dotenv'
require 'slack-notifier'

class GardenSlacker
  def initialize
    Dotenv.load
    @webhook_url = ENV('SLACK_WEBHOOK_URL') or raise "Holy fucking shit! No SLACK_WEBHOOK_URL set! You need to create your .env file."
    @notifier = Slack::Notifier.new webhook_url
    @notifier.username = 'The Garden'
    notifier.ping "Garden starting up...."
  end

  def send_message(message)
    @notifier.ping message 
  end
  
  def slack_notification_of_empty_reservoir(reservoir_value)
    send_message "Please fill my reservoir! My current sensor value is #{reservoir_value}."
  end
end

