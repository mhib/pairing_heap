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
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
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
    <td>62.000755</td>
    <td>0.420</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>17</td>
    <td>61.767914</td>
    <td>0.276(1.52x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>17</td>
    <td>62.531495s</td>
    <td>0.272(1.54x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>10</td>
    <td>66.576596</td>
    <td>0.150(2.79x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>6</td>
    <td>61.606882</td>
    <td>0.091(4.31x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>42</td>
    <td>61.170369</td>
    <td>0.687</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>30</td>
    <td>61.266231</td>
    <td>0.490(1.07x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>25</td>
    <td>61.409506</td>
    <td>0.407(1.69x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>12</td>
    <td>61.560478</td>
    <td>0.195(3.53x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>11</td>
    <td>64.966138</td>
    <td>0.169(4.06x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>42</td>
    <td>60.349060</td>
    <td>0.696</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>32</td>
    <td>60.281040</td>
    <td>0.515(1.35x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>29</td>
    <td>61.276515</td>
    <td>0.474(1.47x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>21</td>
    <td>61.679564</td>
    <td>0.341(2.04x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>21</td>
    <td>62.166960</td>
    <td>0.338(2.06x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>190</td>
    <td>60.150795</td>
    <td>3.181</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>103</td>
    <td>60.395842</td>
    <td>1.707(1.86x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>100</td>
    <td>60.121239</td>
    <td>1.681(1.89x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>20</td>
    <td>62.125953</td>
    <td>0.322(9.87x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>60.682738</td>
    <td>0.132(24.05x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 1000) [source code](./test/performance_with_change_priority.rb)
A stress test of 1,501,500 operations: starting with 1,000 pushes/1000 change_priorities/0 pops, following 999 pushes/999 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
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
    <td>61.049572</td>
    <td>0.246</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>63.753290</td>
    <td>0.141(1.74x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>6</td>
    <td>63.178331</td>
    <td>0.095(2.59x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>23</td>
    <td>62.450014</td>
    <td>0.369</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>11</td>
    <td>61.411572</td>
    <td>0.179(2.06x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>65.088674</td>
    <td>0.138(2.67x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>28</td>
    <td>61.567608</td>
    <td>0.456</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>20</td>
    <td>62.937410</td>
    <td>0.318(1.43x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>19</td>
    <td>61.462856</td>
    <td>0.309(1.47x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>90</td>
    <td>60.338872</td>
    <td>1.505</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>24</td>
    <td>60.910311</td>
    <td>0.395(3.81x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>65.172894</td>
    <td>0.138(10.88x slower)</td>
  </tr>
</table>

### Stress test with changing priority or push/pop(test ignored in summary) [source code](./test/performance_pop_versus_change_priority.rb)
Start with 500 pushes, then:
  * If queue supports changing priority 500 change_priority calls, then 500 pops
  * If does not support changing priority 500 push calls, then 1000 pops
<table>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>734.65</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>386.161(1.90x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>331.9(2.21x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>245.3(2.99x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>224.8(3.27x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1295.8</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>639.3(2.03x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>543.2(2.39x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>432(3x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>407.4(3.18x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap(PairingHeap)</td>
    <td>1469</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>966(1.52x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>907(1.62x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>639(2.30x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>504(2.91x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap(PairingHeap)</td>
    <td>13943</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>8213(1.70x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>2341(5.95x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1572(8.87x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1012(13.78x slower)</td>
  </tr>
</table>

### Dijkstra's algorithm with RGL [source code](./test/performance_rgl.rb)
<table>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>10</td>
    <td>60.694556</td>
    <td>0.165</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>63.397416</td>
    <td>0.142(1.16x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>7</td>
    <td>67.456340</td>
    <td>0.104(1.59x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>12</td>
    <td>61.717338</td>
    <td>0.195</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>11</td>
    <td>65.780856</td>
    <td>0.167(1.16x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>64.968622</td>
    <td>0.139(1.40x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>20</td>
    <td>62.414285</td>
    <td>0.321</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>19</td>
    <td>60.904401</td>
    <td>0.313(1.03x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>18</td>
    <td>62.869887</td>
    <td>0.287(1.12x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>36</td>
    <td>60.620255</td>
    <td>0.599</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>26</td>
    <td>62.000357</td>
    <td>0.422(1.42x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>24</td>
    <td>62.438081</td>
    <td>0.520(1.52x slower)</td>
  </tr>
</table>

### Simple Dijkstra's algorithm implementation [source code](./test/performance_dijkstra.rb)
Heaps that support change_priority operation use it. Heaps that do not support it use dijkstra implementation that do not rely on change_priority instead and do additional pops and pushes instead(see Dijkstra-NoDec from [Priority Queues and Dijkstra’s Algorithm](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf)).
<table>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>38</td>
    <td>60.115729</td>
    <td>0.633</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>32</td>
    <td>60.990854</td>
    <td>0.525(1.20x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>30</td>
    <td>60.288193</td>
    <td>0.498(1.27x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>22</td>
    <td>60.345144</td>
    <td>0.365(1.74x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>13</td>
    <td>64.820842</td>
    <td>0.201(3.16x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>52</td>
    <td>60.764238</td>
    <td>0.856</td>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>49</td>
    <td>60.242233</td>
    <td>0.818(1.05x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>47</td>
    <td>60.176639</td>
    <td>0.784(1.09x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>30</td>
    <td>61.919103</td>
    <td>0.485(1.76x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>18</td>
    <td>61.946877</td>
    <td>0.291(2.95x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>68</td>
    <td>60.677947</td>
    <td>1.123</td>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>64</td>
    <td>60.885495</td>
    <td>1.066(1.05x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>64</td>
    <td>60.928350</td>
    <td>1.053(1.07x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>51</td>
    <td>60.930898</td>
    <td>0.840(1.34x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>48</td>
    <td>60.625907</td>
    <td>0.793(1.42x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>282</td>
    <td>60.154056</td>
    <td>4.748</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>230</td>
    <td>60.070466</td>
    <td>3.855(1.23x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>214</td>
    <td>60.073212</td>
    <td>3.594(1.32x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>68</td>
    <td>60.586191</td>
    <td>1.131(4.20x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>48</td>
    <td>60.991714</td>
    <td>0.788(6.03x slower)</td>
  </tr>
</table>

### Summary
#### Change priority required
<table>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
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
    <td>1.52x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2.38x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
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
    <td>2.493x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2.218x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
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
    <td>1.274x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.295x slower</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
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
    <td>3.428x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>5.175x slower</td>
  </tr>
</table>

#### Change priority not required
<table>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin22]</th>
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
    <td>1.35x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.4x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.2x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>3.69x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.2.2 (2023-03-30 revision e51014f9c0) +YJIT [x86_64-darwin22]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>1.025x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.034x slower</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.357x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.492x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>3.46x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.4.2.0 (3.1.0) 2023-03-08 90d2913fda OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>1.024x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.162x slower</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.254x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.661x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.702x slower</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.3.1, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
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
    <td>1.525x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.567x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>7.715x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10.05x slower</td>
  </tr>
</table>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhib/pairing_heap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
