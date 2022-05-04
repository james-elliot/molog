fast:
	gnatmake -O2 -gnatN -fomit-frame-pointer -gnatp master

slow:
	gnatmake master

clean:
	\rm -f *.ali *.o master *~
