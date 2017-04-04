module GitHubWebHooks
  class FetchUserFromGitHubHandle
    include Interactor

    def call
      HTTParty.get(api_url, query: user_params).tap do |res|
        context.fail!(errors: res.body) unless res.success?
        context.user = JSON.parse(res.body)
      end
    end

    private

    def user_params
      { github_handle: github_handle }
    end

    def github_handle
      context.github_handle
    end

    def api_url
      context.api_url ||= ENV["API_URL"] || raise("api url not defined")
    end
  end
end
