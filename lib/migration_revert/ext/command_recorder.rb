module ActiveRecord
  class Migration
    class CommandRecorder
      def revert
        @reverting = !@reverting
        previous = @commands
        @commands = []
        yield
      ensure
        @commands = previous.concat(@commands.reverse)
        @reverting = !@reverting
      end

      # record +command+. +command+ should be a method name and arguments.
      # For example:
      #
      #   recorder.record(:method_name, [:arg1, :arg2])
      #
      def record(*command, &block)
        if @reverting
          @commands << inverse_of(*command)
        else
          @commands << (command << block)
        end
      end

      [:create_table, :create_join_table, :change_table, :rename_table, :add_column, :remove_column, :rename_index, :rename_column, :add_index, :remove_index, :add_timestamps, :remove_timestamps, :change_column, :change_column_default, :add_reference, :remove_reference].each do |method|
        class_eval <<-EOV, __FILE__, __LINE__ + 1
          def #{method}(*args, &block)          # def create_table(*args, &block)
            record(:"#{method}", args, &block)  #   record(:create_table, args, &block)
          end                                   # end
        EOV
      end
      alias :add_belongs_to :add_reference
      alias :remove_belongs_to :remove_reference

      # Returns the inverse of the given command
      #
      #   recorder.inverse_of(:rename_table, [:old, :new])
      #    # => [:rename_table, [:new, :old]]
      #
      # This method will raise an +IrreversibleMigration+ exception if it cannot
      # invert the +commands+.
      #
      def inverse_of(name, args)
        method = :"invert_#{name}"
        raise IrreversibleMigration unless respond_to?(method, true)
        send(method, args)
      end
    end
  end
end