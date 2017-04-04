require_relative "fetch_user_from_github_handle"
require_relative "post_event_to_api"

class RecordGitHubEvent
  include Interactor

  def call
    return if user && post_event_to_api
    context.fail!(errors: context.errors)
  end

  private

  def user
    context.user || fetch_user && context.user
  end

  def fetch_user
    context.github_handle ||= event_sender
    FetchUserFromGitHubHandle.call(context)
    context.success?
  end

  def event_sender
    payload["sender"]["login"]
  end

  def post_event_to_api
    context.event ||= event_category
    PostEventToAPI.call(context)
    context.success?
  end

  def event_category
    "#{event_type.pluralize}_#{event_action}"
    # => "issues_created", "pull_requests_opened", etc.
  end

  def request
    context.request
  end

  def event_type
    request.headers["X-GitHub-Event"]
  end

  def event_action
    payload["action"]
  end

  def payload
    @payload ||= JSON.parse(request.body)
  end
end
