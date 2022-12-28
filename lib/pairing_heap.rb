# frozen_string_literal: true

module PairingHeap
  module MergePairs
    # Non-recursive implementation of method described in https://en.wikipedia.org/wiki/Pairing_heap#delete-min
    def merge_pairs(heaps)
      return nil if heaps.nil?
      return heaps if heaps.next_sibling.nil?

      # [H1, H2, H3, H4, H5, H6, H7] => [H1H2, H3H4, H5H6, H7]
      pairs = nil
      left = heaps
      while left
        right = left.next_sibling
        unless right
          left.next_sibling = pairs
          pairs = left
          break
        end
        next_val = right.next_sibling
        right = meld(left, right)
        right.next_sibling = pairs
        pairs = right

        left = next_val
      end

      # [H1H2, H3H4, H5H6, H7]
      # [H1H2, H3H4, H5H67]
      # [H1H2, H3H45H67]
      # [H1H2H3H45H67]
      # return H1H2H3H45H67
      left = pairs
      right = pairs.next_sibling
      while right
        next_val = right.next_sibling
        left = meld(left, right)
        right = next_val
      end
      left
    end
  end
  private_constant :MergePairs

  # Pairing heap data structure implementation
  # @see https://en.wikipedia.org/wiki/Pairing_heap
  class PairingHeap
    class Node
      attr_accessor :elem, :priority, :subheaps, :parent, :prev_sibling, :next_sibling
      def initialize(elem, priority)
        @elem = elem
        @priority = priority
        @subheaps = nil
        @parent = nil
        @prev_sibling = nil
        @next_sibling = nil
      end

      def remove_from_parents_list!
        if self.prev_sibling
          self.prev_sibling.next_sibling = self.next_sibling
          self.next_sibling.prev_sibling = self.prev_sibling if self.next_sibling
        elsif self.parent.subheaps.equal?(self)
          self.parent.subheaps = self.next_sibling
          self.next_sibling.prev_sibling = nil if self.next_sibling
        end
        self.prev_sibling = nil
        self.next_sibling = nil
      end
    end
    private_constant :Node

    # @param &block Optional heap property priority comparator. `<:=.to_proc` by default
    def initialize(&block)
      @root = nil
      @nodes = {}
      @order = block || :<=.to_proc
    end

    # Pushes element to the heap.
    #   Time Complexity: O(1)
    # @param elem Element to be pushed
    # @param priority Priority of the element
    # @raise [ArgumentError] if the element is already in the heap
    # @return [PairingHeap]
    def push(elem, priority)
      raise ArgumentError, "Element already in the heap" if @nodes.key?(elem)

      node = Node.new(elem, priority)
      @nodes[elem] = node
      if @root
        @root = meld(@root, node)
      else
        @root = node
      end
      self
    end
    alias enqueue push
    alias offer push

    # Returns the element at the top of the heap
    #   Time Complexity: O(1)
    def peek
      @root&.elem
    end

    def peek_priority
      @root&.priority
    end

    def peek_with_priority
      [@root&.elem, @root&.priority]
    end

    # Time Complexity: O(1)
    # @return [Boolean]
    def empty?
      @root.nil?
    end

    # Time Complexity: O(1)
    # @return [Boolean]
    def any?
      !@root.nil?
    end

    # Time Complexity: O(1)
    # @return [Integer]
    def size
      @nodes.size
    end
    alias length size

    # Removes element from the top of the heap and returns it
    #   Time Complexity: O(N)
    #   Amortized time Complexity: O(log(N))
    # @raise [ArgumentError] if the heap is empty
    def pop
      raise ArgumentError, "Cannot remove from an empty heap" if @root.nil?

      elem = @root.elem
      @nodes.delete(elem)
      @root = merge_pairs(@root.subheaps)
      if @root
        @root.parent = nil
        @root.next_sibling = nil
        @root.prev_sibling = nil
      end
      elem
    end
    alias dequeue pop

    # @return [Object]
    def pop_priority
      node = @root
      pop
      node.priority
    end

    # @return [Array(Object, Object)]
    def pop_with_priority
      node = @root
      pop
      [node.elem, node.priority]
    end

    # Changes a priority of element to a more prioritary one
    #   Time Complexity: O(1)
    #   Amortized Time Complexity: o(log(N))
    # @param elem Element
    # @param priority New priority
    # @raise [ArgumentError] if the element is not in the heap or the new priority is less prioritary
    # @return [PairingHeap]
    def change_priority(elem, priority)
      node = @nodes[elem]
      raise ArgumentError, "Provided element is not in heap" if node.nil?
      unless @order[priority, node.priority]
        raise ArgumentError, "Priority cannot be changed to a less prioritary value."
      end

      node.priority = priority
      return if node.parent.nil?
      return if @order[node.parent.priority, node.priority]

      node.remove_from_parents_list!
      @root = meld(node, @root)
      @root.parent = nil
      self
    end

    # Removes element from the heap
    #   Time Complexity: O(N)
    #   Amortized Time Complexity: O(log(N))
    # @raise [ArgumentError] if the element is not in the heap
    # @return [PairingHeap]
    def delete(elem)
      node = @nodes[elem]
      raise ArgumentError, "Provided element is not in heap" if node.nil?

      @nodes.delete(elem)
      if node.parent.nil?
        @root = merge_pairs(node.subheaps)
        if @root
          @root.parent = nil
          @root.prev_sibling = nil
          @root.next_sibling = nil
        end
      else
        node.remove_from_parents_list!
        new_heap = merge_pairs(node.subheaps)
        if new_heap
          @root = meld(new_heap, @root)
          @root.parent = nil
          @root.prev_sibling = nil
          @root.next_sibling = nil
        end
      end
      self
    end

    # Returns priority of the provided element
    #   Time Complexity: O(1)
    # @raise [ArgumentError] if the element is not in the heap
    def get_priority(elem)
      node = @nodes[elem]
      raise ArgumentError, "Provided element is not in heap" if node.nil?
      node.priority
    end

    # Returns enumerator of elements. No order guarantees are provided.
    # @return [Enumerator]
    def each
      return to_enum(__method__) { size } unless block_given?
      NodeVisitor::visit_node(@root) { |x| yield x.elem }
    end

    private
    include MergePairs

    def meld(left, right)
      if @order[left.priority, right.priority]
        parent = left
        child = right
      else
        parent = right
        child = left
      end
      child.next_sibling = parent.subheaps
      parent.subheaps = child
      child.next_sibling.prev_sibling = child if child.next_sibling
      child.prev_sibling = nil
      child.parent = parent
      parent
    end
  end

  class SimplePairingHeap
    class Node
      attr_accessor :elem, :priority, :subheaps, :next_sibling
      def initialize(elem, priority)
        @elem = elem
        @priority = priority
        @subheaps = nil
        @next_sibling = nil
      end
    end
    private_constant :Node

    # @param &block Optional heap property priority comparator. `<:=.to_proc` by default
    def initialize(&block)
      @root = nil
      @order = block || :<=.to_proc
      @size = 0
    end

    # Pushes element to the heap.
    #   Time Complexity: O(1)
    # @param elem Element to be pushed
    # @param priority Priority of the element
    # @return [PairingHeap]
    def push(elem, priority)
      node = Node.new(elem, priority)
      if @root
        @root = meld(@root, node)
      else
        @root = node
      end
      @size += 1
      self
    end
    alias enqueue push
    alias offer push

    # Returns the element at the top of the heap
    #   Time Complexity: O(1)
    def peek
      @root&.elem
    end

    def peek_priority
      @root&.priority
    end

    def peek_with_priority
      [@root&.elem, @root&.priority]
    end

    # Time Complexity: O(1)
    # @return [Boolean]
    def empty?
      @root.nil?
    end

    # Time Complexity: O(1)
    # @return [Boolean]
    def any?
      !@root.nil?
    end

    # Time Complexity: O(1)
    # @return [Integer]
    def size
      @size
    end
    alias length size

    # Removes element from the top of the heap and returns it
    #   Time Complexity: O(N)
    #   Amortized time Complexity: O(log(N))
    # @raise [ArgumEntError] if the heap is empty
    def pop
      raise ArgumentError, "Cannot remove from an empty heap" if @root.nil?
      @size -= 1

      elem = @root.elem
      @root = merge_pairs(@root.subheaps)
      @root&.next_sibling = nil

      elem
    end
    alias dequeue pop

    # @return [Object]
    def pop_priority
      node = @root
      pop
      node.priority
    end

    # @return [Array(Object, Object)]
    def pop_with_priority
      node = @root
      pop
      [node.elem, node.priority]
    end

    # Returns enumerator of elements. No order guarantees are provided.
    # @return [Enumerator]
    def each
      return to_enum(__method__) { size } unless block_given?
      NodeVisitor::visit_node(@root) { |x| yield x.elem }
    end

    private
    include MergePairs

    def meld(left, right)
      if @order[left.priority, right.priority]
        parent = left
        child = right
      else
        parent = right
        child = left
      end
      child.next_sibling = parent.subheaps
      parent.subheaps = child
      parent
    end
  end


  # Priority queue where the smallest priority is the most prioritary
  class MinPriorityQueue < PairingHeap
    def initialize
      super(&:<=)
    end

    alias decrease_key change_priority
    alias min peek
    alias extract_min dequeue
  end

  # Priority queue where the highest priority is the most prioritary
  class MaxPriorityQueue < PairingHeap
    def initialize
      super(&:>=)
    end

    alias increase_key change_priority
    alias max peek
    alias extract_max dequeue
  end

  # Priority queue with change_priority, that accepts changing to a less prioritary priority
  class SafeChangePriorityQueue < PairingHeap
    # Changes a priority of the element to a more prioritary one
    #   Time Complexity: O(N)
    #   Amortized Time Complexity: O(log(N))
    # @raise [ArgumentError] if the element is not in the heap
    # @return [PairingHeap]
    def change_priority(elem, priority)
      raise ArgumentError, "Provided element is not in heap" unless @nodes.key?(elem)
      if !@order[priority, @nodes[elem].priority]
        delete(elem)
        push(elem, priority)
      else
        super(elem, priority)
      end
    end
  end

  module NodeVisitor
    extend self

    def visit_node(node, &block)
      return unless node

      block.call(node)

      if node.subheaps
        visit_node(node.subheaps, &block)
      end
      if node.next_sibling
        visit_node(node.next_sibling, &block)
      end
    end
  end
  private_constant :NodeVisitor
end
