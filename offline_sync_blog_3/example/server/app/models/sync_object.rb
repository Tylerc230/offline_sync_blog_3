class SyncObject < ActiveRecord::Base
  acts_as_citier
  scope :modified_since, lambda { |time| where("updated_at > ?", time)}
end
