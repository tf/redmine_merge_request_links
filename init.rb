require 'redmine'

Redmine::Plugin.register :redmine_merge_request_links do
  name 'Redmine Merge Request Links'
  author 'Tim Fischbach'
  description 'Display links to Gitlab merge requests and GitHub pull requests'
  version '2.2.0'
  url 'https://github.com/tf/redmine_merge_request_links'
  author_url 'https://github.com/tf'

  requires_redmine version_or_higher: '3.0'

  project_module :merge_request_links do
    permission :view_associated_merge_requests, {}
    permission :create_projectbased_tokens, {}
  end
end

Rails.configuration.to_prepare do
  RedmineMergeRequestLinks::ProjectSettingsTabs.apply
end

require 'redmine_merge_request_links'
