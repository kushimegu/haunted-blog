# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :permit_editing, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = if current_user&.blogs&.find_by(id: params[:id])
              Blog.find(params[:id])
            else
              Blog.where(secret: false).find(params[:id])
            end
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def blog_params
    attributes = %i[title content secret]
    attributes.push(:random_eyecatch) if current_user.premium == true
    params.require(:blog).permit(attributes)
  end

  def permit_editing
    @blog = current_user.blogs.find(params[:id])
  end
end
