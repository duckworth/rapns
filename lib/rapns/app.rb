module Rapns
  class App < Rapns::RecordBase
    if Rapns.config.store == :active_record
      self.table_name = 'rapns_apps'
    else
      
      field :name,        type: String
      field :environment, type: String
      field :certificate, type: String
      field :password,    type: String
      field :connections, type: Integer, default: 1
      field :auth_key,    type: String
      
      has_many :feedbacks, :class_name => 'Rapns::Apns::Feedback'
    end
    
    if Rapns.attr_accessible_available?
      attr_accessible :name, :environment, :certificate, :password, :connections, :auth_key, :client_id, :client_secret
    end

    has_many :notifications, :class_name => 'Rapns::Notification', :dependent => :destroy

    validates :name, :presence => true, :uniqueness => { :scope => [:type, :environment] }
    validates_numericality_of :connections, :greater_than => 0, :only_integer => true

    def service_name
      raise NotImplementedError
    end
  end
end
