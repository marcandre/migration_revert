# MigrationRevert

Reversible migrations are very cool.

Some commands are not reversible, for example the removal of a table or a column.

Also, one downside is that it is now more difficult to write the reverse of a migration if `change` is used. When `up` and `down` were used, one could simply swap the code around.

This gem introduces `Migration#revert` that makes it trivial to revert a past migration, in part or in whole, or do the doing a reversible removal of a table/column.

Note that `revert` can even be called from legacy migrations using `up` & `down` and that it can revert legacy-style migrations too. For anyone changing their mind every second day, `revert` is fully nestable.

Sounds useful? Give a +1 to https://github.com/rails/rails/pull/7627

Also introduces `Migration#reversible` for data operations that can be reverted.

Sounds useful also? Give a +1 to https://github.com/rails/rails/pull/8177

## Usage

### revert

Reverses the migration commands for the given block and
the given migrations.

The following migration will remove the table 'horses'
and create the table 'apples' on the way up, and the reverse
on the way down.

    class FixTLMigration < ActiveRecord::Migration
      def change
        revert do
          create_table(:horses) do |t|
            t.text :content
            t.datetime :remind_at
          end
        end
        create_table(:apples) do |t|
          t.string :variety
        end
      end
    end

Or equivalently, if `TenderloveMigration` is defined as in the
documentation for Migration:

    class FixupTLMigration < ActiveRecord::Migration
      def change
        revert TenderloveMigration

        create_table(:apples) do |t|
          t.string :variety
        end
      end
    end

This command can be nested.

### reversible

Used to specify an operation that can be run in one direction or another.
Call the methods +up+ and +down+ of the yielded object to run a block
only in one given direction.
The whole block will be called in the right order within the migration.

In the following example, the looping on users will always be done
when the three columns 'first_name', 'last_name' and 'full_name' exist,
even when migrating down:

    class SplitNameMigration < ActiveRecord::Migration
      def change
        add_column :users, :first_name, :string
        add_column :users, :last_name, :string

        reversible do |dir|
          User.reset_column_information
          User.all.each do |u|
            dir.up   { u.first_name, u.last_name = u.full_name.split(' ') }
            dir.down { u.full_name = "#{u.first_name} #{u.last_name}" }
            u.save
          end
        end

        revert { add_column :users, :full_name, :string }
      end
    end

## Installation

Add this line to your application's Gemfile:

    gem 'migration_revert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install migration_revert
