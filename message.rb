class Message

  attr_accessor :id

  def self.exists?(message)
    m = new(message)
    m.exists?
  end

  def initialize(message)
    @id = message.id
    @exists = storage.has_key?(id)
    save unless exists?
  end

  def exists?
    @exists
  end

  def save
    storage[id] = Time.now
  end

  private

  def storage
    @storage ||= Moneta::DataMapper.new(:setup => "sqlite3:///#{File.join(Dir.pwd,'data','messages.db')}")
  end

end