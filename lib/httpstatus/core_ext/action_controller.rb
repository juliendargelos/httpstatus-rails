ActionController::Base.class_eval do
  DEFAULT_STATUS_LAYOUT = 'application'

  class << self
    def status_format?(format)
      (status_formats[:only].include?(format) || status_formats[:only].empty?) && !status_formats[:except].include?(format)
    end

    def status_formats(only: nil, except: nil)
      @status_formats = { only: [], except: [] } unless @status_formats.is_a? Hash

      only = only.to_sym if only.is_a? String
      only = [only] if only.is_a? Symbol

      except = only.to_sym if only.is_a? String
      except = [only] if only.is_a? Symbol

      if only.is_a? Array
        @status_formats[:only] = (@status_formats[:only] + only).uniq
      end

      if except.is_a? Array
        @status_formats[:except] = (@status_formats[:except] + except).uniq
        @status_formats[:only] -= except
      end

      @status_formats
    end
    alias_method :status_format, :status_formats

    def status_layout(*name)
      @status_layout = name.first if name.any?
      @status_layout == false ? nil : (@status_layout || DEFAULT_STATUS_LAYOUT)
    end
  end

  protected

  def status_format?(format)
    lookup_context.exists?('http/status', [], false, [], formats: [format]) && self.class.status_format?(format)
  end

  def render_status(status, format: nil, layout: nil)
    format = (format.present? ? format : request.format).to_sym
    format = self.class.status_formats[:only].first || :html unless status_format? format
    layout = layout.nil? ? self.class.status_layout : layout
    layout = false unless lookup_context.exists? layout, [], false, formats: [format]
    layout = "layouts/#{layout}" unless layout == false

    @status = Httpstatus::Status.new status
    render 'http/status', formats: [format], layout: layout, status: @status.key
  end

  class << self
    def status_action(*status)
      status.each do |_status|
        unless instance_methods.include? _status
          define_method _status do |*_, format: nil, layout: nil|
            render_status _status, format: format, layout: layout
          end
        end
      end
    end

    def handles_error_status
      status_action :internal_server_error
      skip_before_action :verify_authenticity_token, only: :internal_server_error, if: -> { request.format.js? }
      rescue_from Exception, with: :internal_server_error
    end

    def handles_not_found_status
      status_action :not_found
      skip_before_action :verify_authenticity_token, only: :not_found, if: -> { request.format.js? }
      rescue_from *[
        ActiveRecord::RecordNotFound,
        ActionController::RoutingError,
        ActionController::UnknownFormat,
        ::AbstractController::ActionNotFound
      ], with: :not_found
    end
  end
end
