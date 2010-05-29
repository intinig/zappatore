module Shufflable
  def self.included(klass)
    klass.class_eval do
      def shuffle!
        n = length #The number of items left to shuffle
        while (n > 1)
          k = rand(n) 
          n = n -1 #n is now the last pertinent index
          self[k], self[n] = self[n], self[k]
        end
      end
    end
  end
end