# frozen_string_literal: true

require "csv"
require "benchmark/ips"
require_relative "../../lib/pairing_heap"
require "lazy_priority_queue"
require_relative "fib"
require "rb_heap"
Edge = Struct.new(:to, :weight)

@neighbourhood = []
# https://gist.githubusercontent.com/mhib/ed03bb9eb67ae871fa6f199f024379c7/raw/4acd08372b3ffec2de1982449b2a4ee9fbaa48cd/Tokyo_Edgelist.csv
CSV.foreach("Tokyo_Edgelist.csv", headers: true) do |row|
  from = row["START_NODE"].to_i
  to = row["END_NODE"].to_i
  weight = row["LENGTH"].to_f
  @neighbourhood[from] ||= []
  @neighbourhood[from] << Edge.new(to, weight)
  @neighbourhood[to] ||= []
  @neighbourhood[to] << Edge.new(from, weight)
end

def get_costs(q)
  distance = Array.new(@neighbourhood.size, Float::INFINITY)
  distance[1] = 0
  q.push(1, 0)
  until q.empty?
    el = q.pop
    @neighbourhood[el].each do |edge|
      alt = distance[el] + edge.weight
      if distance[edge.to].infinite?
        distance[edge.to] = alt
        q.push(edge.to, alt)
      elsif alt < distance[edge.to]
        distance[edge.to] = alt
        q.change_priority(edge.to, alt)
      end
    end
  end
  distance
end

class Entry
  attr_reader :vertex, :weight
  def initialize(vertex, weight)
    @vertex = vertex
    @weight = weight
  end
end

def get_cost_rb_heap(q)
  distance = Array.new(@neighbourhood.size, Float::INFINITY)
  distance[1] = 0
  q.add(Entry.new(1, 0))
  until q.empty?
    entry = q.pop
    if entry.weight != distance[entry.vertex]
      next
    end
    el = entry.vertex
    @neighbourhood[el].each do |edge|
      alt = distance[el] + edge.weight
      if alt < distance[edge.to]
        distance[edge.to] = alt
        q.add(Entry.new(edge.to, alt))
      end
    end
  end
  distance
end

def get_cost_simple_pairing_heap(q)
  distance = Array.new(@neighbourhood.size, Float::INFINITY)
  distance[1] = 0
  q.push(1, 0)
  until q.empty?
    el, weight = q.pop_with_priority
    if weight != distance[el]
      next
    end
    @neighbourhood[el].each do |edge|
      alt = distance[el] + edge.weight
      if alt < distance[edge.to]
        distance[edge.to] = alt
        q.push(edge.to, alt)
      end
    end
  end
  distance
end

Benchmark.ips do |bm|
  bm.time = 60
  bm.warmup = 15

  bm.report("SimplePairingHeap") do
    get_cost_simple_pairing_heap(PairingHeap::SimplePairingHeap.new)
  end

  bm.report("Fibonacci") do
    get_costs(RubyPriorityQueue.new)
  end

  bm.report("lazy_priority_queue") do
    get_costs(MinPriorityQueue.new)
  end

  bm.report("rb_heap") do
    get_cost_rb_heap(Heap.new { |a, b| a.weight < b.weight })
  end

  bm.report("PairingHeap") do
    get_costs(PairingHeap::MinPriorityQueue.new)
  end

  bm.compare!
end
