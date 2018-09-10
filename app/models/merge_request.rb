class MergeRequest < ActiveRecord::Base
  has_and_belongs_to_many :issues

  attr_accessor :description

  after_save :scan_description_for_issue_ids

  private

  ISSUE_ID_REGEXP = /[^a-z]#(\d+)/

  def scan_description_for_issue_ids
    self.issues = (description || '').scan(ISSUE_ID_REGEXP).map do |match|
      Issue.find_by_id(match[0])
    end.compact
  end
end
