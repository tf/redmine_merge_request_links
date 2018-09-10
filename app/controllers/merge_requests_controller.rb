class MergeRequestsController < ApplicationController
  def event
    unless event_handler.matches?(request)
      return head :bad_request
    end

    attributes = event_handler.parse_params(params)

    merge_request =
      MergeRequest.find_or_initialize_by(url: attributes[:url])
    merge_request.update!(attributes)

    head :success
  end

  private

  def event_handler
    RedmineMergeRequestLinks::EventHandlers::Gitlab.new
  end
end
