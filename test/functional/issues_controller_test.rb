require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::ControllerTest

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
    get(
      :show, 
      :params => {
        id: issue.id
      }
    )

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}"
  end

  def test_requires_merge_request_links_module_to_be_enabled
    issue.project.enabled_module_names -= ['merge_request_links']
    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(
      :show, 
      :params => {
        id: issue.id
      }
    )

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}", count: 0
  end

  def test_requires_permission
    merge_request = MergeRequest.create!(title: 'Some merge request')
    merge_request.issues << issue

    sign_in(user_without_permission)
    get(
      :show, 
      :params => {
        id: issue.id
      }
    )

    assert_response :success
    assert_select "#merge-request-#{merge_request.id}", count: 0
  end

  def test_merge_request_filter_any
    merge_request = MergeRequest.create!(title: 'Some merge request', state: 'open')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :set_filter => 1,
        :f => ['merge_request'],
        :op => {
          'merge_request' => '*'
        }
      }
    )

    assert_response :success
    assert_equal [issue], issues_in_list
  end

  def test_merge_request_filter_none
    merge_request = MergeRequest.create!(title: 'Some merge request', state: 'open')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :set_filter => 1,
        :f => ['merge_request'],
        :op => {
          'merge_request' => '!*'
        }
      }
    )

    assert_response :success
    assert_not_includes issues_in_list, issue
  end

  def test_merge_request_filter_open
    merge_request = MergeRequest.create!(title: 'Some merge request', state: 'open')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :set_filter => 1,
        :f => ['merge_request'],
        :op => {
          'merge_request' => '='
        },
        :v => {
          'merge_request' => ['open']
        }
      }
    )

    assert_response :success
    assert_equal [issue], issues_in_list
  end

  def test_merge_request_filter_merged
    merge_request = MergeRequest.create!(title: 'Some merge request', state: 'open')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :set_filter => 1,
        :f => ['merge_request'],
        :op => {
          'merge_request' => '='
        },
        :v => {
          'merge_request' => ['merged']
        }
      }
    )

    assert_response :success
    assert_not_includes issues_in_list, issue
  end

  def test_merge_requests_column
    merge_request = MergeRequest.create!(title: 'Some merge request', state: 'open', display_id: 'mr_id')
    merge_request.issues << issue

    sign_in(user_with_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :set_filter => 1,
        :f => ['merge_request'],
        :op => {
          'merge_request' => '*'
        },
        :c => ['merge_requests']
      }
    )

    assert_response :success
    assert_includes columns_in_issues_list, "Merge requests"
    assert_match "mr_id", css_select("td.merge_requests").first.text
  end

  def test_merge_request_filter_no_permission
    merge_request = MergeRequest.create!(title: 'Some merge request', state: 'open')
    merge_request.issues << issue

    sign_in(user_without_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :set_filter => 1,
        :f => ['merge_request'],
        :op => {
          'merge_request' => '*'
        }
      }
    )

    assert_response :success
    assert issues_in_list.length > 1
  end

  def test_merge_requests_column_no_permission
    sign_in(user_without_permission)
    get(
      :index,
      :params => {
        :project_id => issue.project_id,
        :c => ['merge_requests']
      }
    )

    assert_response :success
    assert_not_includes columns_in_issues_list, "Merge requests"
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
