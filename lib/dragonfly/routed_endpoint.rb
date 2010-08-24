module Dragonfly
  class RoutedEndpoint
    
    include Endpoint

    class NoRoutingParams < RuntimeError; end

    def initialize(app, &block)
      @app = app
      @block = block
    end

    def call(env)
      job = @block.call(routing_params(env), @app)
      response_for_job(job, env)
    rescue Job::NoSHAGiven => e
      [400, {"Content-Type" => 'text/plain'}, ["You need to give a SHA parameter"]]
    rescue Job::IncorrectSHA => e
      [400, {"Content-Type" => 'text/plain'}, ["The SHA parameter you gave (#{e}) is incorrect"]]
    end

    private
    
    def routing_params(env)
      env['rack.routing_args'] ||
        env['action_dispatch.request.path_parameters'] ||
        env['router.params'] ||
        env['usher.params'] ||
        env['dragonfly.params'] ||
        raise(NoRoutingParams, "couldn't find any routing parameters in env #{env.inspect}")
    end

  end
end
