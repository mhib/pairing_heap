# frozen_string_literal: true

require 'csv'
require 'benchmark/ips'
require_relative '../lib/pairing_heap'
require 'lazy_priority_queue'
require_relative 'fib'
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
  @neighbourhood.each_with_index do |value, vertex|
    next unless value

    q.push(vertex, distance[vertex])
  end
  until q.empty?
    el = q.pop
    @neighbourhood[el].each do |edge|
      alt = distance[el] + edge.weight
      if alt < distance[edge.to]
        distance[edge.to] = alt
        q.change_priority(edge.to, alt)
      end
    end
  end
  distance
end

Benchmark.ips do |bm|
  bm.time = 60
  bm.warmup = 15
  bm.report('pairing_heap') do
    get_costs(PairingHeap::MinPriorityQueue.new)
  end

  bm.report('Fibonacci') do
    get_costs(RubyPriorityQueue.new)
  end

  bm.report('lazy_priority_queue') do
    get_costs(MinPriorityQueue.new)
  end

  bm.compare!
end
