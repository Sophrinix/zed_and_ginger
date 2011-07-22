require 'ray'

%w[animation drawable matrix rect].each do |file_name|
  require_relative "ray_ext/#{file_name}"
end

include Ray
