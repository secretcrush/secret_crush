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
        sleep interval
        rescue Exception => e
          log.error e.message
          sleep max
        end
        log.debug "Sleeping for #{interval}s"
      end
    end
  end
end