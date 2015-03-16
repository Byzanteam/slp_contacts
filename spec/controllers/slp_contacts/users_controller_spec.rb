require 'rails_helper'

module SlpContacts
  RSpec.describe UsersController, type: :controller do

    let(:user) { Fabricate(:user) }
    let(:valid_session) { { current_user_id: user.id } }

    describe "GET #show" do
      it "when current_user equals @user" do
        get :show, { id: user.id }, valid_session
        expect(response).to redirect_to root_path
      end
      it "when current_user doesnot equal @user" do
        another_user = Fabricate(:user, name: "xx")
        get :show, { id: another_user.id }, valid_session
        expect(assigns(:user)).to eq another_user
      end
    end

    describe "POST #favorite" do
      it "slp_contacts_favorite table's count adds 1" do
        contact = Fabricate(:user, name: "xx")
        expect{
          xhr :post, :favorite, { id: contact.id, format: :js }, valid_session
          }.to change(Favorite, :count).by(1)
      end

      it "fails when users collect self" do 
        xhr :post, :favorite, { id: user.id, format: :js }, valid_session
        expect(response).to have_http_status(403)
      end
    end

    describe "DELETE #unfavorite" do
      it "slp_contacts_favorite table's count cut 1" do
        contact = Fabricate(:user, name: "xx")
        Favorite.create(user_id: user.id, contact_id: contact.id)
        expect{
          xhr :delete, :unfavorite, { id: contact.id, format: :js }, valid_session
          }.to change(Favorite, :count).by(-1)
      end
      it "fails when users uncollect self" do 
        xhr :delete, :unfavorite, { id: user.id, format: :js }, valid_session
        expect(response).to have_http_status(403)
      end
    end

    describe "GET #query" do
      it "returns a json when user exists " do
        contact1 = Fabricate(:user, name: 'xx1')
        xhr :get, :query, { name: "xx1", format: :json }, valid_session
        json = JSON.parse(response.body)
        expect(json['results'][0]['name']).to eq contact1.name
      end
    end


  end
end
