# PairingHeap

PairingHeap is a pure Ruby priority queue implementation using a pairing heap as the underlying data structure. While a pairing heap is asymptotically less efficient than the Fibonacci heap, it is usually faster in practice. This makes it a popular choice for Prim's MST or Dijkstra's algorithm implementations.

Also implementation without priority change support is provided(`SimplePairingHeap`), while the asymptotical complexity of the methods stay the same, bookkeeping of elements is not needed making the constant smaller.

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

* [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue) that uses a lazy binomial heap. This is probably the most popular option, used for example in [RGL](https://github.com/monora/rgl/)
* Pure Ruby implementation of Fibonacci Heap from [priority-queue](https://github.com/supertinou/priority-queue) ([link to source](https://github.com/supertinou/priority-queue/blob/master/lib/priority_queue/ruby_priority_queue.rb))
* [rb_heap](https://github.com/florian/rb_heap) that uses a binary heap. Note however that this implementation does not support change_priority operation.

All tests except for the third one were executed by [benchmark-ips](https://github.com/evanphx/benchmark-ips) with parameters `time = 60` and `warmup = 15`, on an `Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz`.
### Stress test without changing priority test(N = 1000) [source code](./test/performance.rb)
Original performance test from [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue)
> A stress test of 1,000,000 operations: starting with 1,000 pushes/0 pops, following 999 pushes/1 pop, and so on till 0 pushes/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>18</td>
    <td>60.232046</td>
    <td>0.299</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>15</td>
    <td>63.978031</td>
    <td>0.234(1.27x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>60.031283</td>
    <td>0.150(1.99x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>9</td>
    <td>60.497355</td>
    <td>0.149(2.01x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>66.866055</td>
    <td>0.120(2.50x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>22</td>
    <td>62.866807</td>
    <td>0.350</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>16</td>
    <td>61.358679</td>
    <td>0.261(1.34x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>14</td>
    <td>64.394112</td>
    <td>0.217(1.61x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>12</td>
    <td>60.975479</td>
    <td>0.197(1.78x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>11</td>
    <td>65.568648</td>
    <td>0.168(2.09x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>21</td>
    <td>60.357577s</td>
    <td>0.348</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>15</td>
    <td>60.417252</td>
    <td>0.248(1.40x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>14</td>
    <td>61.022450</td>
    <td>0.229(1.52x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>13</td>
    <td>63.661862</td>
    <td>0.204(1.70x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>62.643449</td>
    <td>0.128(2.72x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
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
    <td>60.472129</td>
    <td>0.711</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>30</td>
    <td>60.359748</td>
    <td>0.497(1.43x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>25</td>
    <td>62.084250</td>
    <td>0.403(1.77x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>23</td>
    <td>62.419893</td>
    <td>0.369(1.93x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>22</td>
    <td>60.947299</td>
    <td>0.361(1.97x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 1000) [source code](./test/performance_with_change_priority.rb)
A stress test of 1,501,500 operations: starting with 1,000 pushes/1000 change_priorities/0 pops, following 999 pushes/999 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>14</td>
    <td>63.536300</td>
    <td>0.220</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>63.319474s</td>
    <td>0.142(1.55x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>67.385714</td>
    <td>0.119(1.86x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
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
    <td>62.243080</td>
    <td>0.241</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>13</td>
    <td>63.030390</td>
    <td>0.206(1.17x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>10</td>
    <td>64.865853</td>
    <td>0.154(1.56x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
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
    <td>61.540851</td>
    <td>0.244</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>14</td>
    <td>61.471507</td>
    <td>0.228(1.07x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>67.393730</td>
    <td>0.134(1.83x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
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
    <td>61.322001</td>
    <td>0.440</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>21</td>
    <td>60.334636</td>
    <td>0.349(1.26x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>20</td>
    <td>61.471507</td>
    <td>0.327(1.35x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 10) [source code](./test/performance_with_change_priority.rb)
A stress test of 165 operations: starting with 10 pushes/10 change_priorities/0 pops, following 9 pushes/9 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/10 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>5914.3</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>4293.5(1.38x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>3755.2(1.57x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>7082.7</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>6687.1(1.06x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>5006.4(1.41x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>6861.6</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>6446.4(1.06x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>4365.4(1.57x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>14032</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>12841(1.09x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>10404(1.35x slower)</td>
  </tr>
</table>

### Dijkstra's algorithm with RGL [source code](./test/performance_rgl.rb)
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
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
    <td>64.505899</td>
    <td>0.140</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>8</td>
    <td>63.970577</td>
    <td>0.125(1.12x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>7</td>
    <td>62.573724</td>
    <td>0.112(1.25x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
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
    <td>63.567801</td>
    <td>0.142</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>64.575079</td>
    <td>0.140(1.02x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>8</td>
    <td>60.123700</td>
    <td>0.133(1.06x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>14</td>
    <td>64.124373</td>
    <td>0.218</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>13</td>
    <td>61.147807</td>
    <td>0.213(1.03x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>64.250067</td>
    <td>0.156(1.40x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
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
    <td>61.450341</td>
    <td>0.361</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>18</td>
    <td>61.618204</td>
    <td>0.296(1.22x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>17</td>
    <td>60.156184</td>
    <td>0.283(1.27x slower)</td>
  </tr>
</table>

### Simple Dijkstra's algorithm implementation [source code](./test/performance_dijkstra.rb)
Heaps that support change_priority operation use it. Heaps that do not support it use dijkstra implementation that do not rely on change_priority instead and do additional pops and pushes instead(see Dijkstra-NoDec from [Priority Queues and Dijkstra’s Algorithm](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf)).
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
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
    <td>61.386477</td>
    <td>0.407</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>22</td>
    <td>62.044470</td>
    <td>0.355(1.15x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>13</td>
    <td>60.717112</td>
    <td>0.214(1.90x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>10</td>
    <td>61.730614</td>
    <td>0.162(2.51x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>65.899982</td>
    <td>0.152(2.68x slower)</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>29</td>
    <td>61.656995</td>
    <td>0.471</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>24</td>
    <td>61.813482</td>
    <td>0.389(1.21x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>19</td>
    <td>62.191040</td>
    <td>0.306(1.54x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>18</td>
    <td>60.062072</td>
    <td>0.300(1.57x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>12</td>
    <td>60.860292</td>
    <td>0.197(2.38x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap (SimplePairingHeap)</td>
    <td>24</td>
    <td>61.972936</td>
    <td>0.387</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>20</td>
    <td>62.178839</td>
    <td>0.322(1.20x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>14</td>
    <td>61.540058s</td>
    <td>0.228(1.70x slower)</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>14</td>
    <td>62.125831</td>
    <td>0.225(1.72x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>62.319669</td>
    <td>0.155(2.41x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
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
    <td>61.192519</td>
    <td>0.770</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>39</td>
    <td>61.028398</td>
    <td>0.639(1.20x slower)</td>
  </tr>
  <tr>
    <td>pairing_heap (PairingHeap)</td>
    <td>36</td>
    <td>60.035760</td>
    <td>0.601(1.28x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>28</td>
    <td>61.599202</td>
    <td>0.456(1.69x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>22</td>
    <td>60.540367</td>
    <td>0.364(2.12x slower)</td>
  </tr>
</table>

### Summary
#### Change priority required
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
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
    <td>1.523x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.751x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
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
    <td>1.146x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.482x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
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
    <td>1.153x slower</td>

  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.793x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
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
    <td>1.222x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.394x slower</td>
  </tr>
</table>

#### Change priority not required
<table>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]</th>
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
    <td>1.209</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.954</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.235x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2.588x slower</td>
  </tr>
  <tr>
    <th colspan="4">ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) +YJIT [x86_64-darwin21]</th>
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
    <td>1.273x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.590x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.666x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.230x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +jit [darwin-x86_64]</th>
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
    <td>1.296</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.607x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.710</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>2.452x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.3.3.0 (2.6.8) 2022-01-19 b26de1f5c5 OpenJDK 64-Bit Server VM 16.0.1+9-24 on 16.0.1+9-24 +indy +jit [darwin-x86_64]</th>
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
    <td>1.353x slower</td>
  </tr>
  <tr>
    <td>rb_heap</td>
    <td>1.522x slower</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.730x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>2.044x slower</td>
  </tr>
</table>
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhib/pairing_heap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
