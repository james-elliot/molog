# MOLOG, a PROLOG for modal logic

MOLOG was written and published in 1992, at the dawn of languages based on PROLOG. It was designed to implement PROLOG resolution mechanisms on other logics than predicate logic. In fact it can be used to implement any kind of logic using Gentzen sequents. My PhD supervisor was Luis Fariñas who had worked at Marseilles with Alain Colmerauer (the father of PROLOG).  
Unfortunately, the second AI winter of the 90s killed almost all research on these subjects; moreover, today, non classical logics use technics such as tableaux to solve the same kind of problems.

MOLOG was written in ADA, with a part in C for the implementation of parallelism. Let's remind the reader that in 1992 ADA parallelism was not properly implemented by the ALSYS compiler on Sun/Unix machines (it was only working properly with DEC-ADA under DEC/VMS). So I had to develop my own set of routines for non blocking communications and parallelism (it was called PARADISE).

At the occasion of the thirtieth anniversary of MOLOG, I decided to dig out the old code. The ADA part compiled and worked almost on the spot, the C implementation of communication and parallelism was a mess. The perfect solution would be to rewrite this part using MPI/ADA bindings, but this kind of beast seems hard to find, and it is extremely dubious that I will ever work again on this code.

So I publish this version, which is full ADA, but doesn't implement parallelism. It's a kind of tribute to all people who ever worked on these subjects, and whose work has slowly sunk into oblivion. 

You need gnu make and the gnat ada compiler:  
Compile by typing: make  
Run the example with:  
  ./master < examples/chevalier

There is a short description of MOLOG in this [paper](http://www.alliot.fr/papers/fgcs92.pdf)
For more information you can read my [PhD](http://www.alliot.fr/papers/thesejma.pdf), but it is in french...

