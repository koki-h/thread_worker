class Worker
  @@workers = []
  @@mutex = Mutex.new
  attr_reader :thread

  def initialize
    #$BA0$N%o!<%+$N;E;v$,=*$o$k$^$G%3%s%+%l%s%7!<$rD6$($?J,$N?75,%o!<%+$NEPO?$,$G$-$J$$!#(B
    #$B%3%s%+%l%s%7!<$OEPO?$r@)8B$9$k$N$G$O$J$/!"$=$l$>$l$N%9%l%C%I$KH=CG$5$;$?$[$&$,$$$$$h$&$J!#(B
    #$B%9%l%C%I$OL5>r7o$K%9%?!<%H$9$k$,!";E;v$N<B9T$O<+J,$NHV$,Mh$k$^$GBT$D$h$&$K$9$k!#(B
    while(true) do
      @@mutex.synchronize {
        if @@workers.count < @@concurrency
          @thread = Thread.start do  
            yield
            @@workers.delete(self)
          end
          @@workers << self 
          return
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
        @@workers.each do |t|
          t.thread.join
        end
      }
    end
  end
end

Worker.concurrency =4 
20.times do |i|
  puts "no#{i}"
  Worker.new{
     sleep 3
     puts "yes!#{i}"
     #open("#{i}.txt","w") {|f|f.puts i}
  }
end
puts "main thread"
Worker.join
