require 'omniauth/core'

module OmniAuth
  class Builder < ::Rack::Builder
    def initialize(app, &block)
      if rack14?
        super
      else
        @app = app
        super(&block)
      end
    end

    def rack14?
      Rack.release.split('.')[1].to_i >= 4
    end

    def on_failure(&block)
      OmniAuth.config.on_failure = block
    end

    def configure(&block)
      OmniAuth.configure(&block)
    end

    def provider(klass, *args, &block)
      if klass.is_a?(Class)
        middleware = klass
      else
        middleware = OmniAuth::Strategies.const_get("#{OmniAuth::Utils.camelize(klass.to_s)}")
      end

      use middleware, *args, &block
    end

    def call(env)
      @ins << @app unless rack14? || @ins.include?(@app)
      to_app.call(env)
    end
  end
end
