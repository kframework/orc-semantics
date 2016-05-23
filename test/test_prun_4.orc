// same as test_prun_3 but brackets rearranged.
// the correct behavior is that it gets stuck. see comment below.
DummyExp(a,b) := Add(a,b)
(Add(f2,f3) < f3 < (Add(f1,f2) < f2 < Add(f1,1))) < f1 < Add(1,1)

/* Here is how it is structured
                          
                             prunMgr(f1)
                             /         \
                        prunMgr(f3)    1+1
                       /         \                                    
  This f2 --------> f2+f3        prunMgr(f2)                                  
  is stuck.                     /          \                              
  it should not              f1+f2         1+f1                             
  see the value 
  provided by 
  prunMgr(f2)?                                                 

*/                                                                        
