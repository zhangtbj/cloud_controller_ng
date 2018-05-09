module VCAP::CloudController
  class ProcessTypes
    WEB = 'web'.freeze

    def self.webish?(type)
      return type == WEB || type.match?(/web-deployment/)
    end
  end
end
