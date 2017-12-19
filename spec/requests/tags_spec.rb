require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  describe 'GET /tags' do
    tag_params = { name: 'Furry' }
    before do
      Tag.create(tag_params)
    end
    it 'should return all tags' do
      get '/tags'
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first[:name]).to eq(tag_params[:name])
    end
  end

  describe 'GET /tags/:id' do
    before do
      %w[Furry Cute].each do |tag_name|
        Tag.create(name: tag_name)
      end
    end
    it 'should get the correct tag' do
      get '/tags/1'
      expect(parsed_response).to include(id: 1, name: 'Furry')
      get '/tags/2'
      expect(parsed_response).to include(id: 2, name: 'Cute')
    end
  end

  describe 'PATCH /tags/:id' do
    let!(:tag) { Tag.create(name: 'Foo') }

    it 'should update tag' do
      expect {
        patch "/tags/#{tag.id}", params: { tag: {name: 'Foobar'} }
      }.to change { tag.reload.name }
        .from('Foo')
        .to('Foobar')
    end
  end

  describe 'GET /tags/stats' do
    before :each do
      cat = Breed.create(name: 'Tomcat')
      %w[Furry Cute].each do |tag_name|
        Tag.create(name: tag_name)
      end
      cat.tags << Tag.first
    end

    it 'should return tag stats' do
      get '/tags/stats'
      expect(response).to have_http_status 200
      expect(parsed_response)
        .to match(tags: [
          {
            id: 1,
            name: 'Furry',
            breed_count: 1,
            breed_ids: [1]
          },
          {
            id: 2,
            name: 'Cute',
            breed_count: 0,
            breed_ids: []
          }
        ])
    end
  end

  describe 'DELETE /tags/:id' do
    before do
      cat = Breed.create(name: 'CatName')
      cat.tags.create(name: 'Foo')
    end

    let(:cat) { Breed.first }
    let(:tag) { cat.tags.first }

    it 'should destroy the tag' do
      expect { delete "/tags/#{tag.id}" }
        .to change { Tag.count }
        .from(1)
        .to(0)
    end
  end
end
