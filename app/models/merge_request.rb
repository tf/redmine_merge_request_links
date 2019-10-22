class MergeRequest < ActiveRecord::Base
  has_and_belongs_to_many :issues

  attr_accessor :description
  attr_writer :allowed_projects

  # Gitlab does not pass the author name, only the name of the user
  # performing the current action. Since (except for merge requests
  # that were created before the plugin was installed) the user
  # triggering the first webhook event is the author, we want to
  # update the author name only once.
  attr_readonly :author_name

  after_initialize :set_allowed_projects
  after_save :scan_description_for_issue_ids

  def set_allowed_projects
    @allowed_projects = ['*']
  end

  def self.find_all_by_issue(issue)
    includes(:issues).where(issues: { id: issue.id })
  end

  private

  ISSUE_ID_REGEXP = /(?:[^a-z]|\A)(?:#|REDMINE-)(\d+)/

  def scan_description_for_issue_ids
    self.issues = []
    mentioned_issue_ids.each do |match|
      issue = Issue.find_by_id(match[0])
      if issue != nil && (@allowed_projects[0] == '*' || @allowed_projects.include?(issue.project.id))
        self.issues.push(issue)
      end
    end
  end

  def mentioned_issue_ids
    [description, title].flat_map do |value|
      (value || '').scan(ISSUE_ID_REGEXP)
    end.uniq
  end
end
