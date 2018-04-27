module VCAP::CloudController
  class UaaTimeoutScim
    attr_reader :uaa_core_scim

    def initialize(uaa_core_scim, timeout)
      @uaa_core_scim = uaa_core_scim
      @timeout = timeout
    end

    def get(*args)
      Timeout.timeout @timeout do
        uaa_core_scim.get(*args)
      end
    rescue Timeout::Error
      raise UaaUnavailable.new
    end

    def query(*args)
      Timeout.timeout @timeout do
        uaa_core_scim.query(*args)
      end
    rescue Timeout::Error
      raise UaaUnavailable.new
    end
  end
end
