require 'redmine_merge_request_links/hooks'

module RedmineMergeRequestLinks
  mattr_accessor :providers
  self.providers = [
      :gitea,
      :github,
      :gitlab
  ]

  github_token = ENV['REDMINE_MERGE_REQUEST_LINKS_GITHUB_WEBHOOK_TOKEN']
  gitlab_token = ENV['REDMINE_MERGE_REQUEST_LINKS_GITLAB_WEBHOOK_TOKEN']
  gitea_token  = ENV['REDMINE_MERGE_REQUEST_LINKS_GITEA_WEBHOOK_TOKEN']

  mattr_accessor :event_handlers
  self.event_handlers = [
    RedmineMergeRequestLinks::EventHandlers::Gitea.new(token: gitea_token),
    RedmineMergeRequestLinks::EventHandlers::Github.new(token: github_token),
    RedmineMergeRequestLinks::EventHandlers::Gitlab.new(token: gitlab_token)
  ]
end
