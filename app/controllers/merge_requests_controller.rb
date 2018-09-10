class MergeRequestsController < ApplicationController
  def event
    event_handler = find_event_handler
    return head :bad_request unless event_handler

    attributes = event_handler.parse_params(params)

    merge_request =
      MergeRequest.find_or_initialize_by(url: attributes[:url])
    merge_request.update!(attributes)

    head :success
  end

  private

  def find_event_handler
    [
      RedmineMergeRequestLinks::EventHandlers::Github.new,
      RedmineMergeRequestLinks::EventHandlers::Gitlab.new
    ].detect do |event_handler|
      event_handler.matches?(request)
    end
  end
end
