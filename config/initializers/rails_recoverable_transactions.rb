module TransactionRecoverable
  module ClassMethods
    raise "We may no longer need the monkeypatch #{__FILE__}!" if Rails::VERSION::MAJOR > 4

    def transaction(*args)
      puts "TransactionRecoverable Loaded."
      super(*args) do
        yield
      end
    rescue PG::InFailedSqlTransaction => e
      connection.rollback_db_transaction
      connection.clear_cache!

      super(*args) do
        yield
      end
    end
  end
end

class << ActiveRecord::Base
  prepend TransactionRecoverable::ClassMethods
end
