#for Ruby 1.8.4 DM compatibility
require 'rubygems'
require 'pathname'

module Kernel
  def Pathname(args)
    Pathname.new(args)
  end
end