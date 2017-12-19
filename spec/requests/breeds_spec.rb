require 'rails_helper'

RSpec.describe 'Breeds', type: :request do
  describe 'GET /breeds/' do
    cat_names = ['American Bobcat', 'Cymric']
    before :each do
      cat_names.each do |cat_name|
        Breed.create(name: cat_name)
      end
    end
    it 'should return a list of all breeds' do
      get '/breeds/'
      expect(parsed_response.length).to eq(2)
      expect(parsed_response.map {|cat| cat[:name]} ).to eq(cat_names)
    end
  end

  describe 'GET /breeds/:id' do
    let!(:breed) { Breed.create(name: 'Foocat') }
    let!(:tag) { Tag.create(name: 'RandomTag')  }
    it 'should return the right breed' do
      get "/breeds/#{breed.id}"
      expect(parsed_response[:name]).to eq(breed.name)
    end
    it 'should return the tags' do
      breed.tags << tag
      get "/breeds/#{breed.id}"
      expect(parsed_response[:tags].count).to eq(1)
      expect(parsed_response[:tags].first).to include(name: 'RandomTag')
    end
    describe 'GET /breeds/:id/tags' do
      it 'returns tags for breed' do
        get "/breeds/#{tag.id}/tags"
        expect(parsed_response.count).to eq(1)
        expect(parsed_response.first[:name]).to eq('RandomTag')
      end
    end
  end

  describe 'GET /breeds/stats' do
    let!(:breed) do
      c = Breed.create(name: 'Foo')
      c.tags.create(name: 'Tag')
      c
    end
    it 'should return breed statistics' do
      get '/breeds/stats'
      expect(response).to have_http_status(200)
      expect(parsed_response).to match([{:id=>1, :name=>"Foo", :tag_count=>1, :tag_ids=>[1]}])
    end
  end

  describe 'POST /breeds/' do
    it 'should create a new breed record' do
      expect {
        post '/breeds/', params: {breed: {name: 'New Cat'}}
      }.to change{ Breed.count }
      .from(0)
      .to(1)
    end

    it 'should require a name' do
      post '/breeds/', params: {breed: {name: ''}}
      expect(response).to have_http_status(422)
      expect(parsed_response[:name]).to include("can't be blank")
    end

    context 'with tags' do
      let!(:new_breed_params) {
        { breed:
          {
            name: 'Cat Name',
            tags: [
              {name: 'Knows Kung Fu'},
              {name: 'Climbs Trees'}
            ]
          }
        }
      }
      it 'should create the breed' do
        expect {
          post '/breeds/', params: new_breed_params
        }.to change(Breed, :count)
        .from(0)
        .to(1)
        expect(response).to have_http_status(201)
      end
      it 'the breed should have tags' do
        post '/breeds/', params: new_breed_params
        breed = Breed.find_by_name(new_breed_params[:breed][:name])
        expect(breed.tags.map(&:name)).to contain_exactly('Knows Kung Fu', 'Climbs Trees')
      end
    end
  end

  describe 'PATCH /breeds/:id' do
    let!(:update_params) {
      { breed:
        {
          name: 'Alleycat',
          tags: [
            {name: 'Knows Ruby'}
          ]
        }
      }
    }
    let!(:cat) do
      cat = Breed.create(name: 'Tomcat')
      ['Knows Kung Fu', 'Climbs Trees'].each do |tag|
        cat.tags.create(name: tag)
      end
      cat
    end
    it 'should update breed name and tags' do
      expect {
        patch "/breeds/#{cat.id}", params: update_params
      }.to change{ cat.reload.name }
      .from('Tomcat')
      .to('Alleycat')
    end
  end

  describe 'DELETE /breeds/:id' do
    let!(:cat) do
      cat1 = Breed.create(name: 'Tomcat')
      cat2 = Breed.create(name: 'Alleycat')
      ['Knows Kung Fu', 'Climbs Trees'].each do |tag_name|
        cat1.tags.create(name: tag_name)
      end
      cat2.tags << Tag.first
      cat1
    end

    it 'should delete breed' do
      expect {
        delete "/breeds/#{cat.id}"
        }.to change(Breed, :count)
        .from(2)
        .to(1)
    end

    it 'should delete unique tags only' do
      expect {
        delete "/breeds/#{cat.id}"
      }.to change{ Tag.where(name: 'Climbs Trees').count }
      .from(1)
      .to(0)
    end
  end
end