module RedmineMergeRequestLinks
  module Hooks
    class ViewIssuesHook < Redmine::Hook::ViewListener
      render_on(:view_layouts_base_html_head,
                partial: 'hooks/redmine_merge_request_links/header')

      render_on(:view_issues_show_after_details,
                partial: 'hooks/redmine_merge_request_links/issue')
    end
  end
end
