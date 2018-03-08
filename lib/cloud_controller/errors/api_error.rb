module CloudController
  module Errors
    class ApiError < StandardError
      attr_accessor :args
      attr_accessor :details

      def self.new_from_details(name, *args)
        details = Details.new(name)
        new(details, args)
      end

      def self.setup_i18n(load_path, default_locale)
        I18n.enforce_available_locales = false
        I18n.load_path.concat(load_path).uniq!
        I18n.default_locale = default_locale
        I18n.fallbacks[default_locale.to_sym] = [default_locale.to_sym, :en_US, :en]
        I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
        I18n.backend.reload!
      end

      def initialize(details=nil, args=nil)
        @details = details
        @args = args
      end

      def message
        return unless args || details

        formatted_args = args.flatten.map do |arg|
          begin
            sprintf(I18n.translate(details.name, raise: true, locale: I18n.locale), arg)
          rescue I18n::MissingTranslationData
            sprintf(details.message_format, arg)
          end
        end

        formatted_args
      end

      def code
        details.try(:code)
      end

      def name
        details.try(:name)
      end

      def response_code
        details.try(:response_code)
      end
    end
  end
end
