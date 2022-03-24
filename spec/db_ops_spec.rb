require 'pry-byebug'
require 'db_ops'
require 'auth'

def h(password)
  Authenticator::hash_password(password)
end

RSpec.describe "Adding users" do
    before(:context) do
        @test_user_email = 'ethan@kleine.com'
        @test_user_pwd = 'thiccboi'
        @test_user_pwd_hash = Authenticator::hash_password(@test_user_pwd)
        @test_user_role = 'user'

        @test_user_document_1 = 'thicc_drivers_licence.jpg'
        @test_user_document_2 = 'drivers_licence2.jpg'

        @credzy_db = CredzyDb.new(true, "test.db")
        @credzy_db.seed(:h)
    end

    context "Adding users" do
        it "Can insert user" do
            @credzy_db.insert_user(@test_user_email, @test_user_pwd_hash, @test_user_role)
            result = @credzy_db.select_user(@test_user_email, @test_user_pwd_hash)

            expect(result.length).to be(1)
            
            test_user = result[0]
            expect(test_user[0]).to eq(@test_user_email)
            expect(test_user[1]).to eq(@test_user_role)
        end

        it "Can check if user exists" do
            user_id = CredzyDb::SEED_USERS[0][0]
            user_exists = @credzy_db.user_exists?(user_id)

            expect(user_exists).to be true
        end

        it "Can select users" do
            users = @credzy_db.select_user_all()
            expect(users).not_to be_empty
        end

        it "Can select a specific user" do
            alice = CredzyDb::SEED_USERS[1]
            username = alice[0]
            password = alice[1]
            role = alice[2]
            result = @credzy_db.select_user(username, method(:h).call(password))
            expect(result.length).to be(1)
            
            test_user = result[0]
            expect(test_user[0]).to eq(username)
            expect(test_user[1]).to eq(role)
        end
    end

    context "Adding documents" do
        it "Can insert a document" do
            @credzy_db.insert_user(@test_user_email, @test_user_pwd_hash, @test_user_role)

            @credzy_db.insert_document(@test_user_email, @test_user_document_1)
            results = @credzy_db.select_documents(@test_user_email)
            expect(results.length).to be(1)

            @credzy_db.insert_document(@test_user_email, @test_user_document_2)
            results = @credzy_db.select_documents(@test_user_email)
            expect(results.length).to be(2)

            document_1 = results[0]
            expect(document_1).to eq(@test_user_document_1)

            document_2 = results[1]
            expect(document_2).to eq(@test_user_document_2)
        end
    end
  end