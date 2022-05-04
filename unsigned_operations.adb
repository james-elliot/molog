PACKAGE BODY unsigned_operations IS

   item_size : CONSTANT natural := item'SIZE;
   item_last : CONSTANT item    := item'LAST;

   FUNCTION "NOT" (left : IN item) RETURN item IS
   BEGIN
      RETURN (- left - 1);
   END "NOT";


   FUNCTION "AND" (left, right : IN item) RETURN item IS

      s1     : item := left;
      s2     : item := right;
      target : item := 0;
      signe  : boolean;
      to_add : item := 1;

   BEGIN

      -- First check if we must set the high order bit in the result.
      -- We have to do it  if both numbers have the high order bit set,
      -- i.e. if they are negatives.
      IF (s1 < 0) AND THEN (s2 < 0) THEN
         signe := true;
      ELSE
         signe := false;
      END IF;
      -- Reset the high order bit in S1 if it is set.
      IF (s1 < 0) THEN
         s1 := (item_last + s1) + 1;
      END IF;
      -- The same goes for S2
      IF (s2 < 0) THEN
         s2 := (item_last + s2) + 1;
      END IF;
      -- Now loop for the other bits
      -- We could do better and faster by testing if S1 and S2 are both non 0,
      -- instead of doing ITEM_SIZE-1 loops every time.
      FOR i IN 1 .. item_size - 1 LOOP
         IF (s1 MOD 2 = 1) AND THEN (s2 MOD 2 = 1) THEN
            target := target + to_add;
         END IF;
-- We use ASL instead of * 2, because last iteration would provoke an NUMERIC_E
--+RROR
         -- (Multiplication of 2^31 by 2)
         to_add := asl (to_add, 1);
         s1     := s1 / 2;
         s2     := s2 / 2;
      END LOOP;
      -- We set high order bit if we have to
      IF (signe) THEN
         target := (target - 1) - item_last;
      END IF;
      -- That's all folks...
      RETURN target;
   END "AND";

   FUNCTION "OR" (left, right : IN item) RETURN item IS

      s1     : item := left;
      s2     : item := right;
      target : item := 0;
      signe  : boolean;
      to_add : item := 1;

   BEGIN

      IF (s1 < 0) OR (s2 < 0) THEN
         signe := true;
      ELSE
         signe := false;
      END IF;
      IF (s1 < 0) THEN
         s1 := (item_last + s1) + 1;
      END IF;
      IF (s2 < 0) THEN
         s2 := (item_last + s2) + 1;
      END IF;
      FOR i IN 1 .. item_size - 1 LOOP
         IF (s1 MOD 2 = 1) OR (s2 MOD 2 = 1) THEN
            target := target + to_add;
         END IF;
         to_add := asl (to_add, 1);
         s1     := s1 / 2;
         s2     := s2 / 2;
      END LOOP;
      IF (signe) THEN
         target := (target - 1) - item_last;
      END IF;
      RETURN target;
   END "OR";

   FUNCTION "XOR" (left, right : IN item) RETURN item IS

      s1     : item := left;
      s2     : item := right;
      target : item := 0;
      signe  : boolean;
      to_add : item := 1;

   BEGIN

      IF (s1 < 0) XOR (s2 < 0) THEN
         signe := true;
      ELSE
         signe := false;
      END IF;
      IF (s1 < 0) THEN
         s1 := (item_last + s1) + 1;
      END IF;
      IF (s2 < 0) THEN
         s2 := (item_last + s2) + 1;
      END IF;
      FOR i IN 1 .. item_size - 1 LOOP
         IF (s1 MOD 2 = 1) XOR (s2 MOD 2 = 1) THEN
            target := target + to_add;
         END IF;
         to_add := asl (to_add, 1);
         s1     := s1 / 2;
         s2     := s2 / 2;
      END LOOP;
      IF (signe) THEN
         target := (target - 1) - item_last;
      END IF;
      RETURN target;
   END "XOR";


   FUNCTION asl (arg : IN item;
                 num : IN natural) RETURN item IS
      local : item := arg;
      FUNCTION asl1 (arg : IN item) RETURN item IS
      BEGIN
         IF (arg < 0) THEN
            RAISE numeric_error;
         ELSIF (arg <= item_last / 2) THEN
            RETURN arg * 2;
         ELSE
            RETURN (- 2) * (item_last - arg) - 2;
         END IF;
      END asl1;

   BEGIN
      FOR i IN 1 .. num LOOP
         local := asl1 (local);
      END LOOP;
      RETURN local;
   END asl;


   FUNCTION asr (arg : IN item;
                 num : IN natural) RETURN item IS
      local : item := arg;

      FUNCTION asr1 (arg : IN item) RETURN item IS
      BEGIN
         IF (arg > 0) THEN
            RETURN arg / 2;
         ELSE
            RETURN (arg + 1) / 2 + item_last;
         END IF;
      END asr1;

   BEGIN

      FOR i IN 1 .. num LOOP
         local := asr1 (local);
      END LOOP;
      RETURN local;
   END asr;


END unsigned_operations;
