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
    # (named_)scope seems to have trouble with unscoped. So use where directly
    # e.g. Rails3.0.0.rc: Listing.unscoped.user(1).to_sql contains "listings.deleted_at IS NULL"
#     base.class_eval do
#       scope :user, lambda {|u| where(:user_id => u)}
#     end
  end
end
