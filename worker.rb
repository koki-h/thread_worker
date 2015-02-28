class Worker
  @@workers = []
  @@mutex = Mutex.new
  attr_reader :thread

  def initialize
    #前のワーカの仕事が終わるまでコンカレンシーを超えた分の新規ワーカの登録ができない。
    #コンカレンシーは登録を制限するのではなく、それぞれのスレッドに判断させたほうがいいような。
    #スレッドは無条件にスタートするが、仕事の実行は自分の番が来るまで待つようにする。
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
