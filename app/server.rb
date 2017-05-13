Bundler.require(:default)
require_relative "interactions/record_github_event"

if ENV["RACK_ENV"] != "production"
  require "dotenv"
  Dotenv.load
end

module GitHubWebhooks
  class Server < Sinatra::Base
    post "/events" do
      request.body.rewind
      verify_signature(request.dup)
      result = RecordGitHubEvent.call(request: request)
      if result.success?
        status 201
        result.event
      else
        status 500
        result.errors
      end
    end

    get "/" do
      "ok"
    end

    private

    def verify_signature(request)
      payload_body = request.body.read
      hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), ENV["SECRET_TOKEN"], payload_body)
      signature = "sha1=#{hmac}"
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env["HTTP_X_HUB_SIGNATURE"])
    end
  end
end
