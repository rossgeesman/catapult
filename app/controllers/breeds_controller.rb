class BreedsController < ApplicationController
  before_action :set_breed, only: [:show, :update, :destroy]

  def index
    @breeds = Breed.all

    render json: @breeds
  end

  def show
    render json: @breed.as_json(include: :tags)
  end

  def create
    @breed = Breed.new(name: breed_params[:name])

    if breed_params[:tags]
      breed_params[:tags].each do |tag_name|
        @breed.tags.find_or_initialize_by(tag_name)
      end
    end

    if @breed.save
      render json: @breed.as_json(include: :tags), status: :created
    else
      render json: @breed.errors, status: :unprocessable_entity
    end
  end

  def update
    @breed.assign_attributes(name: breed_params[:name])

    if breed_params[:tags]
      @breed.taggings.destroy_all
      breed_params[:tags].each do |tag_name|
        @breed.tags.find_or_initialize_by(tag_name)
      end
    end

    if @breed.save(breed_params)
      render json: @breed.as_json(include: :tags)
    else
      render json: @breed.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @breed.destroy
  end

  def stats
    @breeds = Breed.all
    render json: @breeds.as_json(only: [:id, :name], methods: [:tag_count, :tag_ids])
  end

  private
    def set_breed
      @breed = Breed.find(params[:id])
    end

    def breed_params
      params.require(:breed).permit(:name, tags: [:name])
    end
end
