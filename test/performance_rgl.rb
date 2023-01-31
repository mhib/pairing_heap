# frozen_string_literal: true

require "rgl/dijkstra"
require "rgl/adjacency"
require_relative "../lib/pairing_heap"
require "csv"
require "benchmark/ips"
require_relative "fib"
require "lazy_priority_queue"

@graph = RGL::AdjacencyGraph[]
@edge_weights = {}

# https://gist.githubusercontent.com/mhib/ed03bb9eb67ae871fa6f199f024379c7/raw/4acd08372b3ffec2de1982449b2a4ee9fbaa48cd/Tokyo_Edgelist.csv
CSV.foreach("Tokyo_Edgelist.csv", headers: true) do |row|
  @graph.add_edge(row["START_NODE"].to_i, row["END_NODE"].to_i)
  @edge_weights[[row["START_NODE"].to_i, row["END_NODE"].to_i]] = row["LENGTH"].to_f
end

class PairingDijkstraAlgorithm < RGL::DijkstraAlgorithm
  def init(source)
    @visitor.set_source(source)

    @queue = PairingHeap::MinPriorityQueue.new
    @queue.push(source, 0)
  end
end

class LazyDijkstraAlgorithm < RGL::DijkstraAlgorithm
  def init(source)
    @visitor.set_source(source)

    @queue = MinPriorityQueue.new
    @queue.push(source, 0)
  end
end

class FibDijkstraAlgorithm < RGL::DijkstraAlgorithm
  def init(source)
    @visitor.set_source(source)

    @queue = RubyPriorityQueue.new
    @queue.push(source, 0)
  end
end

Benchmark.ips do |bm|
  bm.time = 60
  bm.warmup = 15

  bm.report("Fibonacci") do
    FibDijkstraAlgorithm.new(@graph, @edge_weights, RGL::DijkstraVisitor.new(@graph)).shortest_paths(1)
  end

  bm.report("pairing_heap") do
    PairingDijkstraAlgorithm.new(@graph, @edge_weights, RGL::DijkstraVisitor.new(@graph)).shortest_paths(1)
  end

  bm.report("lazy_priority_queue") do
    LazyDijkstraAlgorithm.new(@graph, @edge_weights, RGL::DijkstraVisitor.new(@graph)).shortest_paths(1)
  end

  bm.compare!
end
