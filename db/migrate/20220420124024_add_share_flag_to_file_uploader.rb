class AddShareFlagToFileUploader < ActiveRecord::Migration[6.0]
  # def change
  # end

  def up
    add_column :file_uploaders, :share, :boolean, default: false
  end

  def down
    remove_column :file_uploaders, :share
  end
end
