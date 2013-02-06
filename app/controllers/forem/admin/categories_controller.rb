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
        # if can?(:moderate, @category.forums.first)
          result = @category.custom_forums_sort(params['id'], params['forumIds'])
        # end

        render :json => result

        # if can? :moderate, @forum
        #   #current_user.forum_user.update_attributes(accepted_terms: true)
        #   #current_user.touch  # update cache key
        #   render :json => current_user.forum_user.accepted_terms
        # else
        #   render :json => !current_user.forum_user.accepted_terms
        # end
      end

      private
        def find_category
          @category = Forem::Category.find(params[:id])
        end

    end
  end
end
