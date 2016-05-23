// tests nested function definition and calling
// prints 10
Sum3(x,y,z) := Add(x,a) < a < Add(y,z)
Sum2(a1,a2) := Sum3(a1,a2,0)
(Sum2(4,f1) < f1 < Sum3(1,2,3)) > x > print(x)


/*
debugging

left 
tid=1
Add(x,a) < a < Add(y,z)
a1 -> 4
a2 -> f1
x -> a1
y -> a2
z -> 0

right
tid=2
Add(x,a) < a < Add(y,z)
x -> 1
y -> 2
z -> 3

	left publishes 6 up
	
	right done correctly

now right (2) gives f1 -> 6 to left (1), but if left copied context from right or manager, then it overwrites things.
...........

left 
tid=1
Add(x,a) < a < Add(y,z)
a1 -> 4
a2 -> f1
x -> a1
y -> a2
z -> 0
f1 -> 6

right
tid=2
Add(x,a) < a < Add(y,z)
x -> 1
y -> 2
z -> 3
*/
