# Async
More easier to use GCD in Swift.

This is heavily inspired by [Async](https://github.com/duemunk/Async), a very simple, light but powerful project.

I removed some of the features to make it more simple but enough to use, and rewrote the ```AsyncGroup``` part to make it more easier to support async operations.

## Simple to use: 
```
DispatchQueue.main.async {
   // to do something
}

Async.main {
  // to do something
}
```

```
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    // to do something after 3 seconds
}
Async.main(after: 3) {
    // to do something after 3 seconds
}
```

## Custom queue
*only support concurrent queue for now*
```
Async.custom(label: "job", after: 3) {
    Logger.log("do something on a custom queue", event: .debug)
}
```

## Chainable
```
Async.main(after: 3) {
    Logger.log("do some job...", event: .debug)
}.main {
    Logger.log("job finished.", event: .debug)
}
```

## Cancelable
**Note: only when the block hasn't already begun running that can be cancelled.**
```
let job1 = Async.main {
    Logger.log("start to do some heavy jobs..", event: .debug)
    for i in 0 ... 1000000 {
        // do some heavy jobs
        if i % 100000 == 0 {
            Logger.log("job \(i)", event: .debug)
        }
    }
    Logger.log("all heavy jobs are done", event: .debug)
}
let job2 = job1.global {
    Logger.log("this will be cancelled", event: .debug)
}

Async.main {
    job1.cancel() // can't be cancelled because it's running
    job2.cancel() // will be cancelled
}.custom(label: "cancel job") {
    Logger.log("all job canceld. [\(Thread.current)]", event: .debug)
}
```

## Async Group
Support async operations
```
let group = AsyncGroup()
group.start { (job) in
    Logger.log("start job1...", event: .debug)
    Async.main(after: 3, {
        job.finish() // call finish() when async operation is done.
        Logger.log("job1 done.", event: .debug)
    })
}
group.start { (job) in
    Logger.log("start job2...", event: .debug)
    Async.main(after: 5, {
        job.finish()
        Logger.log("job2 done.", event: .debug)
    })
}
group.finished { // will be called when all async jobs are done.
    Logger.log("all jobs are done.", event: .debug)
}
```



