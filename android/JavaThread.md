title:  Java多线程
date: 2018年7月28日23:33:26
categories: 多线程
tags: 

	 - Synchronized
	 - ReentrantLock
	 - Volitale
	 - Semaphore
	 - CountDownLatch
	 - CyclicBarrier
cover_picture: /images/JavaThread.jpg
---

### Synchronized 

- 内置锁，互斥性。
- JVM关键字，修饰符。
- 内置条件队列操作接口Object.waie()、notify()、notifyAll()。

ReentrantLock

- 默认非公平锁。

- 内置锁类似功能。

- 公平锁：等待时间最长的会最先被唤醒获取锁 。

- 重入锁：线程可以重复获取**已经持有**的锁。

- Synchronized中，所有的线程都在同一个object的条件队列上等待。而ReentrantLock中，每个condition都维护了一个条件队列。

-  每一个**Lock**可以有任意数据的**Condition**对象，**Condition**是与**Lock**绑定的，所以就有**Lock**的公平性特性：如果是公平锁，线程为按照FIFO的顺序从*Condition.await*中释放，如果是非公平锁，那么后续的锁竞争就不保证FIFO顺序了。

- Condition接口定义的方法，**await**对应于**Object.wait**，**signal**对应于**Object.notify**，**signalAll**对应于**Object.notifyAll**。特别说明的是Condition的接口改变名称就是为了避免与Object中的*wait/notify/notifyAll*的语义和使用上混淆。

  ```java
  /**
  * ReentrantLock 的使用
  */
  public class Queue<T> {
      private final T[] mItems;
      private final Lock mLock = new ReentrantLock();
      private Condition mNotFull = mLock.newCondition();
      private Condition mNotEmpty = mLock.newCondition();
      private int head, tail, count;
  
      public Queue(int maxSize) {
          mItems = (T[]) new Object[maxSize];
      }
  
      public Queue() {
          this(10);
      }
  
      public void put(T t) throws InterruptedException {
          mLock.lock();//获取锁
          try {
              while (count == mItems.length) {
                  //数组满时，线程进入等待队列挂起。线程被唤醒时，从这里返回。
                  mNotFull.await();
              }
              mItems[tail] = t;
              if (++tail == mItems.length) {
                  tail = 0;
              }
              ++count;
              mNotEmpty.signal();
          } finally {
              mLock.unlock();
          }
      }
  
      public T take() throws InterruptedException {
          mLock.lock();
          try {
              while (count == 0) {
                  mNotEmpty.await();
              }
              T o = mItems[head];
              mItems[head] = null;//GC
              if (++head == mItems.length) {
                  head = 0;
              }
              --count;
              mNotFull.signal();
              return o;
          } finally {
              mLock.unlock();
          }
      }
  
  }
  ```

  

### Volatile

- 内存可见性。
- 放置指令重排。

### Semaphore 

- 信号量，跟锁机制存在一定的相似性。
- Semaphore也是一种锁机制。
- ReentrantLock是只允许一个线程获得锁。
- Semaphore允许多个线程同时获得执行许可。

```java
 private static void semaphore() {
        final Semaphore semaphore = new Semaphore(5);
        for (int i = 0; i < 20; i++) {
            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        semaphore.acquire();
                        Thread.sleep(3000);
                        semaphore.release();
                        System.err.println(Thread.currentThread().getName() + ":" + new Date());
                    } catch (InterruptedException e) {
                    }
                }
            });
            thread.setName("Thread:" + i);
            thread.start();
        }
    }
```

### CountDownLatch 

- 一个线程等其它一个或多个线程。

- 计数器实现，一个线程完成任务计数器减1.

  ```java
   private static void countDownLatch() {
          final CountDownLatch countDownLatch = new CountDownLatch(5);
          for (int i = 0; i < 5; i++) {
              Thread thread = new Thread(new Runnable() {
                  @Override
                  public void run() {
                      try {
                          Thread.sleep(2000);
                          System.out.println(Thread.currentThread()
                                  .getName() + ":" + System.currentTimeMillis());
                          countDownLatch.countDown();
                      } catch (InterruptedException e) {
                          System.out.println(e.toString());
                      }
  
                  }
              });
              thread.setName("Thread:--:" + i);
              thread.start();
          }
  
          Thread thread1 = new Thread(new Runnable() {
              @Override
              public void run() {
                  try {
                      System.err.println(countDownLatch.getCount() + "start---------" + System
                              .currentTimeMillis());
                      countDownLatch.await();
                      System.err.println("end-----------" + countDownLatch.getCount());
                  } catch (InterruptedException e) {
                      System.err.println(e.toString());
                  }
  
              }
          });
          thread1.setName("Main Thread:");
          thread1.start();}
  ```

  ### CyclicBarrier

  - 所有线程必须同时到达栅栏位置才能继续执行下一步操作。

  - 可以循环使用。

    ```java
     private static void cyclicBarrier() {
           final CyclicBarrier barrier = new CyclicBarrier(5, new Runnable() {
                @Override
                public void run() {
                    System.out.println("All Over");
                }
            });
            
            for (int i = 0; i < 5; i++) {
                Thread thread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            System.out.println(Thread.currentThread().getName() + "over");
                            barrier.await();
                        } catch (Exception e) {
                            System.out.println(e.toString());
                        }
                    }
                });
                thread.setName("Thread:" + i);
                thread.start();
            }
        }
    
    ```

