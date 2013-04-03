# == Schema Information
#
# Table name: event_images
#
#  id                 :integer          not null, primary key
#  caption            :text
#  event_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  user_id            :integer
#

require 'spec_helper'

describe EventImage do
  pending "add some examples to (or delete) #{__FILE__}"
end
