class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    @lists = List.all.reverse
  end

  def show
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)

    if @list.save
      respond_to do |format|
        format.html { redirect_to lists_path, notice: 'List successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'List successfully created.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      respond_to do |format|
        format.html { redirect_to lists_path, notice: 'List successfully edited.' }
        format.turbo_stream { flash.now[:notice] = 'List successfully edited.' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_path }
      format.turbo_stream { flash.now[:notice] = 'List successfully destroyed.' }
    end
  end

  private

  def list_params
    params.require(:list).permit(:name)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
