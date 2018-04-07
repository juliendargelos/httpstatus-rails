module Httpstatus
  class Status
    DEFAULT = :internal_server_error

    def initialize key = nil
      self.key = key
    end

    def key
      @key || DEFAULT
    end

    def key= v
      @key = v.is_a?(Symbol) ? v : (v.is_a?(String) ? v.to_sym : nil)
      default! unless valid?
    end

    def code
      i18n :code
    end

    def title
      i18n :title
    end

    def message
      i18n :message
    end

    def error?
      (400..599) === code
    end

    def default!
      @key = nil
    end

    def default?
      status.key == DEFAULT
    end

    def to_hash *options
      { status: code, title: title, message: message }
    end
    alias_method :to_h, :to_hash
    alias_method :as_json, :to_hash

    def to_s
      "#{code} #{title}\n#{message}"
    end

    def to_json(*options)
      to_h.to_json(*options).html_safe
    end

    def to_yaml(*options)
      to_h.to_yaml(*options).html_safe
    end

    def to_xml(*options)
      to_h.to_xml(*options).html_safe
    end

    protected

    def valid?
      code.is_a?(Fixnum) && title.is_a?(String) && message.is_a?(String)
    end

    def i18n(property)
      I18n.t "http_status.#{key}.#{property}"
    end
  end
end
