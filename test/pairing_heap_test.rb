# frozen_string_literal: true

require "test_helper"

class Element
  attr_accessor :priority
  def initialize(priority)
    @priority = priority
  end
end

class CommonMethodsSpec < Module
  def initialize(klazz)
    @klazz = klazz
  end

  def included(ancestor)
    super
    klazz = @klazz
    ancestor.instance_eval do
      describe "common api" do
        before do
          @queue = klazz.new
        end

        describe "#each" do
          it "returns all elements" do
            1.upto(500) do |i|
              @queue.push(i)
            end
            @queue.pop
            _(@queue.each.to_set).must_equal(Set.new(2..500))
          end

          it "returns no elements when empty" do
            _(@queue.each.to_a).must_equal([])
          end
        end

        describe "#each_with_priority" do
          it "returns all elements" do
            1.upto(500) do |i|
              @queue.push(i)
            end
            @queue.pop
            _(@queue.each_with_priority.to_set).must_equal(Set.new((2..500).map { |x| [x, x] }))
          end

          it "returns no elements when empty" do
            _(@queue.each_with_priority.to_a).must_equal([])
          end
        end

        describe "#peek_with_priority" do
          it "returns tuple with priority" do
            @queue.push(1, 2)
            @queue.push(3, 4)
            _(@queue.peek_with_priority).must_equal([1, 2])
          end

          it "returns pair of nils when empty" do
            _(@queue.peek_with_priority).must_equal([nil, nil])
          end
        end

        describe "#peek_priority" do
          it "returns priority" do
            @queue.push(1, 2)
            @queue.push(3, 4)
            _(@queue.peek_priority).must_equal(2)
          end

          it "returns nil when empty" do
            _(@queue.peek_priority).must_be_nil
          end
        end

        describe "#pop_priority" do
          it "pops and returns priority" do
            @queue.push(1, 2)
            _(@queue.pop_priority).must_equal(2)
            _(@queue).must_be_empty
          end
        end

        describe "#pop_with_priority" do
          it "pops and returns priority" do
            @queue.push(1, 2)
            _(@queue.pop_with_priority).must_equal([1, 2])
            _(@queue).must_be_empty
          end
        end

        describe "#pop" do
          it "returns nil if the heap is empty" do
            _(@queue).must_be_empty
            _(@queue.pop).must_be_nil
          end
        end

        describe "#push" do
          it "works with a single argument" do
            @queue.push(2)
            _(@queue.peek_with_priority).must_equal([2, 2])
            @queue.push(1)
            _(@queue.peek_with_priority).must_equal([1, 1])
          end
        end

        describe "#any?" do
          it "is opposite of #empty?" do
            _(@queue.any?).must_equal(!@queue.empty?)
            @queue.push(1)
            _(@queue.any?).must_equal(!@queue.empty?)
          end
        end
      end
    end
  end
end

