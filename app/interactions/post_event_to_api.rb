class PostEventToAPI
  include Interactor

  def call
    res = HTTParty.post(api_url, body: event_params)
    return unless res.success?
    context.fail!(errors: res.errors)
  end

  private

  def api_url
    context.api_url ||= ENV["API_URL"] || raise("no api url defined")
  end

  def event_params
    {
      event_category: context.event_category,
      user_id:        context.user_id
    }
  end

  def user_id
    Hash(context.user)["id"]
  end
end
