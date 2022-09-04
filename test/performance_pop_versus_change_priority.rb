
# frozen_string_literal: true
# Based on https://github.com/matiasbattocchia/lazy_priority_queue/blob/master/test/performance.rb
require 'benchmark/ips'
require_relative '../lib/pairing_heap'
require 'lazy_priority_queue'
require_relative 'fib'
require 'rb_heap'

N = 1000
ODD_ARRAY = 1.step(N, 2).to_a.tap(&:shuffle!)
EVEN_ARRAY = 0.step(N, 2).to_a.tap(&:shuffle)
def with_change_priority(push, change_priority, pop)
	ODD_ARRAY.each do |el, idx|
		push.call(el)
	end

	ODD_ARRAY.each_with_index do |el, idx|
		even_el = EVEN_ARRAY[idx]
		if even_el < el
			change_priority.call(el, even_el)
		else
			change_priority.call(el, -(N - el))
		end
	end
	ODD_ARRAY.size.times { pop.call }
end

def without_change_priority(push, pop)
	ODD_ARRAY.each do |el, idx|
		push.call(el)
	end
	ODD_ARRAY.each_with_index do |el, idx|
		push.call(el)
		even_el = EVEN_ARRAY[idx]
		if even_el < el
			push.call(even_el)
		else
			push.call(-(N - el))
		end
	end
	(ODD_ARRAY.size * 2).times { pop.call }
end

Benchmark.ips do |bm|
  bm.time = 60
  bm.warmup = 15

  bm.report('lazy_priority_queue') do
    q = MinPriorityQueue.new
    with_change_priority(->(n) { q.enqueue(n, n) }, ->(e, p) { q.change_priority(e, p) }, -> { q.dequeue })
  end

  bm.report('pairing_heap') do
    q = PairingHeap::MinPriorityQueue.new
    with_change_priority(->(n) { q.enqueue(n, n) }, ->(e, p) { q.change_priority(e, p) }, -> { q.dequeue })
  end

  bm.report('simple_pairing_heap') do
    q = PairingHeap::SimplePairingHeap.new
    without_change_priority(->(n) { q.enqueue(n, n) }, -> { q.dequeue })
  end

  bm.report('Fibonacci') do
    q = RubyPriorityQueue.new
    with_change_priority(->(n) { q.push(n, n) }, ->(e, p) { q.change_priority(e, p)}, -> { q.delete_min })
  end

  bm.report('rb_heap') do
    q = Heap.new(:<)
    without_change_priority(->(n) { q.add(n) }, -> { q.pop })
  end

  bm.compare!
end
