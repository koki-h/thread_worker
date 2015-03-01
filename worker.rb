class Worker
  @@workers = []
  @@waiting = 0
  @@mutex = Mutex.new
  attr_reader :thread

  def initialize
    @@mutex.synchronize {
      @@waiting += 1
    }
    while(true) do
      @@mutex.synchronize {
        if @@workers.count < @@concurrency
          @@workers << self 
          @thread = Thread.start do  
            yield
            @@workers.delete(self)
          end
          @@waiting -= 1
          return
        else
          sleep 1
        end
      }
    end
  end

  class << self
    def concurrency=(num)
      @@concurrency = num
    end

    def join
      @@mutex.synchronize {
        while (@@waiting > 0) do sleep 1 end
        @@workers.each do |t|
          t.thread.join
        end
      }
    end
  end
end

Worker.concurrency =3 
20.times do |i|
  puts "no#{i}"
  Worker.new{
     sleep 1
     puts "yes!#{i}"
     #open("#{i}.txt","w") {|f|f.puts i}
  }
end
puts "main thread"
Worker.join
