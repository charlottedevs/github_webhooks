module GitHubWebHooks
  class FetchUserFromGitHubHandle
    include Interactor


    def call
      res = HTTParty.get(api_url, query: { github_handle: github_handle })
    end

    private

    def github_handle
      context.github_handle
    end

    def api_url
      context.api_url ||= ENV["API_URL"]
    end
  end
end
