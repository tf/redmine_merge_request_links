class MergeRequest < ActiveRecord::Base
  has_and_belongs_to_many :issues

  attr_accessor :description

  # Gitlab does not pass the author name, only the name of the user
  # performing the current action. Since (except for merge requests
  # that were created before the plugin was installed) the user
  # triggering the first webhook event is the author, we want to
  # update the author name only once.
  attr_readonly :author_name

  after_save :scan_description_for_issue_ids

  def self.find_all_by_issue(issue)
    includes(:issues).where(issues: { id: issue.id })
  end

  private

  ISSUE_ID_REGEXP = /(?:[^a-z]|\A)#(\d+)/

  def scan_description_for_issue_ids
    self.issues = (description || '').scan(ISSUE_ID_REGEXP).map do |match|
      Issue.find_by_id(match[0])
    end.compact
  end
end
