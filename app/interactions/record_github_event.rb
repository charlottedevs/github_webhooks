require "active_support/inflector"

class RecordGitHubEvent
  include Interactor

  def call
    return unless merged_pull_request?
    return if user && post_event_to_api
    context.fail!(errors: context.errors)
  end

  private

  def merged_pull_request?
    payload.dig("pull_request", "merged").to_s == "true"
  end

  def user
    context.user ||= fetch_user && context.user
  end

  def fetch_user
    context.user_params = {
      search: "github_handle", value: event_sender
    }

    ApiToolbox::FetchUser.call(context)
    context.success?
  end

  def event_sender
    payload["sender"]["login"]
  end

  def post_event_to_api
    params = {
      event_category: event_category,
      user_id:        user["id"]
    }

    context.response = ApiToolbox::PostEventToAPI.call(params).response
    context.success?
  end

  def event_category
    "#{event_type.singularize}_#{event_action}"
    # => "issue_created", "pull_request_opened", etc.
  end

  def request
    context.request
  end

  def event_type
    request.env["HTTP_X_GITHUB_EVENT"]
  end

  def event_action
    payload["action"]
  end

  def payload
    return @payload if @payload

    request.body.rewind
    payload_body = request.body.read
    @payload = JSON.parse(payload_body)
  end
end
