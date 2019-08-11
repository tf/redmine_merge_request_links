class CreateProjectsToken < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :projects_merge_request_tokens do |t|
      t.string :provider, null: false
      t.string :token, index: { unique: true }, null: false
      t.integer :project_id, null: false
      t.boolean :subprojects, default: true
      t.index [:project_id, :provider], name: "token_index", unique: true
    end
  end
end
