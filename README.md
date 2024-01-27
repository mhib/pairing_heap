# PairingHeap
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

PairingHeap is a pure Ruby priority queue implementation using a pairing heap as the underlying data structure. While a pairing heap is asymptotically less efficient than the Fibonacci heap, it is usually faster in practice. This makes it a popular choice for Prim's MST or Dijkstra's algorithm implementations.

PairingHeap is currently being used as the priority queue data structure in [RGL](https://github.com/monora/rgl/).

Also implementation without priority change support is provided(`SimplePairingHeap`), while the asymptotical complexity of the methods stay the same, bookkeeping of elements is not needed making, the constant smaller.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pairing_heap'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pairing_heap


## Documentation
https://rubydoc.info/gems/pairing_heap

## Usage
```ruby
require 'pairing_heap'

# Simple PairingHeap
simple_heap = PairingHeap::SimplePairingHeap.new
simple_heap.push(:a, 1)
simple_heap.push(:b, 2)
simple_heap.push(:c, 3)
simple_heap.peek # => :a
simple_heap.peek_priority # => 1
simple_heap.pop_with_priority # => [:a, 1]
simple_heap.pop # => :b

# Min priority queue
best_defenses = PairingHeap::MinPriorityQueue.new
best_defenses.push('Chelsea', 24)
best_defenses.push('City', 30)
best_defenses.push('Tottenham', 25)
best_defenses.any? # => true
best_defenses.size # => 3
best_defenses.decrease_key('City', 15)
best_defenses.min # => 'City'
best_defenses.pop # => 'City'
best_defenses.extract_min # => 'Chelsea'
best_defenses.extract_min # => 'Tottenham'
best_defenses.any? # => false

# Max priority queue
best_teams = PairingHeap::MaxPriorityQueue.new
best_teams.push('City', 56)
best_teams.push('United', 46)
best_teams.push('Leicester', 46)
best_teams.increase_key('Leicester', 47)
best_teams.max # => 'City'
best_teams.pop # => 'City'
best_teams.extract_max # => 'Leicester'

# Custom comparator(it defaults to :<=.to_proc)
compare_by_length = PairingHeap::PairingHeap.new { |l, r| l.length <= r.length }
compare_by_length.push(:a, '11')
compare_by_length.push(:b, '1')
compare_by_length.push(:c, '11')
compare_by_length.change_priority(:c, '')
compare_by_length.peek # => :c
compare_by_length.pop # => :c
compare_by_length.pop # => :b
compare_by_length.pop # => :a

# SafeChangePriortyQueue
queue = PairingHeap::SafeChangePriorityQueue.new
queue.push(:a, 1)
queue.push(:b, 2)
queue.change_priority(:a, 3) # This works and does not throw an exception
queue.peek # => :b
```
See also [test/performance_dijkstra.rb](./test/performance_dijkstra.rb) for a Dijkstra algorithm implementation.
### Changes from lazy_priority_queue
This API is a drop-in replacement of [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue) with the following differences:

* Custom comparator provided to constructur, compares weights, not internal nodes
* `change_priority` returns `self` instead of the first argument
* `enqueue` returns `self` instead of the first argument
* Queue classes are in the `PairingHeap` namespace, so `require 'pairing_heap` does not load `MinPriorityQueue` to the global scope
* `top_condition` constructor argument is removed

## Time Complexity
| Operation         | Time complexity | Amortized time complexity |
| ---------------   | --------------- | ------------------------- |
| enqueue           | O(1)            | O(1)                      |
| peek              | O(1)            | O(1)                      |
| dequeue           | O(n)            | O(log n)                  |
| * change_priority | O(1)            | o(log n)                  |
| * delete          | O(n)            | O(log n)                  |

`*` Not available in `SimplePairingHeap`

## Benchmarks
I picked the three fastest pure Ruby priority queue implementations I was aware of for the comparison:

* [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue) that uses a lazy binomial heap. This is probably the most popular option. It was used in [RGL](https://github.com/monora/rgl/) until PairingHeap replaced it.
* Pure Ruby implementation of Fibonacci Heap from [priority-queue](https://github.com/supertinou/priority-queue) ([link to source](https://github.com/supertinou/priority-queue/blob/master/lib/priority_queue/ruby_priority_queue.rb))
* [rb_heap](https://github.com/florian/rb_heap) that uses a binary heap. Note however that this implementation does not support change_priority operation.

All tests except for the third one were executed by [benchmark-ips](https://github.com/evanphx/benchmark-ips) with parameters `time = 60` and `warmup = 15`, on an `Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz`.
### Stress test without changing priority test(N = 1000) [source code](./test/performance.rb)
Original performance test from [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue)
> A stress test of 1,000,000 operations: starting with 1,000 pushes/0 pops, following 999 pushes/1 pop, and so on till 0 pushes/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>26</td>
    <td>62.249427</td>
    <td>0.419</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>17</td>
    <td>61.624806</td>
    <td>0.276(1.52x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>16</td>
    <td>63.656502</td>
    <td>0.251(1.67x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>7</td>
    <td>63.339192</td>
    <td>0.111(3.79x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>5</td>
    <td>69.010737</td>
    <td>0.073(5.77x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) +YJIT [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>39</td>
    <td>60.725689</td>
    <td>0.642</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>31</td>
    <td>60.370348</td>
    <td>0.514(1.25x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>25</td>
    <td>62.269577</td>
    <td>0.402(1.6x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>62.144710</td>
    <td>0.145(4.43x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>65.064385</td>
    <td>0.123(5.22x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.5.0 (3.1.4) 2023-11-02 1abae2700f OpenJDK 64-Bit Server VM 21+35-2513 on 21+35-2513 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>43</td>
    <td>60.734661</td>
    <td>0.709</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>34</td>
    <td>61.677228</td>
    <td>0.552(1.28x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>28</td>
    <td>61.284382</td>
    <td>0.458(1.55x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>22</td>
    <td>61.396897</td>
    <td>0.359(1.97x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>20</td>
    <td>61.841463</td>
    <td>0.324(2.19x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 23.1.2, like ruby 3.2.2, Oracle GraalVM JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>202</td>
    <td>60.225639</td>
    <td>3.388</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>140</td>
    <td>60.190881</td>
    <td>2.357(1.44x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>100</td>
    <td>60.373610</td>
    <td>1.692(2x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>31</td>
    <td>61.179244</td>
    <td>0.510(6.65x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>11</td>
    <td>64.413419</td>
    <td>0.171(19.81x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 1000) [source code](./test/performance_with_change_priority.rb)
A stress test of 1,501,500 operations: starting with 1,000 pushes/1000 change_priorities/0 pops, following 999 pushes/999 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>15</td>
    <td>60.817878</td>
    <td>0.247</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>7</td>
    <td>63.990376s</td>
    <td>0.109(2.26x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>5</td>
    <td>70.148980s</td>
    <td>0.071(3.47x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) +YJIT [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>22</td>
    <td>62.429264</td>
    <td>0.353</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>63.464818</td>
    <td>0.142(2.49x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>67.908812</td>
    <td>0.118(2.99x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.5.0 (3.1.4) 2023-11-02 1abae2700f OpenJDK 64-Bit Server VM 21+35-2513 on 21+35-2513 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>27</td>
    <td>61.709517</td>
    <td>0.438</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>20</td>
    <td>61.495636</td>
    <td>0.326(1.34x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>19</td>
    <td>63.401601</td>
    <td>0.309(1.46x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 23.1.2, like ruby 3.2.2, Oracle GraalVM JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>93</td>
    <td>60.125750</td>
    <td>1.577</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>26</td>
    <td>62.372660s</td>
    <td>0.419(3.77x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>11</td>
    <td>62.620172s</td>
    <td>0.177(8.92x slower)</td>
  </tr>
</table>

### Stress test with changing priority or push/pop(test ignored in summary) [source code](./test/performance_pop_versus_change_priority.rb)
Start with 500 pushes, then:
  * If queue supports changing priority 500 change_priority calls, then 500 pops
  * If does not support changing priority 500 push calls, then 1000 pops
<table>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>748.9</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>388.6(1.93x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>336.2(2.23x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>225.9(3.31x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>215.2(3.48x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) +YJIT [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1276</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>625.6(2.04x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>533.36(2.39x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>495.519(2.57x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>453.323(2.81x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.5.0 (3.1.4) 2023-11-02 1abae2700f OpenJDK 64-Bit Server VM 21+35-2513 on 21+35-2513 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap(PairingHeap)</td>
    <td>1377</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1088(1.27x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>953.935(1.44x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>621.35(2.22x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>595.11(2.31x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 23.1.2, like ruby 3.2.2, Oracle GraalVM JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap(PairingHeap)</td>
    <td>12712</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>9447(1.35x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>4009(3.17x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2793(4.55x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1188(10.7x slower)</td>
  </tr>
</table>

### Simple Dijkstra's algorithm implementation [source code](./test/performance_dijkstra.rb)
Heaps that support change_priority operation use it. Heaps that do not support it use dijkstra implementation that do not rely on change_priority instead and do additional pops and pushes instead(see Dijkstra-NoDec from [Priority Queues and Dijkstra’s Algorithm](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf)).
<table>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>41</td>
    <td>60.100316</td>
    <td>0.682</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>38</td>
    <td>61.003607</td>
    <td>0.623(1.09x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>30</td>
    <td>61.486216</td>
    <td>0.488(1.40x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>23</td>
    <td>60.251764</td>
    <td>0.382(1.79x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>13</td>
    <td>61.158622</td>
    <td>0.213(3.21x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) +YJIT [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>65</td>
    <td>60.805882</td>
    <td>1.070</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>60</td>
    <td>60.790842</td>
    <td>0.987(1.08x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>54</td>
    <td>60.917679</td>
    <td>0.887(1.21x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>30</td>
    <td>60.712786</td>
    <td>0.495(2.16x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>24</td>
    <td>61.900715</td>
    <td>0.388(2.76x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.5.0 (3.1.4) 2023-11-02 1abae2700f OpenJDK 64-Bit Server VM 21+35-2513 on 21+35-2513 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>70</td>
    <td>60.077928</td>
    <td>1.168</td>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>66</td>
    <td>60.420935</td>
    <td>1.094(1.07x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>64</td>
    <td>60.114467</td>
    <td>1.066(1.1x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>54</td>
    <td>60.426971</td>
    <td>0.898(1.30x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>49</td>
    <td>60.636963</td>
    <td>0.809(1.44x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 23.1.2, like ruby 3.2.2, Oracle GraalVM JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>288</td>
    <td>60.102278</td>
    <td>4.936</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>232</td>
    <td>60.159057</td>
    <td>3.936(1.25x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>227</td>
    <td>60.082482</td>
    <td>3.881(1.27x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>101</td>
    <td>60.076691</td>
    <td>1.721(2.87x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>66</td>
    <td>60.771569</td>
    <td>1.1(4.49x slower)</td>
  </tr>
</table>

### Summary
#### Change priority required
<table>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.1x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>3.38x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) +YJIT [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.55x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2.74x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.5.0 (3.1.4) 2023-11-02 1abae2700f OpenJDK 64-Bit Server VM 21+35-2513 on 21+35-2513 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.267x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.396x slower</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 23.1.2, like ruby 3.2.2, Oracle GraalVM JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>3.54x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>5.86x slower</td>
  </tr>
</table>

#### Change priority not required
<table>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>1</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.29x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.53x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.6x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>4.29x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.3.0 (2023-12-25 revision 5124f9ac75) +YJIT [x86_64-darwin23]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>1</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.227x slower</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.316x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>3.094x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>3.79x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.5.0 (3.1.4) 2023-11-02 1abae2700f OpenJDK 64-Bit Server VM 21+35-2513 on 21+35-2513 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>1.033x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.133x slower</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.302x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.602x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.777x slower</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 23.1.2, like ruby 3.2.2, Oracle GraalVM JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>1</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.35x slower</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.58x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>5.46x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>7.54x slower</td>
  </tr>
</table>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhib/pairing_heap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
