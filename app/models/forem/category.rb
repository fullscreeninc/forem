require 'friendly_id'

module Forem
  class Category < ActiveRecord::Base
    extend FriendlyId
    friendly_id :name, :use => :slugged

    has_many :forums
    validates :name, :presence => true
    attr_accessible :name, :forem_public
    
    after_save :create_groups
    
    def forums
      Forem::Forum.where(category_id: id).includes([:category])
    end

    def forums_in_alphabetical
      forums.sort_by { |f| f.title.downcase }
    end

    def moderator?(user)
      user.forem_groups.each do |g|
        return true if self.name + Forem::Group::ADMIN_POSTFIX == g.name
      end

      false
    end

    def forums_in_category
      forums.sort_by do |f|
        if f.sequence != 0
          f.sequence
        else
          f.title.downcase 
        end
      end
    end

    def custom_forums_sort(category_id, sort_order)
      sort_order.each_index do |i|
        forum = forums.find sort_order[i]
        forum.update_attributes(sequence: i+1)
      end
    end

    def to_s
      name
    end
    
    def create_groups
      Forem::Group.create(name: name)
      Forem::Group.create(name: name + Forem::Group::ADMIN_POSTFIX)
    end
  end
end
