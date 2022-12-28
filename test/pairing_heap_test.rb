# frozen_string_literal: true

require 'test_helper'
require 'set'

describe PairingHeap do
  class Element
    attr_accessor :priority
    def initialize(priority)
      @priority = priority
    end
  end
  describe PairingHeap::PairingHeap do
    it 'works correctly with random usage' do
      queue = PairingHeap::PairingHeap.new

      items = []

      5_000.times do |id|
        _(queue.empty?).must_equal(items.empty?)
        _(-> { queue.peek }).must_be_silent
        _(queue.size).must_equal(items.size)

        if rand(2).zero?
          priority = rand(1000)
          item = Element.new(priority)
          queue.enqueue(item, item.priority)
          items << item
        end

        next if items.empty?

        if rand(2).zero?
          item = items.sample
          item.priority -= rand(1000)
          queue.change_priority(item, item.priority)
        end

        if rand(4).zero?
          items.delete(queue.dequeue)
        end

        if items.any? && rand(6).zero?
          sample = items.sample
          queue.delete(sample)
          items.delete(sample)
        end

      end

      sorted_items = []
      sorted_items << queue.pop until queue.empty?
      sorted_items.map!(&:priority)

      _(sorted_items).must_equal(sorted_items.sort)
    end

    it 'does not crash with a large number of consecutive pushes' do
      queue = PairingHeap::PairingHeap.new
      1.upto(5_000_000) do |i|
        queue.push(i, i)
      end
      _(queue.pop).must_equal(1)
    end

    it 'throws when trying to change priority to a less prioritary one' do
      queue = PairingHeap::PairingHeap.new
      queue.push(1, 1)
      _(-> { queue.change_priority(1, 2) }).must_raise(ArgumentError)
    end

    describe '#each' do
      it 'returns all elements' do
        queue = PairingHeap::PairingHeap.new
        1.upto(500) do |i|
          queue.push(i)
        end
        queue.pop
        _(queue.each.to_set).must_equal(Set.new(2..500))
      end
    end
  end

  describe PairingHeap::SimplePairingHeap do
    it 'works correctly with random usage' do
      queue = PairingHeap::SimplePairingHeap.new

      items = []

      5_000.times do |id|
        _(queue.empty?).must_equal(items.empty?)
        _(-> { queue.peek }).must_be_silent
        _(queue.size).must_equal(items.size)

        if rand(2).zero?
          priority = rand(1000)
          item = Element.new(priority)
          queue.enqueue(item, item.priority)
          items << item
        end

        next if items.empty?

        if rand(4).zero?
          items.delete(queue.dequeue)
        end

      end

      sorted_items = []
      sorted_items << queue.pop until queue.empty?
      sorted_items.map!(&:priority)

      _(sorted_items).must_equal(sorted_items.sort)
    end

    it 'does not crash with a large number of consecutive pushes' do
      queue = PairingHeap::SimplePairingHeap.new
      1.upto(5_000_000) do |i|
        queue.push(i, i)
      end
      _(queue.pop).must_equal(1)
    end

    describe '#each' do
      it 'returns all elements' do
        queue = PairingHeap::SimplePairingHeap.new
        1.upto(500) do |i|
          queue.push(i)
        end
        queue.pop
        _(queue.each.to_set).must_equal(Set.new(2..500))
      end
    end
  end


  describe PairingHeap::MinPriorityQueue do
    it 'sorts correctly' do
      queue = PairingHeap::MinPriorityQueue.new
      array = (1..10).to_a
      array.each { |i| queue.push(i, i) }
      result = []
      result << queue.pop while queue.any?
      _(result).must_equal(array)
    end
  end

  describe PairingHeap::MaxPriorityQueue do
    it 'sorts correctly' do
      queue = PairingHeap::MaxPriorityQueue.new
      array = (1..10).to_a
      array.each { |i| queue.push(i, i) }
      result = []
      result << queue.pop while queue.any?
      _(result).must_equal(array.reverse)
    end
  end

  describe PairingHeap::SafeChangePriorityQueue do
    it 'does not throw when trying to change priority to a less prioritary one' do
      queue = PairingHeap::SafeChangePriorityQueue.new(&:<=)
      queue.push(1, 1)
      queue.push(2, 2)
      _(-> { queue.change_priority(1, 3) }).must_be_silent
      _(queue.pop).must_equal(2)
      _(queue.pop).must_equal(1)
    end
  end
end
