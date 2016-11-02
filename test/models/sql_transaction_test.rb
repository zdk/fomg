require 'test_helper'

class SqlTransactionTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  class ::OMG < ActiveRecord::Base
  end

  setup do
    OMG.connection.create_table :omgs, force: true do |t|
      t.string :name
    end
  end

  teardown do
    ActiveRecord::Base.connection.drop_table 'omgs'
  end

  test "Create SELECT statement after add_column migration" do
    record = OMG.create! name: 'LOL'

    OMG.connection.add_column :omgs, :description, :string

    assert_equal 'LOL', record.name

    OMG.transaction do
       record = OMG.find(1)
       assert_equal 'LOL', record.name
    end

    ActiveRecord::Base.connection.execute('ALTER TABLE omgs ADD boo integer;')

    OMG.transaction do
       record = OMG.find(1)
       assert_equal 'LOL', record.name
    end

    OMG.transaction do
       record = OMG.find(1)
       assert_equal 'LOL', record.name
    end
  end

end
