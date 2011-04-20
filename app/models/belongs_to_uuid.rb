module BelongsToUuid
  def self.included(base)
    base.reflections.select{|k, r| r.macro == :belongs_to }.each do |name, reflection|
      if reflection.klass.attribute_method? :uuid
        base.class_eval do
          attr_reader "#{name}_uuid"
          define_method "#{name}_uuid=" do |value|
            self.send("#{name}_id=", reflection.klass.where(:uuid => value).first.id)
          end
        end
      end
    end
  end
end
