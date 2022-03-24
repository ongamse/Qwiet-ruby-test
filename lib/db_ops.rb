require 'sqlite3'

class CredzyDb
    DB_PATH = "db/credzy.db"

    SEED_USERS = [
        ['admin@credzy.com', 'secure-af-pwd99', 'admin'],
        ['alice@cryptopals.com', 'secure', 'user'],
        ['bob@cryptopals.com', 'passw0rd', 'user']
    ]

    SEED_DOCUMENTS = [
        ['admin@credzy.com', 'hawaii.jpeg'],
        ['alice@cryptopals.com', 'newyork.jpeg'],
        ['bob@cryptopals.com', 'qld.jpg']
    ]

    def initialize(clear_db, db_path = DB_PATH)
        if (clear_db or !File.exist?(db_path))
            File.delete(db_path) if File.exist?(db_path)
            @db = SQLite3::Database.new db_path
        else
            @db = SQLite3::Database.new db_path
        end
    end

    def seed(hash_function)
        @db.execute <<-SQL
        create table users (
            email varchar(64),
            pwd_hash char(32),
            role varchar(64)
        );
        SQL

        for user in SEED_USERS
            insert_user(user[0], method(hash_function).call(user[1]), user[2])
        end

        @db.execute <<-SQL
        create table documents (
            email varchar(64),
            filename char(32)
        );
        SQL

        for document in SEED_DOCUMENTS
            insert_document(document[0], document[1])
        end
    end

    def insert_user(email, password_hash, role)
        sql = "insert into users values ('#{email}', '#{password_hash}', '#{role}')"
        @db.execute sql
    end

    def insert_document(email, filename)
        sql = "insert into documents values ('#{email}', '#{filename}')"
        @db.execute sql
    end

    def select_documents(email)
        sql = "select filename from documents where email='#{email}'"
        results = @db.execute sql
        results.map { |result| result[0] }
    end

    def select_user_all
        sql = "select * from users"
        @db.execute sql
    end

    def select_user(email, password_hash)
        sql = "select email, role from users where email='#{email}' and pwd_hash='#{password_hash}'"
        @db.execute sql
    end

    def user_exists?(email)
        sql = "select rowid from users where email='#{email}'"
        result = @db.execute sql
        result.length > 0
    end
end