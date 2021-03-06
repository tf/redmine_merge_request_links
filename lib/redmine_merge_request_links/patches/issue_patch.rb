module RedmineMergeRequestLinks
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          has_and_belongs_to_many :merge_requests
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineMergeRequestLinks::Patches::IssuePatch)
  Issue.send(:include, RedmineMergeRequestLinks::Patches::IssuePatch)
end
