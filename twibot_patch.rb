#we really want this bot to soldier on, even when Twitter throws us a 'Bad Gateway' error etc.
module Twibot
  class Bot
    def poll
      max = max_interval
      step = interval_step
      interval = min_interval

      while !@abort do
        message_count = 0
        begin
        message_count += receive_messages || 0
        message_count += receive_replies || 0
        message_count += receive_tweets || 0

        interval = message_count > 0 ? min_interval : [interval + step, max].min
        rescue => e
          log.error e.message
        end
        log.debug "Sleeping for #{interval}s"
        sleep interval
      end
    end
  end
end