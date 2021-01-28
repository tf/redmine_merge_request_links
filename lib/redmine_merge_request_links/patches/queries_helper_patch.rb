module RedmineMergeRequestLinks
  module Patches
    module QueriesHelperPatch
      def self.included(base)

        def column_value_with_merge_requests(column, item, value)
          if column.name == :merge_requests
            if User.current.allowed_to?(:view_associated_merge_requests, item.project)
              render :partial => 'merge_request_links/column', :locals => { :merge_requests => value }
            else
              ''
            end
          else
            column_value_without_merge_requests(column, item, value)
          end
        end

        base.class_eval do
          unloadable
          alias_method :column_value_without_merge_requests, :column_value
          alias_method :column_value, :column_value_with_merge_requests
        end

      end
    end
  end
end

unless QueriesHelper.included_modules.include?(RedmineMergeRequestLinks::Patches::QueriesHelperPatch)
  QueriesHelper.send(:include, RedmineMergeRequestLinks::Patches::QueriesHelperPatch)
end
