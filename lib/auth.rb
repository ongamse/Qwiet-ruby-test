require 'pry-byebug'
require 'db_ops'
require 'auth'
require 'digest'

class Authenticator
    SESSION_SECRET_USER = Digest::MD5.hexdigest 'user security token'
    SESSION_SECRET_ADMIN = Digest::MD5.hexdigest 'admin secret sauce'

    def initialize(cookies, db)
        @cookies = cookies
        @db = db
    end

    def self.hash_password(password)
        Digest::MD5.hexdigest password
    end

    def is_logged_in?(session_secret)
        if (defined?(@cookies) and @cookies[:session_priv] == session_secret and @db.user_exists?(@cookies[:user_id]))
            true
        else
            false
        end
    end

    def logout
        @cookies.delete(:user_id)
        @cookies.delete(:session_priv)
    end

    def is_logged_in_user?
        is_logged_in?(SESSION_SECRET_USER)
    end

    def is_logged_in_admin?
        is_logged_in?(SESSION_SECRET_ADMIN)
    end

    def authenticate_user(email, password)
        return false unless !is_logged_in_user? and !is_logged_in_admin?

        hash = self.class.hash_password(password)
        result = @db.select_user(email, hash)
        return false unless result.length > 0

        user = result[0]
        user_id = user[0]
        user_role = user[1]
        if (user_role == 'admin')
            @cookies[:user_id] = user_id
            @cookies[:session_priv] = SESSION_SECRET_ADMIN
            true
        elsif (user_role == 'user') 
            @cookies[:user_id] = user_id
            @cookies[:session_priv] = SESSION_SECRET_USER
            true
        else
            false
        end
    end
end