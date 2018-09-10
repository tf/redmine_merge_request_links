require File.expand_path('../../test_helper', __FILE__)

class MergeRequestsControllerTest < ActionController::TestCase
  TOKEN = 'secret'
  MERGE_REQUEST_URL = 'https://gitlab.example.com/project/merge_requests/1'

  fixtures :issues

  def setup
    RedmineMergeRequestLinks.event_handlers = [
      RedmineMergeRequestLinks::EventHandlers::Github.new(token: TOKEN),
      RedmineMergeRequestLinks::EventHandlers::Gitlab.new(token: TOKEN)
    ]
  end

  def test_gitlab_merge_request_event_creates_merge_request
    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event, object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened'
         })

    assert_response :success

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
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event, object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'New title',
           state: 'merged'
         })

    assert_response :success

    merge_request.reload
    assert_equal 'merged', merge_request.state
    assert_equal 'New title', merge_request.title
  end

  def test_responds_with_forbidden_if_gitlab_token_does_not_match
    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'wrong'
    post(:event, object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened'
         })

    assert_response :forbidden
  end

  def test_associates_issues_mentioned_in_gitlab_mr_description
    issue = Issue.first

    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event, object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened',
           description: "This mentions ##{issue.id}"
         })

    merge_request = MergeRequest.where(url: MERGE_REQUEST_URL).first
    assert_includes(merge_request.issues, issue)
  end

  def test_github_pull_request_event_creates_merge_request
    url = 'https://github.com/Codertocat/Hello-World/pull/1'

    payload = {
      pull_request: {
        html_url: url,
        title: 'Some pull request',
        state: 'closed'
      }
    }
    request.headers['X-GitHub-Event'] = 'pull_request'
    request.headers['X-Hub-Signature'] = hub_signature(payload)
    post(:event, payload)

    assert_response :success

    merge_request = MergeRequest.where(url: url).first
    assert merge_request.present?
    assert_equal 'closed', merge_request.state
    assert_equal 'Some pull request', merge_request.title
  end

  def test_responds_with_forbidden_if_github_signature_is_incorrect
    request.headers['X-GitHub-Event'] = 'pull_request'
    request.headers['X-Hub-Signature'] = 'wrong'
    post(:event, pull_request: {
           html_url: 'https://github.com/Codertocat/Hello-World/pull/1',
           title: 'Some pull request',
           state: 'closed'
         })

    assert_response :forbidden
  end

  def test_associates_issues_mentioned_in_github_pr_description
    url = 'https://github.com/Codertocat/Hello-World/pull/1'
    issue = Issue.last

    payload = {
      pull_request: {
        html_url: url,
        title: 'Some pull request',
        state: 'closed',
        description: "Talks about ##{issue.id}"
      }
    }
    request.headers['X-GitHub-Event'] = 'pull_request'
    request.headers['X-Hub-Signature'] = hub_signature(payload)
    post(:event, payload)

    merge_request = MergeRequest.where(url: url).first
    assert_includes(merge_request.issues, issue)
  end

  def test_responds_with_bad_request_if_unknown_event
    post(:event)

    assert_response :bad_request
  end

  private

  def hub_signature(payload)
    'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
                                      TOKEN,
                                      payload.to_query)
  end
end
