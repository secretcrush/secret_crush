class Crush
  attr_accessor :sender, :target

  ONE_WEEK = 604800 #seconds
  TWITTER_NAME = /@([0-9a-z_]+)/i
  
  MESSAGES = {
    :confirmation   => "Your crush has been noted.",  # private message to sender to confirm setup (no match)
    :notification   => "Someone has a crush on you!", # public tweet to target
    :match          => "@%s has a crush on you.", # private message to both when matched
    :overlimit      => "You can only set up one crush per week. No matches yet.", # attempt to send more than one crush per week
  }

  def self.create( message )
    sender = message.sender.screen_name
    target = message.to_s.match(TWITTER_NAME)[1] rescue nil
    crush = Crush.new(sender,target)
    crush.save_and_log_matches
    return crush
  end

  def initialize( sender, target )
    @sender = sender
    @target = target
    @exists = storage.has_key?(sender)
  end

  def matches?
    storage.has_key?(target) && storage[target] == sender
  end

  def exists?
    @exists
  end
  
  def save_and_log_matches
    return if exists?
    save
    log_matches
  end

  def save
    storage.store(sender, target, :expires_in => ONE_WEEK)
  end

  def d( recipient, text )
    "d #{recipient} #{text}"
  end
  
  def a( recipient, text )
    "@#{recipient} #{text}"
  end
  
  def notifications
    if matches?
      match_notifications
    else
      mismatch_notifications
    end  
  end
  
  def log_matches
    return unless matches?
    logger.info "@#{sender} found @#{target}."
  end

  private
  
  def mismatch_notifications
    if exists?
      [ d( sender, MESSAGES[:overlimit] ) ]
    else
      [
        d( sender, MESSAGES[:confirmation] ),
        a( target, MESSAGES[:notification] )
      ]
    end
  end

  def match_notifications
    [
      d( sender, MESSAGES[:match] % target ),
      d( target, MESSAGES[:match] % sender )
    ]
  end

  def storage
    @storage ||= Moneta::DataMapper.new(:setup => "sqlite3:///#{File.join(Dir.pwd,'data','crushes.db')}")
  end
  
  def logger
    @logger ||= Logger.new(File.join(File.dirname(__FILE__),'log',"matches.log"))
  end

end