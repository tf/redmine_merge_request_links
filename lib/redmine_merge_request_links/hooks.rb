module RedmineMergeRequestLinks
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(_context = {})
      stylesheet_link_tag('redmine_merge_request_links.css',
                          plugin: 'redmine_merge_request_links')
    end

    render_on(:view_issues_show_description_bottom, partial: 'merge_request_links/box')
  end
end
