class User < ActiveRecord::Base
  has_many :authorizations, :dependent => :destroy

  def self.create_from_hash!(hash)
    create(:name     => hash['user_info']['name'],
           :nickname => hash['user_info']['nickname'],
           :email    => hash['user_info']['email'])
  end

  def name
    read_attribute(:name) || nickname || "Anonymous ##{id}"
  end


  def refresh_names(hash)
    return if nickname && email

    update_attributes(:name     => hash['user_info']['name'],
                      :nickname => hash['user_info']['nickname'],
                      :email    => hash['user_info']['email'])
  end


end
