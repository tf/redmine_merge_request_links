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
    post(:event,
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened',
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
         })

    assert_response :success

    merge_request = MergeRequest.where(url: MERGE_REQUEST_URL).first
    assert merge_request.present?
    assert_equal 'opened', merge_request.state
    assert_equal 'Some merge request', merge_request.title
    assert_equal 'group/project!23', merge_request.display_id
    assert_equal '@john', merge_request.author_name
    assert_equal 'gitlab', merge_request.provider
  end

  def test_gitlab_merge_request_event_updates_merge_request
    merge_request = MergeRequest.create!(
      url: MERGE_REQUEST_URL,
      title: 'Old title',
      state: 'opened'
    )

    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event,
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'New title',
           state: 'merged',
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
         })

    assert_response :success

    merge_request.reload
    assert_equal 'merged', merge_request.state
    assert_equal 'New title', merge_request.title
  end

  def test_does_not_update_author_field
    # Gitlab does not pass the author name, only the name of the user
    # performing the current action. Since (except for merge requests
    # that were created before the plugin was installed) the user
    # triggering the first webhook event is the author, we want to
    # update the author name only once.

    merge_request = MergeRequest.create!(
      url: MERGE_REQUEST_URL,
      title: 'Title',
      state: 'opened',
      author_name: '@jack'
    )

    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event,
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Title',
           state: 'merged',
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
         })

    assert_response :success

    merge_request.reload
    assert_equal '@jack', merge_request.author_name
  end

  def test_gitlab_system_hooks
    request.headers['X-Gitlab-Event'] = 'System Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event,
         event_type: 'merge_request',
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened',
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
         })

    assert_response :success

    merge_request = MergeRequest.where(url: MERGE_REQUEST_URL).first
    assert merge_request.present?
    assert_equal 'opened', merge_request.state
    assert_equal 'Some merge request', merge_request.title
    assert_equal 'group/project!23', merge_request.display_id
    assert_equal '@john', merge_request.author_name
  end

  def test_responds_with_forbidden_if_gitlab_token_does_not_match
    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'wrong'
    post(:event,
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened',
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
         })

    assert_response :forbidden
  end

  def test_associates_issues_mentioned_in_gitlab_mr_description
    issue = Issue.first

    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event,
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: 'Some merge request',
           state: 'opened',
           description: "This mentions ##{issue.id}",
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
         })

    merge_request = MergeRequest.where(url: MERGE_REQUEST_URL).first
    assert_includes(merge_request.issues, issue)
  end

  def test_associates_issues_mentioned_in_gitlab_mr_title
    issue = Issue.first

    request.headers['X-Gitlab-Event'] = 'Merge Request Hook'
    request.headers['X-Gitlab-Token'] = 'secret'
    post(:event,
         user: {
           username: 'john'
         },
         object_attributes: {
           url: MERGE_REQUEST_URL,
           title: "Some merge request (##{issue.id})",
           state: 'opened',
           description: 'Some text',
           iid: 23,
           target: {
             path_with_namespace: 'group/project'
           }
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
        state: 'closed',
        number: 12,
        user: {
          login: 'someuser'
        },
        base: {
          repo: {
            full_name: 'group/project'
          }
        }
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
    assert_equal 'group/project#12', merge_request.display_id
    assert_equal '@someuser', merge_request.author_name
    assert_equal 'github', merge_request.provider
  end

  def test_responds_with_forbidden_if_github_signature_is_incorrect
    request.headers['X-GitHub-Event'] = 'pull_request'
    request.headers['X-Hub-Signature'] = 'wrong'
    post(:event, pull_request: {
           html_url: 'https://github.com/Codertocat/Hello-World/pull/1',
           title: 'Some pull request',
           state: 'closed',
           number: 12,
           user: {
             login: 'someuser'
           },
           base: {
             repo: {
               full_name: 'group/project'
             }
           }
         })

    assert_response :forbidden
  end

  def test_associates_issues_mentioned_in_github_pr_body
    url = 'https://github.com/Codertocat/Hello-World/pull/1'
    issue = Issue.last

    payload = {
      pull_request: {
        html_url: url,
        title: 'Some pull request',
        state: 'closed',
        body: "Talks about ##{issue.id}",
        number: 12,
        user: {
          login: 'someuser'
        },
        base: {
          repo: {
            full_name: 'group/project'
          }
        }
      }
    }
    request.headers['X-GitHub-Event'] = 'pull_request'
    request.headers['X-Hub-Signature'] = hub_signature(payload)
    post(:event, payload)

    merge_request = MergeRequest.where(url: url).first
    assert_includes(merge_request.issues, issue)
  end

  def test_associates_issues_mentioned_in_github_pr_title
    url = 'https://github.com/Codertocat/Hello-World/pull/1'
    issue = Issue.last

    payload = {
      pull_request: {
        html_url: url,
        title: "Some pull request (##{issue.id})",
        state: 'closed',
        body: 'Some text',
        number: 12,
        user: {
          login: 'someuser'
        },
        base: {
          repo: {
            full_name: 'group/project'
          }
        }
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
