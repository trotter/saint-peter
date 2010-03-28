ActiveRecord::Schema.define do
  create_table "users", :force => true do |t|
    t.string "name"
    t.string "roles"
  end

  create_table "resources", :force => true do |t|
    t.string "name"
    t.string "roles"
  end
end
