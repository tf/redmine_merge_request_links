class MergeRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :check_if_login_required

  def event
    event_handler = find_event_handler
    return head :bad_request unless event_handler
    return head :forbidden unless event_handler.verify(request)

    attributes = event_handler.parse_params(params)

    merge_request = MergeRequest.find_or_initialize_by(url: attributes[:url])
    merge_request.allowed_projects = event_handler.get_allowed_projects
    merge_request.update!(attributes)

    head :ok
  end

  private

  def find_event_handler
    RedmineMergeRequestLinks.event_handlers.detect do |event_handler|
      event_handler.matches?(request)
    end
  end
end
