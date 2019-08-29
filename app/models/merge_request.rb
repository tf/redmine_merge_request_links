class MergeRequest < ActiveRecord::Base
  has_and_belongs_to_many :issues

  attr_accessor :description

  # Gitlab does not pass the author name, only the name of the user
  # performing the current action. Since (except for merge requests
  # that were created before the plugin was installed) the user
  # triggering the first webhook event is the author, we want to
  # update the author name only once.
  attr_readonly :author_name

  after_save :scan_description_for_issue_ids, :update_mentioned_issues_status

  def self.find_all_by_issue(issue)
    includes(:issues).where(issues: { id: issue.id })
  end

  private

  ISSUE_ID_REGEXP = /(?:[^a-z]|\A)(?:#|REDMINE-)(\d+)/

  def scan_description_for_issue_ids
    self.issues = mentioned_issue_ids.map do |match|
      Issue.find_by_id(match[0])
    end.compact
  end

  def mentioned_issue_ids
    [description, title].flat_map do |value|
      (value || '').scan(ISSUE_ID_REGEXP)
    end.uniq
  end

  def update_mentioned_issues_status
    redmine_user_id = ENV['REDMINE_MERGE_REQUEST_LINKS_GITLAB_REDMINE_USER_ID']
    after_merge_status = ENV['REDMINE_MERGE_REQUEST_LINKS_AFTER_MERGE_STATUS']

    if state != 'merged' || redmine_user_id.blank? || after_merge_status.blank?
      return
    end

    mentioned_issue_ids.map do |match|
      issue = Issue.find_by_id(match[0])
      if issue.present?
        issue.init_journal(User.find(redmine_user_id))
        issue.status = IssueStatus.find_by_name(after_merge_status)
        issue.save!
      end
    end
  end
end
