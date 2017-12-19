require 'rails_helper'
RSpec.describe Breed, type: :model do
  describe 'validations' do
    subject { Breed.new }
    it 'should require a name' do
      expect(subject).to be_invalid
      expect(subject.errors[:name]).to include("can't be blank")
    end
    it 'it should require unique names' do
      Breed.create(name: 'Foo')
      subject.name = 'Foo'
      expect(subject).to be_invalid
      expect(subject.errors[:name]).to include('has already been taken')
    end
  end
end
