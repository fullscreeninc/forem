module Forem
  class Group < ActiveRecord::Base
    include Tenacity
    
    validates :name, :presence => true

    t_has_many :memberships
    t_has_many :members, :through => :memberships, :class_name => Forem.user_class.to_s

    attr_accessible :name

    def to_s
      name
    end
  end
end
