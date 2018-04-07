require "httpstatus/rails/railtie"

module Httpstatus
  module Rails
    require __dir__ + '/engine'
    require __dir__ + '/core_ext'
    require __dir__ + '/status'
  end
end
