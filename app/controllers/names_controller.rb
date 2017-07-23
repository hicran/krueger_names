class NamesController < ApplicationController
  # before_action :set_name, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :do_it

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: "public/404.html", status: 404, layout: false
  end

  def index
    @from = params[:from].to_i
    @names = Name.all sort: 'name.raw', size: 1000, from: @from
  end

  def do_it
    IndexManagerNames.create_index
    IndexManagerNames.import_from_data
  end
  # 
  # def new
  #   @name = Name.new
  # end
  # 
  # def edit
  # end
  # 
  # def create
  #   @name = Name.new(name_params)
  # 
  #   respond_to do |format|
  #     if @name.save refresh: true
  #       format.html { redirect_to @name, notice: 'Name was successfully created.' }
  #       format.json { render :show, status: :created, location: @name }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @name.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # def update
  #   respond_to do |format|
  #     if @name.update(name_params, refresh: true)
  #       format.html { redirect_to @name, notice: 'Name was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @name }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @name.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # def destroy
  #   @name.destroy refresh: true
  #   respond_to do |format|
  #     format.html { redirect_to names_url, notice: 'Name was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end
  # 
  # private
  #   def set_name
  #     @name = Name.find(params[:id].split('-').first)
  #   end
  # 
  #   def name_params
  #     a = params.require(:name)
  #     a[:members] = a[:members].split(/,\s?/) unless a[:members].is_a?(Array) || a[:members].blank?
  #     return a
  #   end
end
