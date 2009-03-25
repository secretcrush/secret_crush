class Spinner

  def self.run!
    spinner = new
    spinner.run!
  end

  def run!
    start unless running?
  end
  
  def running?
    !status.match(/Bot is NOT running/)
  end
  
  def pid
    status.match(/Bot is running \((\d+?)\)/)[1].to_i rescue nil
  end

  def status
    run :status
  end
  
  def start
    run :start
  end
  
  def stop
    run :stop
  end
  
  protected
  
  def run(action)
    `ruby #{bot} #{action}`
  end
  
  def bot
    File.join(Dir.pwd,'bot.rb')
  end

end

Spinner.run!