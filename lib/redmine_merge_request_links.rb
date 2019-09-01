require 'redmine_merge_request_links/hooks'

module RedmineMergeRequestLinks
  mattr_accessor :providers
  self.providers = [
      :gitea,
      :github,
      :gitlab
  ]

  def self.get_event_handlers
    event_handlers = []
    self.providers.each do |provider|
      # Create new instance of EventHandler and add it to array
      if tokens[provider] != nil && tokens[provider].length > 0
        class_name = "RedmineMergeRequestLinks::EventHandlers::#{provider.to_s.upcase_first}"
        event_handlers.push(Object::const_get(class_name).new())
      end
    end
    event_handlers
  end
end
