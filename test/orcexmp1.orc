// This increments count to 3 then after n time units, publishes. It publishes 3 for n>0. 
D():=0
(1|1|1) >> count.inc() >> zero() | Rtimer(1) >> count.read()

/* 
test with the following options:
--search --pattern "<gPublish> L:List </gPublish> when L =/=K .List"
--ltlmc "<>Ltl isGPublished(3)"
*/
