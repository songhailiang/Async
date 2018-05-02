//
//  ViewController.swift
//  Async
//
//  Created by songhailiang on 2018/4/28.
//  Copyright © 2018 songhailiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        Logger.log("start", event: .debug)
        Async.main(after: 3) {
            Logger.log("do some job...", event: .debug)
            }.main(after: 3) {
                Logger.log("job done...[\(Thread.current)]", event: .debug)
        }

        Async.global(after: 4) {
            Logger.log("do another job", event: .debug)
        }

        Async.custom(label: "job", after: 3) {
            Logger.log("third job..", event: .debug)
        }

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
            Logger.log("another job after heavy jobs", event: .debug)
        }

        Async.main {
            job1.cancel()
            job2.cancel()
            }.custom(label: "cancel job") {
                Logger.log("all job canceld. [\(Thread.current)]", event: .debug)
        }

        let group = AsyncGroup()
        Logger.log("start to do some jobs.", event: .debug)
        group.start { (job) in
            Logger.log("start job1...", event: .debug)
            Async.main(after: 3, {
                job.finish()
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
        group.finished {
            Logger.log("all jobs are done.", event: .debug)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

