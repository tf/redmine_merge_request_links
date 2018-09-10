require 'redmine'

Redmine::Plugin.register :redmine_merge_request_links do
  name 'Redmine Merge Request Links'
  author 'Codevise Solutions'
  description 'Display links to Gitlab merge requests and GitHub pull requests'
  version '0.1.0'
  url 'http://codevise.de'
  author_url 'mailto:info@codevise.de'

  requires_redmine version_or_higher: '3.0'
end

require 'redmine_merge_request_links'
