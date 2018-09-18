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

  def test_renders_issue_merge_requests
    @request.session[:user_id] = developer_user.id

    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    get(:show, id: issue.id)

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}"
  end

  def test_requires_browse_repository_permission
    @request.session[:user_id] = user_without_browse_repository_permission.id

    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    get(:show, id: issue.id)

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}", count: 0
  end

  private

  def developer_user
    User.find(3)
  end

  def user_without_browse_repository_permission
    developer_user.tap do |user|
      member = Member.where(user: user, project_id: issue.project_id).first

      role = member.roles.first
      role.permissions.delete(:browse_repository)
      role.save!
    end
  end

  def issue
    @issue ||= Issue.find(1)
  end
end
