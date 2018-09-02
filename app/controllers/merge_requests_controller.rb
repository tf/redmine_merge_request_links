class MergeRequestsController < ApplicationController
  def event
    if request.headers['X-Gitlab-Event'] != 'Merge Request Hook'
      return head :bad_request
    end

    attributes = object_params

    merge_request =
      MergeRequest.find_or_initialize_by(url: attributes[:url])
    merge_request.update!(attributes)

    head :success
  end

  private

  def object_params
    params.require(:object_attributes).permit(:state, :url, :title)
  end
end
