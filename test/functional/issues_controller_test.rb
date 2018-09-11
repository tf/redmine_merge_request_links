require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  def setup
    @request.session[:user_id] = 1
  end

  def test_renders_issue_merge_requests
    issue = Issue.find(1)
    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    get(:show, id: issue.id)

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}"
  end
end
