# frozen_string_literal: true

# Based on https://github.com/matiasbattocchia/lazy_priority_queue/blob/master/test/performance.rb
require "benchmark/ips"
require_relative "../../lib/pairing_heap"
require "lazy_priority_queue"
require_relative "fib"

N = 1_000
def iterator(push, pop, change_priority)
  N.times do |i|
    (N - i).times do |j|
      push.call i.to_s + ":" + j.to_s
    end

    (N - i).times do |j|
      change_priority.call(i.to_s + ":" + j.to_s)
    end

    i.times do
      pop.call
    end
  end
end

Benchmark.ips do |bm|
  bm.time = 60
  bm.warmup = 15

  bm.report("lazy_priority_queue") do
    q = MinPriorityQueue.new
    iterator(->(n) { q.enqueue(n, rand) }, -> { q.dequeue }, ->(n) { q.change_priority(n, -rand) })
  end

  bm.report("pairing_heap") do
    q = PairingHeap::MinPriorityQueue.new
    iterator(->(n) { q.enqueue n, rand }, -> { q.dequeue }, ->(n) { q.change_priority(n, -rand) })
  end

  bm.report("Fibonacci") do
    q = RubyPriorityQueue.new
    iterator(->(n) { q.push n, rand }, -> { q.delete_min }, ->(n) { q.change_priority(n, -rand) })
  end

  bm.compare!
end
