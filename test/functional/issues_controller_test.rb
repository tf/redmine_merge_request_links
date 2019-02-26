require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  include RedmineMergeRequestLinks::RequestTestHelperCompat

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
    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(:show, id: issue.id)

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}"
  end

  def test_requires_merge_request_links_mobile_to_be_enabled
    issue.project.enabled_module_names -= ['merge_request_links']
    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(:show, id: issue.id)

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}", count: 0
  end

  def test_requires_permission
    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    sign_in(user_without_permission)
    get(:show, id: issue.id)

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}", count: 0
  end

  private

  def sign_in(user)
    @request.session[:user_id] = user.id
  end

  def user_with_permission
    user_without_permission.tap do |user|
      member = Member.where(user: user, project_id: issue.project_id).first

      role = member.roles.first
      role.permissions << :view_associated_merge_requests
      role.save!
    end
  end

  def user_without_permission
    User.find(3)
  end

  def issue
    @issue ||= Issue.find(1).tap do |issue|
      issue.project.enabled_module_names += ['merge_request_links']
    end
  end
end
