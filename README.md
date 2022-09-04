# PairingHeap

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
simple_heap.peek_priority # => [:a, 1]
simple_heap.pop_priority # => [:a, 1]
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
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>23</td>
    <td>62.014773</td>
    <td>0.371</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>16</td>
    <td>63.135240</td>
    <td>0.253(1.46x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>14</td>
    <td>61.123304</td>
    <td>0.229(1.62x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>10</td>
    <td>66.208647</td>
    <td>0.151(2.46x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>66.353147</td>
    <td>0.121(3.08x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>25</td>
    <td>60.423579</td>
    <td>0.414</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>19</td>
    <td>60.869907</td>
    <td>0.312(1.33x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>17</td>
    <td>61.389127</td>
    <td>0.277(1.49x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>14</td>
    <td>64.417807</td>
    <td>0.217(1.90x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>11</td>
    <td>63.151856</td>
    <td>0.174(2.38x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>47</td>
    <td>60.391633</td>
    <td>0.778</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>34</td>
    <td>60.878639</td>
    <td>0.559(1.39x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>32</td>
    <td>61.211985</td>
    <td>0.523(1.49x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>23</td>
    <td>60.297670</td>
    <td>0.382(2.04x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>23</td>
    <td>61.973538</td>
    <td>0.371(2.10x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>206</td>
    <td>60.191686</td>
    <td>3.433</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>97</td>
    <td>60.134011</td>
    <td>1.614(1.93x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>85</td>
    <td>60.193608s</td>
    <td>1.434(2.40x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>19</td>
    <td>63.212429</td>
    <td>0.301(11.45x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2</td>
    <td>83.508571</td>
    <td>0.024(143.70x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 1000) [source code](./test/performance_with_change_priority.rb)
A stress test of 1,501,500 operations: starting with 1,000 pushes/1000 change_priorities/0 pops, following 999 pushes/999 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
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
    <td>62.946988</td>
    <td>0.238</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>61.876691</td>
    <td>0.145(1.64x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>67.809982</td>
    <td>0.118(2.02x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>16</td>
    <td>62.576693</td>
    <td>0.256</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>13</td>
    <td>63.164614</td>
    <td>0.206(1.24x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>10</td>
    <td>63.172995s</td>
    <td>0.158(1.62x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
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
    <td>60.280368</td>
    <td>0.465</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>22</td>
    <td>61.405561</td>
    <td>0.465(1.30x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>20</td>
    <td>60.397535</td>
    <td>0.331(1.40x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>70</td>
    <td>60.663184</td>
    <td>1.160</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>23</td>
    <td>60.474587</td>
    <td>0.382(3.04x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2</td>
    <td>74.873854</td>
    <td>0.027(43.44x slower)</td>
  </tr>
</table>

### Stress test with changing priority or push/pop(test ignored in summary) [source code](./test/performance_pop_versus_change_priority.rb)
Start with 500 pushes, then:
  * If queue supports changing priority 500 change_priority calls, then 500 pops
  * If does not support changing priority 500 push calls, then 1000 pops
<table>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>436.4</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>380.2(1.94x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>339.9.02(2.17x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>313.9(2.35x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>194.7(3.78 slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>854.6</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>651.3(1.31x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>453.6(1.88x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>390.9(2.19x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>268.8(3.18x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap(PairingHeap)</td>
    <td>1591</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1092(1.46x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>986(1.61x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>562(2.37x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>623(2.55x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap(PairingHeap)</td>
    <td>7404</td>
  </tr>
  <tr>
    <td>pairing_heap(SimplePairingHeap)</td>
    <td>5104(1.45x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1575(4.70x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1258(5.88x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1004(7.38x slower)</td>
  </tr>
</table>

### Dijkstra's algorithm with RGL [source code](./test/performance_rgl.rb)
<table>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>9</td>
    <td>61.469343</td>
    <td>0.116</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>8</td>
    <td>64.312672</td>
    <td>0.125(1.18x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>7</td>
    <td>60.555716</td>
    <td>0.116(1.27x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
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
    <td>65.160945s</td>
    <td>0.154</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>61.950587</td>
    <td>0.145(1.06x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>66.592123</td>
    <td>0.135(1.14x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>20</td>
    <td>61.149944</td>
    <td>0.328</td>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>20</td>
    <td>61.210225s</td>
    <td>0.328</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>18</td>
    <td>62.330882</td>
    <td>0.292(1.12x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>59</td>
    <td>60.053843</td>
    <td>0.991</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>34</td>
    <td>60.586461</td>
    <td>0.563(1.76x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>31</td>
    <td>60.633711</td>
    <td>0.520(1.90x slower)</td>
  </tr>
</table>

### Simple Dijkstra's algorithm implementation [source code](./test/performance_dijkstra.rb)
Heaps that support change_priority operation use it. Heaps that do not support it use dijkstra implementation that do not rely on change_priority instead and do additional pops and pushes instead(see Dijkstra-NoDec from [Priority Queues and Dijkstra’s Algorithm](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf)).
<table>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>28</td>
    <td>62.100299</td>
    <td>0.451</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>23</td>
    <td>60.633153</td>
    <td>0.380(1.19x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>14</td>
    <td>62.019763</td>
    <td>0.226(2.00x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>11</td>
    <td>63.105064s</td>
    <td>0.174(2.58x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>64.407187</td>
    <td>0.155(2.90x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>32</td>
    <td>61.289321</td>
    <td>0.522</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>26</td>
    <td>60.657625</td>
    <td>0.429(1.22x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>19</td>
    <td>60.710888s</td>
    <td>0.313(1.67x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>19</td>
    <td>61.471203</td>
    <td>0.310(1.69x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>12</td>
    <td>60.125779</td>
    <td>0.200(2.61x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>46</td>
    <td>61.226924</td>
    <td>0.753</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>38</td>
    <td>60.563995</td>
    <td>0.628(1.20x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>37</td>
    <td>60.928350</td>
    <td>0.608(1.24x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>28</td>
    <td>61.136970</td>
    <td>0.461(1.63x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>22</td>
    <td>62.214796</td>
    <td>0.354(2.13x slower)</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>176</td>
    <td>60.029817</td>
    <td>3.006</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>124</td>
    <td>60.366607</td>
    <td>2.078(1.45x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>95</td>
    <td>60.021043</td>
    <td>1.585(1.90x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>38</td>
    <td>60.020976</td>
    <td>0.636(4.72x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>27</td>
    <td>61.349925</td>
    <td>0.445(6.75x slower)</td>
  </tr>
</table>

### Summary
#### Change priority required
<table>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
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
    <td>1.688x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.987x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
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
    <td>1.256x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.648x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
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
    <td>1.327x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.383x slower</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
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
    <td>3.878x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9.889x slower</td>
  </tr>
</table>

#### Change priority not required
<table>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]</th>
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
    <td>1.318x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.8x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.519x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2.989x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) +YJIT [x86_64-darwin21]</th>
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
    <td>1.348x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.490x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.792x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.492x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.7.0 (2.6.8) 2022-08-16 c79ef237e0 OpenJDK 64-Bit Server VM 17.0.2+8-86 on 17.0.2+8-86 +indy +jit [x86_64-darwin]</th>
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
    <td>1.292x slower</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>1.359x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.115x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.824x slower</td>
  </tr>
  <tr>
    <th colspan="4">truffleruby 22.2.0, like ruby 3.0.3, GraalVM CE JVM [x86_64-darwin]</th>
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
    <td>1.865x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.915x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>8.791x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>26.044x slower</td>
  </tr>
</table>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhib/pairing_heap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
