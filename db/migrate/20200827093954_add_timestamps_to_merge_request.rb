class AddTimestampsToMergeRequest < ActiveRecord::Migration[5.2]
  def change
    change_table :merge_requests do |t|
      t.timestamps
    end
  end
end
