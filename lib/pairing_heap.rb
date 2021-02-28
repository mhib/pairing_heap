# frozen_string_literal: true

module PairingHeap
  # Pairing heap data structure implementation
  # @see https://en.wikipedia.org/wiki/Pairing_heap
  class PairingHeap
    class Node
      attr_accessor :elem, :priority, :subheaps, :parent, :prev_sibling, :next_sibling
      def initialize(elem, priority, subheaps, parent, prev_sibling, next_sibling)
        @elem = elem
        @priority = priority
        @subheaps = subheaps
        @parent = parent
        @prev_sibling = prev_sibling
        @next_sibling = next_sibling
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

      node = Node.new(elem, priority, nil, nil, nil, nil)
      @nodes[elem] = node
      @root = meld(@root, node)
      self
    end
    alias enqueue push

    # Returns the element at the top of the heap
    #   Time Complexity: O(1)
    def peek
      @root&.elem
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

    # Removes element from the top of the heap
    #   Time Complexity: O(N)
    #   Amortized time Complexity: O(log(N))
    # @raise [ArgumEntError] if the heap is empty
    # @return [PairingHeap]
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

    # Changes a priority of element to a more prioritary one
    #   Time Complexity: O(1)
    #   Amortized Time Complexity: o(log(N))
    # @param elem Element
    # @param priority New priority
    # @raise [ArgumentError] if the element heap is not in heap or the new priority is less prioritary
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

      remove_from_parents_list(node)
      @root = meld(node, @root)
      @root.parent = nil
      self
    end

    # Removes element from the top of the heap
    #   Time Complexity: O(N)
    #   Amortized Time Complexity: O(log(N))
    # @raise [ArgumentError] if the element heap is not in heap
    # @return [PairingHeap]
    def delete(elem)
      node = @nodes[elem]
      raise ArgumentError, "Provided element is not in heap" if node.nil?

      @nodes.delete(elem)
      if node.parent.nil?
        @root = merge_pairs(node.subheaps)
      else
        remove_from_parents_list(node)
        new_heap = merge_pairs(node.subheaps)
        if new_heap
          new_heap.prev_sibling = nil
          new_heap.next_sibling = nil
        end
        @root = meld(new_heap, @root)
      end
      @root&.parent = nil
      self
    end

    private

    def remove_from_parents_list(node)
      if node.prev_sibling
        node.prev_sibling.next_sibling = node.next_sibling
        node.next_sibling.prev_sibling = node.prev_sibling if node.next_sibling
      elsif node.parent.subheaps.equal?(node)
        node.parent.subheaps = node.next_sibling
        node.next_sibling.prev_sibling = nil if node.next_sibling
      end
      node.prev_sibling = nil
      node.next_sibling = nil
    end

    def meld(left, right)
      return right if left.nil?
      return left if right.nil?

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

    # Non-recursive implementation of method described in https://en.wikipedia.org/wiki/Pairing_heap#delete-min
    def merge_pairs(heaps)
      return nil if heaps.nil?
      return heaps if heaps.next_sibling.nil?

      # [H1, H2, H3, H4, H5, H6, H7] => [H1H2, H3H4, H5H6, H7]
      stack = []
      current = heaps
      while current
        prev = current
        current = current.next_sibling
        unless current
          stack << prev
          break
        end
        next_val = current.next_sibling
        stack << meld(prev, current)
        current = next_val
      end

      # [H1H2, H3H4, H5H6, H7]
      # [H1H2, H3H4, H5H67]
      # [H1H2, H3H45H67]
      # [H1H2H3H45H67]
      # return H1H2H3H45H67
      while true
        right = stack.pop
        return right if stack.empty?

        left = stack.pop
        stack << meld(left, right)
      end
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
    # @raise [ArgumentError] if the element heap is not in the heap
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
end
