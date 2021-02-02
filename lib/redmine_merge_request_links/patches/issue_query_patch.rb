module RedmineMergeRequestLinks
  module Patches
    module IssueQueryPatch
      def self.included(base)

        def initialize_available_filters_with_merge_requests
          initialize_available_filters_without_merge_requests
          if User.current.allowed_to?(:view_associated_merge_requests, project, :global => true)
            add_available_filter("merge_request",
              :type => :list_optional, :values => ['open', 'merged', 'closed']
            )
          end
        end

        def available_columns_with_merge_requests
          return @available_columns if @available_columns
          @available_columns = available_columns_without_merge_requests
          if User.current.allowed_to?(:view_associated_merge_requests, project, :global => true)
            @available_columns << QueryColumn.new(:merge_requests)
          end
          @available_columns
        end

        def issues_with_merge_requests(options={})
          if has_column?(:merge_requests)
            (options[:include] ||= []) << :merge_requests
          end
          issues_without_merge_requests(options)
        end

        def sql_for_merge_request_field(field, operator, value, options={})
          issues_merge_requests = Issue.reflections["merge_requests"].join_table
          case operator
          when "*", "!*"
            "#{(operator == "*" ? "EXISTS" : "NOT EXISTS")} (SELECT 1 FROM #{issues_merge_requests}" +
              " WHERE #{issues_merge_requests}.issue_id = #{Issue.table_name}.id" +
              ") AND " + Project.allowed_to_condition(User.current, :view_associated_merge_requests)
          when "=", "!"
            "EXISTS (SELECT 1 FROM #{issues_merge_requests}" +
              " JOIN #{MergeRequest.table_name} ON #{MergeRequest.table_name}.id = #{issues_merge_requests}.merge_request_id" +
              " WHERE #{issues_merge_requests}.issue_id = #{Issue.table_name}.id" +
              " AND #{MergeRequest.table_name}.state #{(operator == "=" ? "IN" : "NOT IN")} (" + value.collect{|val| "'#{self.class.connection.quote_string(val)}'"}.join(",") + ")" +
              ") AND " + Project.allowed_to_condition(User.current, :view_associated_merge_requests)
          end
        end

        base.class_eval do
          unloadable
          alias_method :initialize_available_filters_without_merge_requests, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_merge_requests
          alias_method :available_columns_without_merge_requests, :available_columns
          alias_method :available_columns, :available_columns_with_merge_requests
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
