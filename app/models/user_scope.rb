module UserScope
  def self.included(base)
    if base.respond_to?(:with_scope)
      def base.with_user_scope(user, &block)
        with_scope({
            :find => where(:user_id => user.try(:id)),
            :create => {:user_id => user.try(:id)}
          }, :merge, &block)
      end
    end
  end
end
