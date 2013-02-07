module Forem
  module Admin
    class CategoriesController < BaseController
      before_filter :find_category, :only => [:edit, :update, :destroy, :sort_forums]
      skip_filter :authenticate_forem_admin, :only => :sort_forums

      def index
        @category = Forem::Category.all
      end

      def new
        @category =  Forem::Category.new
      end

      def create
        @category = Forem::Category.new(params[:category])
        if @category.save
          audit(@category, :create)
          flash[:notice] = t("forem.admin.category.created")
          redirect_to admin_categories_path
        else
          flash.now.alert = t("forem.admin.category.not_created")
          render :action => "new"
        end
      end

      def update
        if @category.update_attributes(params[:category])
          audit(@category, :update)
          flash[:notice] = t("forem.admin.category.updated")
          redirect_to admin_categories_path
        else
          flash.now.alert = t("forem.admin.category.not_updated")
          render :action => "edit"
        end
      end

      def destroy
        audit(@category, :destroy) if @category.destroy
        flash[:notice] = t("forem.admin.category.deleted")
        redirect_to admin_categories_path
      end

      def sort_forums
        user = current_user.forum_user
        if @category.moderator?(user) || user.forem_admin? || user.forem_mod?
          @category.custom_forums_sort(params['id'], params['forumIds'])
          render :json => true
        else
          render :json => false
        end
      end

      private
        def find_category
          @category = Forem::Category.find(params[:id])
        end

    end
  end
end
