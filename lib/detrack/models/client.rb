module DeTrack
  module Models
    class Client
      attr_reader :id, :full_name, :email

      def initialize(id:, full_name:, email:)
        @id = validate_id(id)
        @full_name = validate_full_name(full_name)
        @email = validate_email(email)
      end

      def self.from_hash(hash)
        new(
          id: hash['id'],
          full_name: hash['full_name'],
          email: hash['email']
        )
      end

      def to_h
        {
          'id' => @id,
          'full_name' => @full_name,
          'email' => @email
        }
      end

      def name_matches?(query)
        return false if query.nil? || query.strip.empty?

        @full_name.downcase.include?(query.downcase.strip)
      end

      def ==(other)
        other.is_a?(Client) &&
          @id == other.id &&
          @full_name == other.full_name &&
          @email == other.email
      end

      def to_s
        "ID: #{@id}, Name: #{@full_name}, Email: #{@email}"
      end

      private

      def validate_id(id)
        raise ArgumentError, 'ID must be a positive integer' unless id.is_a?(Integer) && id > 0
        id
      end

      def validate_full_name(name)
        raise ArgumentError, 'Full name cannot be nil or empty' if name.nil? || name.strip.empty?
        name.strip
      end

      def validate_email(email)
        raise ArgumentError, 'Email cannot be nil or empty' if email.nil? || email.strip.empty?
        raise ArgumentError, 'Invalid email format' unless email.strip.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
        email.strip.downcase
      end
    end
  end
end