require 'multi_json'

require 'rapns/version'
require 'rapns/deprecation'
require 'rapns/deprecatable'
require 'rapns/logger'
require 'rapns/multi_json_helper'
require 'rapns/configuration'
module Rapns

  def self.init_orm
    if Rapns.config.store == :active_record
      require 'rapns/orm/active_record'
    elsif Rapns.config.store == :mongoid
      require 'rapns/orm/mongoid'
    else
      raise "Unsupported store: #{Rapns.config.store.to_s}"
    end

    require 'rapns/notification'
    require 'rapns/app'

    require 'rapns/apns/binary_notification_validator'
    require 'rapns/apns/device_token_format_validator'
    require 'rapns/apns/notification'
    require 'rapns/apns/feedback'
    require 'rapns/apns/app'
    
    require 'rapns/gcm/expiry_collapse_key_mutual_inclusion_validator'
    require 'rapns/gcm/notification'
    require 'rapns/gcm/app'
    
    require 'rapns/wpns/notification'
    require 'rapns/wpns/app'
    
    require 'rapns/adm/data_validator'
    require 'rapns/adm/notification'
    require 'rapns/adm/app'
  end

  def self.attr_accessible_available?
    require 'rails'
    ::Rails::VERSION::STRING < '4'
  end

  require 'rapns/railtie' if defined?(Rails)
end

require 'rapns/reflection'
require 'rapns/embed'
require 'rapns/push'
require 'rapns/apns_feedback'
require 'rapns/upgraded'
require 'rapns/notifier'
require 'rapns/payload_data_size_validator'
require 'rapns/registration_ids_count_validator'

module Rapns
  def self.jruby?
    defined? JRUBY_VERSION
  end

  def self.require_for_daemon
    require 'rapns/daemon'
  end

  def self.logger
    @logger ||= Logger.new(:foreground => Rapns.config.foreground)
  end

  def self.logger=(logger)
    @logger = logger
  end
end
