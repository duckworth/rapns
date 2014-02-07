require 'mongoid'
require 'autoinc'
require 'active_model'

module Rapns
  class RecordBase
    include Mongoid::Document
    include Mongoid::Timestamps
  end

  self.config.store = :mongoid
end