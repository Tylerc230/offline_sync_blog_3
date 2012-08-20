class SyncObject < ActiveRecord::Base
  acts_as_citier
  scope :modified_since, lambda { |time| where("updated_at > ? || updated_at == 0", time)}
end
