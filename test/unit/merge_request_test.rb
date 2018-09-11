require File.expand_path('../../test_helper', __FILE__)

class MergeRequestTest < ActiveSupport::TestCase
  fixtures :issues

  def test_updates_issues_from_description
    issue = Issue.last
    merge_request = MergeRequest.create!

    merge_request.update!(description: "see ##{issue.id}")

    assert_includes(merge_request.issues, issue)
  end

  def test_removes_no_longer_mentioned_issues_on_update
    issue = Issue.last
    merge_request = MergeRequest.create!
    merge_request.issues << issue

    merge_request.update!(description: 'Nothing mentioned')

    refute_includes(merge_request.issues, issue)
  end

  def test_ignores_issue_ids_with_project_prefix
    issue = Issue.last
    merge_request = MergeRequest.create!

    merge_request.update!(description: "some/project##{issue.id}")

    assert_empty(merge_request.issues)
  end

  def test_ignores_issue_ids_without_hash
    issue = Issue.last
    merge_request = MergeRequest.create!

    merge_request.update!(description: "see #{issue.id}")

    assert_empty(merge_request.issues)
  end

  def test_issue_id_can_be_wrapped_in_braces
    issue = Issue.last
    merge_request = MergeRequest.create!

    merge_request.update!(description: "(##{issue.id})")

    assert_includes(merge_request.issues, issue)
  end

  def test_find_all_by_issue
    issue = Issue.last
    merge_request = MergeRequest.create!
    merge_request.issues << issue
    other_merge_request = MergeRequest.create!

    assert_includes(MergeRequest.find_all_by_issue(issue), merge_request)
    refute_includes(MergeRequest.find_all_by_issue(issue), other_merge_request)
  end
end
