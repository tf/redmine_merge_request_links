require 'redmine_merge_request_links/hooks/view_issues_hook'

module RedmineMergeRequestLinks
  github_token = ENV['REDMINE_MERGE_REQUEST_LINKS_GITHUB_WEBHOOK_TOKEN']
  gitlab_token = ENV['REDMINE_MERGE_REQUEST_LINKS_GITLAB_WEBHOOK_TOKEN']

  mattr_accessor :event_handlers
  self.event_handlers = [
    RedmineMergeRequestLinks::EventHandlers::Github.new(token: github_token),
    RedmineMergeRequestLinks::EventHandlers::Gitlab.new(token: gitlab_token)
  ]
end
