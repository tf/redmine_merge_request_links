require 'redmine_merge_request_links/hooks'

module RedmineMergeRequestLinks
  mattr_accessor :event_handlers
  self.event_handlers = [
    RedmineMergeRequestLinks::EventHandlers::Gitea.new,
    RedmineMergeRequestLinks::EventHandlers::Github.new,
    RedmineMergeRequestLinks::EventHandlers::Gitlab.new
  ]
end
