class ApplicationController < ActionController::Base
  # handles_not_found_status
  handles_error_status

  def index
    10/0
    render inline: 'hey'
  end
end
