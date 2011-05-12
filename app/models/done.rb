module Done
  def self.included(base)
    base.class_eval do
      def done!
        self.update_attributes!(:deleted_at => Time.now)
        # TODO: :dependent => :destroy
      end
    end
  end
end
