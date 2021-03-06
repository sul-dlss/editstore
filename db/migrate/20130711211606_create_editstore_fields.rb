class CreateEditstoreFields < ActiveRecord::Migration[4.2]
  def change
    if Editstore.run_migrations?
      @connection=Editstore::Connection.connection
      create_table :editstore_fields do |t|
        t.integer :project_id,:null=>false
        t.string  :name,:null=>false
        t.timestamps :null=>true
      end
      Editstore::Field.create(:id=>1,:name=>'title',:project_id=>'1')
      Editstore::Field.create(:id=>2,:name=>'description',:project_id=>'1')
    end
  end
end
