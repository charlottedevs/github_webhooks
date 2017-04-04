Bundler.require(:default)
require_relative "interactions/record_github_event"

module GitHubWebhooks
  class Server < Sinatra::Base
    get "/events" do
      result = RecordGitHubEvent.call(request: request)
      if result.success?
        status 201
        result.event
      else
        status 500
        result.errors
      end
    end
  end
end
