module RedmineMergeRequestLinks
  module ProjectSettingsTabs
    def self.apply
      ProjectsController.send :helper, RedmineMergeRequestLinks::ProjectSettingsTabs
    end

    def project_settings_tabs
      tabs = super
      if User.current.allowed_to?(:create_projectbased_tokens, @project)
        tabs.push({
                      name: 'Merge Request Tokens',
                      partial: 'merge_request_links/settings',
                      label: :label_merge_request_tokens
                  })
      end
    end
    tabs
  end
end