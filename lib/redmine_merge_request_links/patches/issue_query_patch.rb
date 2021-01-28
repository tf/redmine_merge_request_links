module RedmineMergeRequestLinks
  module Patches
    module IssueQueryPatch
      def self.included(base)

        def initialize_available_filters_with_merge_requests
          initialize_available_filters_without_merge_requests
          add_available_filter("merge_request",
            :type => :list_optional, :values => ['open', 'merged', 'closed']
          )
        end

        def issues_with_merge_requests(options={})
          if has_column?(:merge_requests)
            (options[:include] ||= []) << :merge_requests
          end
          issues_without_merge_requests(options)
        end

        def sql_for_merge_request_field(field, operator, value, options={})
          case operator
          when "*", "!*"
            "#{(operator == "*" ? "EXISTS" : "NOT EXISTS")} (SELECT 1 FROM issues_merge_requests WHERE issues_merge_requests.issue_id = issues.id)"
          when "=", "!"
            "EXISTS (SELECT 1 FROM issues_merge_requests JOIN merge_requests ON merge_requests.id = issues_merge_requests.merge_request_id" + 
              " WHERE issues_merge_requests.issue_id = issues.id" + 
              " AND merge_requests.state #{(operator == "=" ? "IN" : "NOT IN")} (" + value.collect{|val| "'#{self.class.connection.quote_string(val)}'"}.join(",") + "))"
          end
        end

        base.class_eval do
          unloadable
          alias_method :initialize_available_filters_without_merge_requests, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_merge_requests
          self.available_columns << QueryColumn.new(:merge_requests)
          alias_method :issues_without_merge_requests, :issues
          alias_method :issues, :issues_with_merge_requests
        end

      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineMergeRequestLinks::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineMergeRequestLinks::Patches::IssueQueryPatch)
end
