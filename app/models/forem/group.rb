module Forem
  class Group < ActiveRecord::Base
    validates :name, :presence => true

    has_many :memberships
    has_many :members, :through => :memberships, :class_name => Forem.user_class.to_s

    attr_accessible :name
    
    ADMIN_POSTFIX = ' Admins'

    def to_s
      name
    end
  end
end
