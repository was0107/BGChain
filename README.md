# BGChain
链式执行


将分散在不同地方实现的链路执行方式，进行归总		
支持命名，排序，部分执行等		



`
2020-03-20 21:03:00.490269+0800 BGChain[69868:6359901] 正在注册执行链路 [ 0]:-[MNodeTest:pop:test1:100
2020-03-20 21:03:00.490470+0800 BGChain[69868:6359901] 正在注册执行链路 [ 1]:-[MNodeTest:pop:test2:100
2020-03-20 21:03:00.490653+0800 BGChain[69868:6359901] 正在注册执行链路 [ 2]:-[MNodeTest:ad:test3:10
2020-03-20 21:03:00.490802+0800 BGChain[69868:6359901] 正在注册执行链路 [ 3]:-[MNodeTest:ad:test4:10
2020-03-20 21:03:00.491156+0800 BGChain[69868:6359901] 正在注册执行链路 [ 4]:-[BGNode:pop:test111:20
2020-03-20 21:03:00.491295+0800 BGChain[69868:6359901] 正在注册执行链路 [ 5]:-[MNodeTest1:pop:MNodeTest111:200
2020-03-20 21:03:00.491449+0800 BGChain[69868:6359901] 开始执行链路 pop : -[BGNode:pop:test111:20
2020-03-20 21:03:00.491593+0800 BGChain[69868:6359901] delay 2s :-[BGNode:pop:test111:20
2020-03-20 21:03:02.492014+0800 BGChain[69868:6359901] delay 3s:-[MNodeTest:pop:test1:100
2020-03-20 21:03:05.493530+0800 BGChain[69868:6359901] delay 3s:-[MNodeTest:pop:test2:100
2020-03-20 21:03:08.494648+0800 BGChain[69868:6359901] delay MNodeTest1 2s  :-[MNodeTest1:pop:MNodeTest111:200
2020-03-20 21:03:08.494987+0800 BGChain[69868:6359901] exe:-[MNodeTest1:pop:MNodeTest111:200
`