require 'spec_helper.rb'

Dir.chdir(Rails.root) do
 `rake railties:install:migrations`
end

require Dir.glob("#{Rails.root}/db/migrate/*add_forem_mod.forem.rb").first

describe AddForemMod do
  include_context "user migrations"
  
  it "adds forem_admin to user_class" do
    subject.should_receive('column_exists?').and_return(false)
    subject.should_receive('add_column').with(:users, :forem_mod, :boolean, {:default=>false})
    subject.change
  end
end