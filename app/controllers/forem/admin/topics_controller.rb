module Forem
  module Admin
    class TopicsController < BaseController
      before_filter :find_topic
      before_filter(:only => [:toggle_lock, :toggle_pin]) { |c| c.forem_admin_or_moderator? @topic.forum }
      before_filter :authenticate_forem_admin, :only => [:update, :destroy, :toggle_hide]
      
      skip_filter :authenticate_forem_admin

      def update
        if @topic.update_attributes(params[:topic], :as => :admin)
          audit(@topic, :update)
          flash[:notice] = t("forem.topic.updated")
          redirect_to forum_topic_path(@topic.forum, @topic)
        else
          flash.alert = t("forem.topic.not_updated")
          render :action => "edit"
        end
      end

      def destroy
        forum = @topic.forum
        audit(@topic, :destroy) if @topic.destroy
        flash[:notice] = t("forem.topic.deleted")
        redirect_to forum_topics_path(forum)
      end

      def toggle_hide
        audit(@topic, :hide) if @topic.toggle!(:hidden)
        flash[:notice] = t("forem.topic.hidden.#{@topic.hidden?}")
        redirect_to forum_topic_path(@topic.forum, @topic)
      end

      def toggle_lock
        audit(@topic, :lock) if @topic.toggle!(:locked)
        flash[:notice] = t("forem.topic.locked.#{@topic.locked?}")
        redirect_to forum_topic_path(@topic.forum, @topic)
      end

      def toggle_pin
        audit(@topic, :pin) if @topic.toggle!(:pinned)
        flash[:notice] = t("forem.topic.pinned.#{@topic.pinned?}")
        redirect_to forum_topic_path(@topic.forum, @topic)
      end
      
      def forem_admin_or_moderator?(forum)
        forem_user && (forem_user.forem_admin? || forum.moderator?(forem_user))
      end

      def change_forum
        @topic.change_forum(params[:topic][:forum_id])
        flash[:notice] = "You just changed the Forum of '#{@topic.subject}'"
        redirect_to forum_topic_path(@topic.forum, @topic)
      end

      helper_method :forem_admin_or_moderator?

      private
        def find_topic
          @topic = Forem::Topic.find(params[:id])
          
        rescue Exception
          @topic = Forem::Topic.find_by_slug params[:id]
        end
    end
  end
end