describe PairingHeap do
  describe PairingHeap::PairingHeap do
    include CommonMethodsSpec.new(PairingHeap::PairingHeap)

    it "works correctly with random usage" do
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

      _(sorted_items).must_equal(items.map(&:priority).sort)
    end

    it "does not crash with a large number of consecutive pushes" do
      queue = PairingHeap::PairingHeap.new
      1.upto(5_000_000) do |i|
        queue.push(i, i)
      end
      _(queue.pop).must_equal(1)
    end

    describe "#change_priority" do
      it "throws when trying to change priority to a less prioritary one" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 1)
        _(-> { queue.change_priority(1, 2) }).must_raise(ArgumentError)
      end

      it "throws when trying to change priority of element that does not exist" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 1)
        _(-> { queue.change_priority(3, 2) }).must_raise(ArgumentError)
      end
    end

    describe "#push" do
      it "throws when pushing already existing element" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 1)
        _(-> { queue.push(1, 2) }).must_raise(ArgumentError)
      end
    end

    describe "#delete" do
      it "works correctly when deleting last element" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        queue.delete(1)

        _(queue).must_be_empty
      end

      it "throws when element does not exist in heap" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(-> { queue.delete(2) }).must_raise(ArgumentError)
      end
    end

    describe "#get_priority" do
      it "works correctly when deleting last element" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(queue.get_priority(1)).must_equal(2)
      end

      it "returns nil when element does not exist in heap" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(queue.get_priority(2)).must_be_nil
      end
    end

    describe "#get_priority_if_exists" do
      it "works correctly when deleting last element" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(queue.get_priority_if_exists(1)).must_equal([true, 2])
      end

      it "throws when element does not exist in heap" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(queue.get_priority_if_exists(2)).must_equal([false, nil])
      end
    end

    describe "#include?" do
      it "returns true when element is in the heap" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(queue.include?(1)).must_equal(true)
      end

      it "returns false when element is in the heap" do
        queue = PairingHeap::PairingHeap.new
        queue.push(1, 2)
        _(queue.include?(3)).must_equal(false)
      end
    end
  end

  describe PairingHeap::SimplePairingHeap do
    include CommonMethodsSpec.new(PairingHeap::SimplePairingHeap)

    it "works correctly with random usage" do
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

      _(sorted_items).must_equal(items.map(&:priority).sort)
    end

    it "does not crash with a large number of consecutive pushes" do
      queue = PairingHeap::SimplePairingHeap.new
      1.upto(5_000_000) do |i|
        queue.push(i, i)
      end
      _(queue.pop).must_equal(1)
    end

    describe "#merge" do
      it "merges 2 heaps correctly" do
        first = PairingHeap::SimplePairingHeap.new
        2.step(10, 2).to_a.shuffle.each { |x| first.push(x) }
        second = PairingHeap::SimplePairingHeap.new
        1.step(9, 2).to_a.shuffle.each { |x| second.push(x) }

        first.merge(second)
        _(second.size).must_equal(0)
        _(second.peek).must_be_nil
        _(first.size).must_equal(10)

        sorted = []
        sorted << first.pop until first.empty?

        _(sorted).must_equal((1..10).to_a)
      end

      it "throws argument error if trying to merge with itself" do
        queue = PairingHeap::SimplePairingHeap.new
        queue.push(3)

        _(-> { queue.merge(queue) }).must_raise(ArgumentError)
      end

      it "works correctly if the called heap is empty" do
        first = PairingHeap::SimplePairingHeap.new
        second = PairingHeap::SimplePairingHeap.new
        (1..5).to_a.shuffle.each { |x| second.push(x) }

        first.merge(second)
        _(second.size).must_equal(0)
        _(second.peek).must_be_nil
        _(first.size).must_equal(5)

        sorted = []
        sorted << first.pop until first.empty?

        _(sorted).must_equal((1..5).to_a)
      end

      it "works correctly if the provided heap is empty" do
        first = PairingHeap::SimplePairingHeap.new
        (1..5).to_a.shuffle.each { |x| first.push(x) }
        second = PairingHeap::SimplePairingHeap.new

        first.merge(second)
        _(second.size).must_equal(0)
        _(second.peek).must_be_nil
        _(first.size).must_equal(5)

        sorted = []
        sorted << first.pop until first.empty?

        _(sorted).must_equal((1..5).to_a)
      end

      it "handles many merge operations" do
        heaps = (0..100).to_a.shuffle.map do |e|
          PairingHeap::SimplePairingHeap.new.push(e)
        end

        while heaps.size > 1
          first_idx = rand(0...heaps.size)
          heaps[-1], heaps[first_idx] = heaps[first_idx], heaps[-1]
          first = heaps.pop
          second_idx = rand(0...heaps.size)
          heaps[-1], heaps[second_idx] = heaps[second_idx], heaps[-1]
          second = heaps.pop

          heaps << first.merge(second)
        end

        res = heaps[0]

        _(res.size).must_equal(101)

        sorted = []
        sorted << res.pop until res.empty?

        _(sorted).must_equal((0..100).to_a)
      end
    end
  end

  describe PairingHeap::MinPriorityQueue do
    it "sorts correctly" do
      queue = PairingHeap::MinPriorityQueue.new
      array = (1..10).to_a
      array.each { |i| queue.push(i, i) }
      result = []
      result << queue.pop while queue.any?
      _(result).must_equal(array)
    end
  end

  describe PairingHeap::MaxPriorityQueue do
    it "sorts correctly" do
      queue = PairingHeap::MaxPriorityQueue.new
      array = (1..10).to_a
      array.each { |i| queue.push(i, i) }
      result = []
      result << queue.pop while queue.any?
      _(result).must_equal(array.reverse)
    end
  end

  describe PairingHeap::SafeChangePriorityQueue do
    it "does not throw when trying to change priority to a less prioritary one" do
      queue = PairingHeap::SafeChangePriorityQueue.new(&:<=)
      queue.push(1, 1)
      queue.push(2, 2)
      _(-> { queue.change_priority(1, 3) }).must_be_silent
      _(queue.pop).must_equal(2)
      _(queue.pop).must_equal(1)
      queue.push(1, 1)
      queue.push(2, 2)
      _(-> { queue.change_priority(2, 0) }).must_be_silent
      _(queue.pop).must_equal(2)
      _(queue.pop).must_equal(1)
    end

    it "throws when element does not exist" do
      queue = PairingHeap::SafeChangePriorityQueue.new(&:<=)
      queue.push(1, 1)
      queue.push(2, 2)
      _(-> { queue.change_priority(4, 3) }).must_raise(ArgumentError)
    end
  end
end
