require File.expand_path('../../test_helper', __FILE__)

class MergeRequestsControllerTest < ActionController::TestCase
  MERGE_REQUEST_URL = 'https://gitlab.example.com/project/merge_requests/1'

  def test_gitlab_merge_request_event_creates_merge_request
    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    post(:event, object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened'
         })

    merge_request = MergeRequest.where(url: MERGE_REQUEST_URL).first
    assert merge_request.present?
    assert_equal 'opened', merge_request.state
    assert_equal 'Some merge request', merge_request.title
  end

  def test_gitlab_merge_request_event_updates_merge_request
    merge_request = MergeRequest.create!(
      url: MERGE_REQUEST_URL,
      title: 'Old title',
      state: 'opened'
    )

    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    post(:event, object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'New title',
           state: 'merged'
         })

    merge_request.reload
    assert_equal 'merged', merge_request.state
    assert_equal 'New title', merge_request.title
  end

  def test_github_pull_request_event_creates_merge_request
    request.headers['X-Github-Event'] = 'pull_request'
    url = 'https://github.com/Codertocat/Hello-World/pull/1'
    post(:event, pull_request: {
           html_url: url,
           title: 'Some pull request',
           state: 'closed'
         })

    merge_request = MergeRequest.where(url: url).first
    assert merge_request.present?
    assert_equal 'closed', merge_request.state
    assert_equal 'Some pull request', merge_request.title
  end

  def test_responds_with_bad_request_if_unknown_event
    post(:event)

    assert_response :bad_request
  end
end