### ReadWriteLock

- 数据读写，保证数据的一致性和完整性。
- 读和写是互斥的。
- 写和写是互斥的。
- 读和读不是互斥的。

```java
public class Data {
    private Long value;
    private ReadWriteLock mReadWriteLock = new ReentrantReadWriteLock();

    public Long getValue() {
        Lock readLock = mReadWriteLock.readLock();
        try {
            readLock.lock();
            return value;
        } finally {
            readLock.unlock();
        }
    }

    public void setValue(Long value) {
        Lock writeLock = mReadWriteLock.writeLock();
        try {
            writeLock.lock();
            this.value = value;
        } finally {
            writeLock.unlock();
        }

    }
}
```

#### sleep

- sleep使当前线程进入停滞状态（阻塞当前线程），**让出CPU**的使用，不让当前线程独自霸占该进程所获取的CPU资源，以留一定时间给其它线程执行的机会。

- 任何地方使用。

-  sleep睡眠时**仍然占有锁**。

  ```java
   private final Object mLock = new Object();
  
      public void sleepTest() {
          sleep1();
          try {
              Thread.sleep(10);
          } catch (InterruptedException e) {
              e.printStackTrace();
          }
          sleep2();
      }
  
      private void sleep1() {
          new Thread(new Runnable() {
              @Override
              public void run() {
                  System.out.println("sleep1 start");
                  synchronized (mLock) {
                      System.out.println("sleep1 synchronized start");
                      try {
                          Thread.sleep(5000);
                      } catch (InterruptedException e) {
                          System.out.println("sleep1:" + e.toString());
                      }
                      System.out.println("sleep1 synchronized end");
                  }
                  System.out.println("sleep1 end");
              }
          }).start();
      }
  
      private void sleep2() {
          new Thread(new Runnable() {
              @Override
              public void run() {
                  System.out.println("sleep2 start");
                  synchronized (mLock) {
                      System.out.println("sleep2 synchronized start");
                      System.out.println("sleep2 synchronized end");
                  }
                  System.out.println("sleep2 end");
              }
          }).start();
      }
  
  sleep1 start
  sleep1 synchronized start
  sleep2 start
  sleep1 synchronized end
  sleep1 end
  sleep2 synchronized start
  sleep2 synchronized end
  sleep2 end
  ```

  #### wait

  - wait是Object类里的方法，当一个线程执行到wait()时，就进入到一个和该对象相关的等待池中，同时**释放了锁**(暂时失去锁，wait(long timeout)超时到期后还需要返还对象锁)；其他线程可以访问。

  - wait必须放在synchronized block中，否则会在program runtime 时抛出"java.lang.IllegalMonitorStateException"。

    ```java
     public void waitTest() {
            wait1();
            try {
                Thread.sleep(10);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            wait2();
        }
    
        private void wait1() {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    System.out.println("wait1 start");
                    synchronized (mLock) {
                        System.out.println("wait1 synchronized start");
                        try {
                            mLock.wait();
                        } catch (InterruptedException e) {
                            System.out.println("wait1 :" + e.toString());
                        }
                        System.out.println("wait1 synchronized end");
                    }
                    System.out.println("wait1 end");
                }
            }).start();
        }
    
        private void wait2() {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    System.out.println("wait2 start");
                    synchronized (mLock) {
                        System.out.println("wait2 synchronized start");
                        mLock.notify();
                        // mLock.notifyAll();
                        System.out.println("wait2 synchronized end");
                    }
                    System.out.println("wait2 end");
                }
            }).start();
        }
    
    wait1 start
    wait1 synchronized start
    wait2 start
    wait2 synchronized start
    wait2 synchronized end
    wait2 end
    wait1 synchronized end
    wait1 end
    ```

    #### notify、notifyAll

    - wait：线程自动释放其占用的对象锁，并等待notify
    - notify：唤醒一个正在wait当前对象锁的线程，并让它拿到对象锁（多个等待时，具体唤醒哪一个由虚拟机控制）。
    - notifyAll：唤醒所有正在wait当前对象锁的线程，跳出wait状态，竞争对象锁。
    - wait、notify、notifyAll是Object类的本地方法，在调用这三个方法的时候，**当前线程必须获得这个对象的锁**。