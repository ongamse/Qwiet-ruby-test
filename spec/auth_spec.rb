require 'pry-byebug'
require 'db_ops'
require 'auth'

def h(password)
  Authenticator::hash_password(password)
end

RSpec.describe "Authenticating users" do
    before(:context) do
        admin = CredzyDb::SEED_USERS[0]
        @test_admin_email = admin[0]
        @test_admin_pwd = admin[1] 
        @test_admin_pwd_hash = Authenticator::hash_password(@test_admin_pwd)
        @test_admin_role = admin[2]

        user = CredzyDb::SEED_USERS[1]
        @test_user_email = user[0] 
        @test_user_pwd = user[1]
        @test_user_pwd_hash = Authenticator::hash_password(@test_user_pwd)
        @test_user_role = user[2]

        @credzy_db = CredzyDb.new(true, "test.db")
        @credzy_db.seed(:h)
    end

    context "No cookies" do
        let(:cookies) { Hash.new }
        let(:auth) { Authenticator.new(cookies, @credzy_db) }

        it "Does not detect login" do
            expect(auth.is_logged_in_admin?).to be false
            expect(auth.is_logged_in_user?).to be false
        end

        it "Grants user privilege to users" do
            authenticated = auth.authenticate_user(@test_user_email, @test_user_pwd)
            expect(authenticated).to be true
            expect(auth.is_logged_in_user?).to be true
            expect(auth.is_logged_in_admin?).to be false
        end

        it "Grants admin privilege to admin" do
            authenticated = auth.authenticate_user(@test_admin_email, @test_admin_pwd)
            expect(authenticated).to be true
            expect(auth.is_logged_in_user?).to be false
            expect(auth.is_logged_in_admin?).to be true
        end

        it "Rejects invalid login attempt" do
            authenticated = auth.authenticate_user("asdf", "asdf")
            expect(authenticated).to be false
            expect(auth.is_logged_in_user?).to be false
            expect(auth.is_logged_in_admin?).to be false 
        end
    end

    context "With admin cookie" do
        let(:cookies) {
            {
                :user_id => @test_admin_email, 
                :session_priv => Authenticator::SESSION_SECRET_ADMIN
            }
        }
        let(:auth) { Authenticator.new(cookies, @credzy_db) }

        it "Always denies login attempt" do
            authenticated = auth.authenticate_user(@test_user_email, @test_user_pwd)
            expect(authenticated).to be false 

            authenticated = auth.authenticate_user(@test_admin_email, @test_admin_pwd)
            expect(authenticated).to be false 
        end

        it "Clears cookies on logout" do
            expect(auth.is_logged_in_user?).to be false
            expect(auth.is_logged_in_admin?).to be true 

            auth.logout()

            expect(auth.is_logged_in_user?).to be false
            expect(auth.is_logged_in_admin?).to be false 
        end
    end
  end